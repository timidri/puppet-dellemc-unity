#!/opt/puppetlabs/puppet/bin/ruby
require 'pry'
require_relative '../lib/puppet/util/task_helper'
require_relative '../lib/puppet/type/unity_job'
task = Puppet::Util::TaskHelper.new('unity')
result = {}

begin
  # we are loading the type here and use the :field_name attribute
  # to determine which fields we want to request from the API
  attributes = Puppet::Type.type(:unity_job).context.type.attributes
  result['jobs'] = task.transport.unity_get_instances('job', attributes.values.map { |v| v[:field_name] } )

rescue Exception => e # rubocop:disable Lint/RescueException
  result[:_error] = { msg: e.message,
                      kind: 'timidri-unity/unknown',
                      details: {
                        class: e.class.to_s,
                        backtrace: e.backtrace,
                      } }
end

puts result.to_json
