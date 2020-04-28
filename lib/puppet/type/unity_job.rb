# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'unity_job',
  docs: <<-EOS,
@summary a Unity job type
@example
job { 'N-1':
  ensure => 'present',
}

EOS
  unity_resource_type: 'job',
  features: ['remote_resource'],
  attributes: {
    id: {
      type:       'String',
      desc:       'The job id',
      behaviour:  :namevar,
      field_name: 'id',
    },
    description: {
      type:       'String',
      desc:       'The job description',
      field_name: 'description',
    },
    state: {
      type:       'Integer',
      desc:       'The job state',
      field_name: 'state',
    },
    progress_pct: {
      type:       'Integer',
      desc:       'The progress percentage of the job',
      field_name: 'progressPct',
    },
    message_out: {
      type:       'Hash',
      desc:       'The output message of the job result',
      field_name: 'messageOut',
    },
    affected_resource: {
      type:       'Hash',
      desc:       'The resource primarily affected by the job',
      field_name: 'affectedResource',
    },
    client_data: {
      type:      'String',
      desc:      'The client-specified data',
      field_name: 'clientData',
    },
  },
)
