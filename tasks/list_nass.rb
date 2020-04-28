#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'

class ListNassTask < TaskHelper

  def task(params)
    result = {}

    begin
      result['nass'] = transport.unity_get_collection('nasServer', transport.fields_for_type('nas'))
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
    ListNassTask.run
  end

end