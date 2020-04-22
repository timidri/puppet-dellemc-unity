require 'uri'
require 'json'
require 'rest-client'
require 'pry'

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
      @api[path].post body.to_json
    rescue RestClient::ExceptionWithResponse => e
      raise Puppet::ResourceError, "Unity error: #{e}, message: \"#{JSON.parse(e.response.body)['error']['messages'].map { |m| m['en-US'] }.join(';')}\""
    end

    def unity_delete(path)
      path = URI.escape(path) if path
      @api[path].delete
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
      JSON.parse(result.body)['entries']
    rescue RestClient::ExceptionWithResponse => e
      raise Puppet::ResourceError, "Unity error: #{e}, message: \"#{JSON.parse(e.response.body)['error']['messages'].map { |m| m['en-US'] }.join(';')}\""
    rescue JSON::ParserError => e
      raise Puppet::ResourceError, "Unable to parse JSON response from Unity API: #{e.inspect}\n#{e.full_message}"
    end

    def unity_get_collection(type, fields = ['id'])
      unity_get("types/#{type}/instances", fields: fields.join(','))
    end

    def get_pools
      unity_get_collection('pool', fields_for_type('pool'))
    end

    def get_luns
      unity_get_collection('lun', fields_for_type('lun'))
      # binding.pry
    end

    def get_jobs
      unity_get_collection('job', fields_for_type('job'))
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


    def fields_for_type(type)
      attributes = Puppet::Type.type("unity_#{type}".downcase.to_sym).context.type.attributes
      attributes.values.map { |v| v[:field_name] }
    end

    # @summary
    #   Returns device's facts
    def facts(_context)
      system_info = unity_get_collection('basicSystemInfo')[0]['content']
      {
        operatingsystem:      'dellemc_unity',
        model:                system_info['model'],
        name:                 system_info['name'],
        software_version:     system_info['softwareVersion'],
        api_version:          system_info['apiVersion'],
        earliest_api_version: system_info['earliestApiVersion'],
      }
    end

    def verify(context)
      # Test that transport can talk to the remote target
    end

    def close(_context)
      # Close connection, free up resources
      @connection.close
    end
  end
end
