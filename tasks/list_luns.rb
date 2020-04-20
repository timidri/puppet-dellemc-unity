#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'
require_relative '../lib/puppet/type/unity_lun'
task = Puppet::Util::TaskHelper.new('unity')
result = {}

begin
  # we are loading the type here and use the :field_name attribute
  # to determine which fields we want to request from the API
  attributes = Puppet::Type.type(:unity_lun).context.type.attributes
  result['luns'] = task.transport.unity_get_collection('lun', attributes.values.map { |v| v[:field_name] })
rescue Exception => e # rubocop:disable Lint/RescueException
  result[:_error] = { msg: e.message,
                      kind: 'timidri-unity/unknown',
                      details: {
                        class: e.class.to_s,
                        backtrace: e.backtrace,
                      } }
end

puts result.to_json
