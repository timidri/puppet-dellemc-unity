#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'

class ListLunsTask < TaskHelper

  def task(params)
    result = {}
    begin
      result['luns'] = transport.unity_get_collection('lun')
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
    ListLunsTask.run
  end

end
