#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('unity')
result = {}


begin
  # Puppet.debug = true 

  result['response'] = task.transport.create_nfs(
    task.params['name'],
    task.params['pool_id'],
    task.params['nas_id'],
    task.params['size'],
  )
rescue Exception => e # rubocop:disable Lint/RescueException
  result[:_error] = { msg: e.message,
                      kind: 'timidri-unity/unknown',
                      details: {
                        class: e.class.to_s,
                        backtrace: e.backtrace,
                      } }
end

puts result.to_json