# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'job',
  docs: <<-EOS,
@summary a job type
@example
job { 'N-1':
  ensure => 'present',
}

EOS
  features: ['remote_resource'],
  attributes: {
    id: {
      type:      'String',
      desc:      'The job id',
      behaviour: :namevar,
    },
    description: {
      type:      'String',
      desc:      'The job description',
    },
    state: {
      type:      'Integer',
      desc:      'The job state',
    },
    progress_pct: {
      type:      'Integer',
      desc:      'The progress percentage of the job',
    },
    message_out: {
      type:      'Hash',
      desc:      'The output message of the job result',
    },
    affected_resource: {
      type:      'Hash',
      desc:      'The resource primarily affected by the job',
    },
    client_data: {
      type:      'String',
      desc:      'The client-specified data',
    },
  },
)
