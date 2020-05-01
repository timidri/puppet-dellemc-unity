require 'uri'
require 'json'
require 'rest-client'

module Puppet::Transport
  # The main connection class to a Device endpoint
  class Unity
    def initialize(_context, connection_info)
      # TODO: Add additional validation for connection_info
      port = connection_info[:port].nil? ? 443 : connection_info[:port]
      Puppet.debug "Trying to connect to #{connection_info[:host]}:#{port} as user #{connection_info[:user]}"
      # NOTE: the authentication header only needs to be sent in the first request
      # subsequent requests are authenticated using the persistent cookie returned from the first request
      # see https://www.dellemc.com/en-us/collaterals/unauth/technical-guides-support-information/products/storage/docu69331.pdf
      # page 44: Connecting and authenticating
      RestClient.log = STDOUT if Puppet.debug

      headers =  {
        'X-EMC-REST-CLIENT' => 'true',
        'Content-Type'      => 'application/json',
        'Accept'            => 'application/json'
        }

      @api = RestClient::Resource.new("https://#{connection_info[:host]}:#{port}/api",
                                      user:       connection_info[:user],
                                      password:   connection_info[:password].unwrap,
                                      headers:    headers,
                                      verify_ssl: OpenSSL::SSL::VERIFY_NONE)
      # do an initial authenticated request to get cookies and the CSRF token
      response = @api['types/job/instances'].get
      # now configure the client for subsequent requests without credentials
      # but with cookies and the CSRF token (needed for POST and DELETE requests)
      headers['EMC-CSRF-TOKEN'] = response.headers[:emc_csrf_token]
      @api = RestClient::Resource.new("https://#{connection_info[:host]}:#{port}/api",
          headers: headers,
          cookies: response.cookie_jar,
          verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end

    def unity_post(path, body)
      path = URI.escape(path) if path
      response = @api[path].post(body.to_json)
      response
    rescue RestClient::ExceptionWithResponse => e
      raise Puppet::ResourceError, "Unity error: #{e}, message: \"#{JSON.parse(e.response.body)['error']['messages'].map { |m| m['en-US'] }.join(';')}\""
    end

    def unity_delete(path)
      path = URI.escape(path) if path
      response = @api[path].delete
      response
    rescue RestClient::ExceptionWithResponse => e
      raise Puppet::ResourceError, "Unity error: #{e}, message: \"#{JSON.parse(e.response.body)['error']['messages'].map { |m| m['en-US'] }.join(';')}\""
    end

    def unity_get(path, params = nil)
      path = URI.escape(path) if path
      args = if args.nil?
               { compact: true }
             else
               args.merge(compact: true)
             end
      result = @api[path].get params: params
      body = JSON.parse(result.body)
      # When returning a single resource via the API the response does not contain the "entries" key
      body['entries'].nil? ? body : body['entries']
    rescue RestClient::ExceptionWithResponse => e
      raise Puppet::ResourceError, "Unity error: #{e}, message: \"#{JSON.parse(e.response.body)['error']['messages'].map { |m| m['en-US'] }.join(';')}\""
    rescue JSON::ParserError => e
      raise Puppet::ResourceError, "Unable to parse JSON response from Unity API: #{e.inspect}\n#{e.full_message}"
    end

    # Request a collection of Unity resources
    # Note: the type needs to be a valid Unity resource type
    def unity_get_collection(type, fields = fields_for_type(type))
      unity_get("types/#{type}/instances", fields: fields.join(',')).map { |item| item['content'] }
    end

    def unity_create_instance(type, body)
      unity_post("types/#{type}/instances", body)
    end

    def unity_update_instance(type, name, body)
      unity_post("instances/#{type}/name:#{name}/action/modify", body)
    end

    def unity_delete_instance(type, name)
      unity_delete("instances/#{type}/name:#{name}")
    end

    def create_lun(name, pool_id, size, is_thin_enabled)
      unity_post('types/storageResource/action/createLun', {
        "lunParameters": {
          "pool": {
            "id": pool_id
          },
          "size": size,
          "isThinEnabled": is_thin_enabled
        },
        "name": name

      })
    end

    def delete_lun(lun_id)
      unity_delete("instances/storageResource/#{lun_id}")
    end

    def create_vvol(name, cap_profile_id, size)
      unity_post('types/storageResource/action/createVVolDatastore', {
        "name": name,
        "description": "Created via Bolt",
        "vvolDatastoreType": 1,
        "vvolDatastoreCapabilityProfilesParameters": {
          "addCapabilityProfile": [
            {
              "capProfile": { "id": cap_profile_id },
              "sizeTotal": size
            }
          ]
        }
      })
    end

    def create_nfs(name, pool_id, nas_id, size)
      # It's useful to parse the JSON so Bolt prints it pretty
      JSON.parse(unity_post('types/storageResource/action/createFilesystem', {
        "name": name,
        "fsParameters": {
          "supportedProtocols": 0,
          "pool": {
            "id": pool_id
          },
          "nasServer": {
            "id": nas_id
          },
          "isThinEnabled": true,
          "size": size
        },
        "nfsShareCreate": [
          {
            "name": name,
            "path": "/"
          }
        ]
      }).body)
    end

    # Return Unity resource fields for a given Puppet type
    def fields_for_type(type)
      # hack: allow for omitting the "unity_" prefix
      # require 'pry';binding.pry
      type = type.downcase
      type = "unity_#{type}" unless type.start_with?('unity_')
      attributes = Puppet::Type.type(type.to_sym).context.type.attributes
      attributes.values.map { |v| v[:field_name] }.select { |f| !f.nil? }
    end

    # @summary
    #   Returns device's facts
    def facts(_context)
      # require 'pry';binding.pry
      system_info = unity_get_collection('basicSystemInfo',[])[0]
      {
        "operatingsystem"      => 'dellemc_unity',
        "device_model"         => system_info['model'],
        "device_name"          => system_info['name'],
        "software_version"     => system_info['softwareVersion'],
        "api_version"          => system_info['apiVersion'],
        "earliest_api_version" => system_info['earliestApiVersion'],
      }
    end

    def verify(context)
      # Test that transport can talk to the remote target
    end

    def close(_context)
      # Close connection, free up resources
    end
  end
end
