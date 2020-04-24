#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
require_relative '../lib/puppet/type/unity_lun'
task = Puppet::Util::TaskHelper.new('unity')
result = {}


begin
#  Puppet.debug = true 
  task.params['is_thin_enabled'] = true unless task.params['is_thin_enabled']

  result['response'] = task.transport.create_lun(
    task.params['name'],
    task.params['pool_id'],
    task.params['size'],
    task.params['is_thin_enabled'],
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