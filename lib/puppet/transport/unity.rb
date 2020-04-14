require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'uri'
require 'json'
require 'pry'

module Puppet::Transport
  # The main connection class to a Device endpoint
  class Unity
    def initialize(_context, connection_info)
      #TODO Add additional validation for connection_info
      port = connection_info[:port].nil? ? 443 : connection_info[:port]
      Puppet.debug "Trying to connect to #{connection_info[:host]}:#{port} as user #{connection_info[:user]}"
      @connection = Faraday.new(
        url: "https://#{connection_info[:host]}:#{port}/api",
        headers: {
          'X-EMC-REST-CLIENT' => 'true',
        },
        ssl: { verify: false },
      ) do |conn|
        conn.use FaradayMiddleware::FollowRedirects, limit: 10
        conn.use :cookie_jar
        # TODO the authentication header only needs to be sent in the first request
        # subsequent requests are authenticated using the persistent cookie returned from the first request
        # see https://www.dellemc.com/en-us/collaterals/unauth/technical-guides-support-information/products/storage/docu69331.pdf
        # page 44: Connecting and authenticating
        conn.request :basic_auth, connection_info[:user], connection_info[:password].unwrap
        # conn.response :logger, nil, headers: true, bodies: true, log_level: :debug
        conn.use Faraday::Response::RaiseError
        conn.adapter Faraday.default_adapter
      end
    end

    def unity_get(path, args = nil)
      path = URI.escape(path) if path
      args = if args.nil?
               { compact: true }
             else
               args.merge(compact: true)
             end
      result = @connection.get(path, args)
      JSON.parse(result.body)['entries']
    rescue Faraday::ClientError => e
      raise Puppet::ResourceError, "Client error response received from Unity: #{e.inspect}\n#{e.full_message}"
    rescue Faraday::ServerError => e
      raise "Server error response received from Unity: #{e.inspect}\n#{e.full_message}"
    rescue JSON::ParserError => e
      raise Puppet::ResourceError, "Unable to parse JSON response from Unity API: #{e.inspect}\n#{e.full_message}"
    end

    def unity_get_instances(type, fields=['id'])
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

    def close(context)
      # Close connection, free up resources
      @connection.close
    end
  end
end
