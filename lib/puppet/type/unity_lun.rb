# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'unity_lun',
  docs: <<-EOS,
@summary a Unity lun type
@example
unity_lun { 'mylun':
  ensure  => 'present',
  size    => '1GB',
  pool_id => 'pool_1',
}

EOS
  unity_resource_type: 'lun',
  unity_resource_type_cud: 'storageResource',
  create_endpoint: 'types/storageResource/action/createLun',
  update_endpoint: 'instances/storageResource/name:%{name}/action/modifyLun',
  features: ['remote_resource'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    name: {
        type:       'String',
        desc:       'The lun name',
        behaviour:  :namevar,
        field_name: 'name',
      },
    id: {
      type:       'String',
      desc:       'The lun id',
      behaviour:  :read_only,
      field_name: 'id',
    },
    health: {
      type:       'Hash',
      desc:       'The lun health',
      behaviour:  :read_only,
      field_name: 'health',
    },
    description: {
      type:       'Optional[String]',
      desc:       'The lun description',
      field_name: 'description',
    },
    type: {
      type:       'Optional[Integer]',
      desc:       'The lun type',
      field_name: 'type',
    },
    pool: {
      type:       'Hash',
      desc:       'The pool the lun is defined on',
      behaviour:  :init_only,
      field_name: 'pool',
    },
    size_total: {
      type:       'Integer',
      desc:       'LUN size that the system presents to the host or end user.',
      field_name: 'sizeTotal',
    },
    size_allocated: {
      type:       'Integer',
      desc: <<-EOS,
Size of space actually allocated in the pool for the LUN:
For thin-provisioned LUNs this as a rule is less than the sizeTotal attribute until the LUN is not fully populated with user data.
For not thin-provisioned LUNs this is approximately equal to the sizeTotal.
EOS
      behaviour:  :read_only,
      field_name: 'sizeAllocated',
    },
    is_thin_enabled: {
      type:       'Boolean',
      desc:       'The total size of the lun',
      default:    true,
      behaviour:  :init_only,
      field_name: 'isThinEnabled',
    },
  },
)
