#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'

class ListPoolsTask < TaskHelper

  def task(params)
    result = {}
    begin
      result['pools'] = transport.unity_get_collection('pool')
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
    ListPoolsTask.run
  end

end