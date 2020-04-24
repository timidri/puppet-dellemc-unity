#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('unity')
result = {}

begin
  result['nass'] = task.transport.unity_get_collection('nasServer', task.transport.fields_for_type('nas'))
rescue Exception => e # rubocop:disable Lint/RescueException
  result[:_error] = { msg: e.message,
                      kind: 'timidri-unity/unknown',
                      details: {
                        class: e.class.to_s,
                        backtrace: e.backtrace,
                      } }
end

puts result.to_json
