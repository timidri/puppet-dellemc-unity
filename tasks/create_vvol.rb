#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
require_relative '../lib/puppet/type/unity_nas'
task = Puppet::Util::TaskHelper.new('unity')
result = {}


begin
  # Puppet.debug = true 

  result['response'] = task.transport.create_vvol(
    task.params['name'],
    task.params['cap_profile_id'],
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