# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'unity_host',
  docs: <<-EOS,
@summary a Unity host type
@example
unity_host { 'myhost':
  ensure => 'present',
}

EOS
  unity_resource_type: 'host',
  features: ['remote_resource'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    id: {
      type:       'String',
      desc:       'The host id',
      behaviour:  :read_only,
      field_name: 'id',
    },
    name: {
      type:       'String',
      desc:       'The host name',
      behaviour:  :namevar,
      field_name: 'name',
    },
    description: {
      type:       'Optional[String]',
      desc:       'The host description',
      field_name: 'description',
    },
    health: {
      type:       'Hash',
      desc:       'The host health',
      behaviour:  :read_only,
      field_name: 'health',
    },
    type: {
      type:       'Integer',
      desc:       'The host type',
      behaviour:  :init_only,
      field_name: 'type',
    },
    os_type: {
      type:       'Optional[String]',
      desc:       'The host OS type',
      field_name: 'osType',
    },
    datastores: {
      type:       'Optional[Array[Hash]]',
      desc:       'The datastores associated with the host.',
      behaviour:  :read_only,
      field_name: 'datastores',
    },
    vms: {
      type:      'Optional[Array[Hash]]',
      desc:      'The vms associated with the host.',
      behaviour:  :read_only,
      field_name: 'vms',
    },
  },
)
