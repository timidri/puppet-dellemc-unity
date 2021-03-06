#!/opt/puppetlabs/puppet/bin/ruby
require_relative '../lib/puppet/util/task_helper'

class DeleteLunTask < TaskHelper
  def task(lun_id:, **kwargs)

    result = {}
    begin
      result['response'] = transport.delete_lun(lun_id)
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
    DeleteLunTask.run
  end

end