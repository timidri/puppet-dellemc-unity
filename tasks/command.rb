#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('unity')
result = {}


begin
  # Puppet.debug = true 
  case task.params['command']
  when 'get'
    result['response'] = task.transport.unity_get(task.params['endpoint'], task.params['parameters'])
  when 'post'
    result['response'] = task.transport.unity_post(task.params['endpoint'], task.params['body'])
  when 'delete'
    result['response'] = task.transport.unity_delete(task.params['endpoint'])
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