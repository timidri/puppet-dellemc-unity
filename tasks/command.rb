#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'

class CommandTask < TaskHelper

  def task(command:, endpoint:, parameters:nil, body:nil, **kwargs)
    result = {}

    begin

      case command
      when 'get'
        result['response'] = transport.unity_get(endpoint, parameters)
      when 'post'
        result['response'] = JSON.parse(transport.unity_post(endpoint, body).body)
      when 'delete'
        result['response'] = transport.unity_delete(endpoint)
      else
        raise "Invalid Command"
      end

    rescue Exception => e # rubocop:disable Lint/RescueException
      result[:_error] = { msg: e.message,
                          kind: 'timidri-unity/unknown',
                          details: {
                            class: e.class.to_s,
                            backtrace: e.backtrace,
                          } }
    end
    puts result.to_json
  end

  if __FILE__ == $0
    CommandTask.run
  end

end

