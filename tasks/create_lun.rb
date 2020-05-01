#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'

class CreateLunTask < TaskHelper

  def task(name:, description:nil, pool_id:, size:, is_thin_enabled: true, **kwargs)
    result = {}

    begin
      result['response'] = transport.create_lun(name, description, pool_id, size, is_thin_enabled)
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
    CreateLunTask.run
  end

end