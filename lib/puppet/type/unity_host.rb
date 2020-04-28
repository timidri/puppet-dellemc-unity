# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'unity_host',
  docs: <<-EOS,
@summary a Unity host type
@example
unity_host { 'N-1':
  ensure => 'present',
}

EOS
  unity_resource_type: 'host',
  features: ['remote_resource'],
  attributes: {
    id: {
      type:       'String',
      desc:       'The host id',
      behaviour:  :namevar,
      field_name: 'id',
    },
    description: {
      type:       'String',
      desc:       'The host description',
      field_name: 'description',
    },
    health: {
      type:       'Hash',
      desc:       'The host health',
      field_name: 'health',
    },
    type: {
      type:       'Integer',
      desc:       'The host type',
      field_name: 'type',
    },
    os_type: {
      type:       'String',
      desc:       'The host OS type',
      field_name: 'osType',
    },
    datastores: {
      type:       'Optional[Array[Hash]]',
      desc:       'The datastores associated with the host.',
      field_name: 'datastores',
    },
    vms: {
      type:      'Optional[Array[Hash]]',
      desc:      'The vms associated with the host.',
      field_name: 'vms',
    },
  },
)
