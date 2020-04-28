#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'

class CreateVvolTask < TaskHelper

  def task(name:, cap_profile_id:, size:, **kwargs)
    result = {}

    begin
      result['response'] = transport.create_vvol(name, cap_profile_id, size)
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
    CreateVvolTask.run
  end

end