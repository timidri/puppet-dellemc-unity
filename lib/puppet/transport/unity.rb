# require 'faraday'
# require 'faraday_middleware'
# require 'faraday-cookie_jar'
require 'uri'
require 'json'
require 'rest-client'
# require 'pry'

module Puppet::Transport
  # The main connection class to a Device endpoint
  class Unity
    def initialize(_context, connection_info)
      # TODO: Add additional validation for connection_info
      port = connection_info[:port].nil? ? 443 : connection_info[:port]
      Puppet.debug "Trying to connect to #{connection_info[:host]}:#{port} as user #{connection_info[:user]}"
      # TODO: the authentication header only needs to be sent in the first request
      # subsequent requests are authenticated using the persistent cookie returned from the first request
      # see https://www.dellemc.com/en-us/collaterals/unauth/technical-guides-support-information/products/storage/docu69331.pdf
      # page 44: Connecting and authenticating
      @api = RestClient::Resource.new("https://#{connection_info[:host]}:#{port}/api", 
        :user       => connection_info[:user], 
        :password   => connection_info[:password].unwrap, 
        :headers    => { 'X-EMC-REST-CLIENT' => 'true' },
        :verify_ssl =>  OpenSSL::SSL::VERIFY_NONE)
      RestClient.log = STDOUT if Puppet.debug
    end

    def unity_get(path, args = nil)
      path = URI.escape(path) if path
      args = if args.nil?
               { compact: true }
             else
               args.merge(compact: true)
             end
      result = @api[path].get params:args
      JSON.parse(result.body)['entries']
    rescue RestClient::ExceptionWithResponse => e
      raise Puppet::ResourceError, "Unity error: #{e.to_s}, message: \"#{JSON.parse(e.response.body)['error']['messages'].map { |m| m['en-US'] }.join(';')}\""
    rescue JSON::ParserError => e
      raise Puppet::ResourceError, "Unable to parse JSON response from Unity API: #{e.inspect}\n#{e.full_message}"
    end

    def unity_get_instances(type, fields = ['id'])
      unity_get("types/#{type}/instances", fields: fields.join(','))
    end

    # @summary
    #   Returns device's facts
    def facts(_context)
      system_info = unity_get_instances('basicSystemInfo')[0]['content']
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
