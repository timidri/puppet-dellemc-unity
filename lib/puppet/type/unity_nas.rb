# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'unity_nas',
  docs: <<-EOS,
@summary a Unity nas server 
@example
unity_nas { 'N-1':
  ensure => 'present',
}

EOS
  features: ['remote_resource'],
  attributes: {
    id: {
        field_name: 'id',
        behaviour:  :namevar,
        type: 'String',
        desc: 'Unique identifier of the nasServer instance.',
    },
    current_sp: {
        field_name: 'currentSP',
        type: 'Hash',
        desc: 'Storage Processor on which the NAS server is currently running.',
    },
    name: {
        field_name: 'name',
        type: 'String',
        desc: 'User-specified name of the NAS server.',
    },
    is_replicated_enabled: {
        field_name: 'isReplicationEnabled',
        type: 'Boolean',
        desc: "Indicates whether a replication session is enabled for the NAS server.  The NAS server can't be deleted while replication session is enabled.  Values are:  <ul>  <li> true - Replication session is enabled. </li>  <li> false - Replication session is disabled. </li>  </ul>",
    },
    pool: {
        field_name: 'pool',
        type: 'Hash',
        desc: "Storage pool that stores the NAS server's configuration metadata, as defined by the pool resource type.",
    },
    default_unix_user: {
        field_name: 'defaultUnixUser',
        type: 'Optional[String]',
        desc: 'Default Unix user name to use for an unmapped Windows user. This value only applies when the value of allowUnmappedUser is true.',
    },
    file_interface: {
        field_name: 'fileInterface',
        type: 'Array[Hash]',
        desc: 'The fileInterfaces associated with the current nasServer',
    },
    current_unix_directory_service: {
        field_name: 'currentUnixDirectoryService',
        type: 'Integer',
        desc: 'Unix Directory Service used to look up users and hosts.',
    },
    data_reduction_size_saved: {
        field_name: 'dataReductionSizeSaved',
        type: 'Optional[Integer]',
        desc: 'Storage element saved space by data reduction, which includes savings from compression, deduplication  and advanced deduplication.',
    },
    file_space_used: {
        field_name: 'fileSpaceUsed',
        type: 'Integer',
        desc: "File systems' space used.",
    },
    compression_size_saved: {
        field_name: 'compressionSizeSaved',
        type: 'Optional[Integer]',
        desc: 'Storage element saved space by compression. This attribute is obsolete and will be removed in a future release. Please use nasServer.dataReductionSizeSaved instead.',
    },
    default_windows_user: {
        field_name: 'defaultWindowsUser',
        type: 'Optional[String]',
        desc: 'Default Windows user name to use for an unmapped Unix user. This value only applies when the value of allowUnmappedUser is true.',
    },
    virus_checker: {
        field_name: 'virusChecker',
        type: 'Hash',
        desc: 'The virusChecker associated with the current nasServer',
    },
    nfs_server: {
        field_name: 'nfsServer',
        type: 'Hash',
        desc: 'The nfsServer associated with the current nasServer',
    },
    allow_unmapped_user: {
        field_name: 'allowUnmappedUser',
        type: 'Optional[Boolean]',
        desc: 'Indicates whether an unmappped user can access the NAS server as a default user.  Values are:  <ul>  <li> true - Allow access for unmapped users. </li>  <li> false - Disallow access for unmapped users. </li>  </ul>',
    },
    sync_replication_type: {
        field_name: 'syncReplicationType',
        type: 'Integer',
        desc: 'Sync Replication type.',
    },
    event_publisher: {
        field_name: 'eventPublisher',
        type: 'Hash',
        desc: 'The fileEventsPublisher associated with the current nasServer',
    },
    filesystems: {
        field_name: 'filesystems',
        type: 'Optional[Array[Hash]]',
        desc: 'The filesystems associated with the current nasServer',
    },
    is_replication_destination: {
        field_name: 'isReplicationDestination',
        type: 'Boolean',
        desc: 'Indicates whether the NAS server is a replication destination.  Values are:  <ul>  <li>true - NAS server is a replication destination.</li>  <li>false - NAS server is a not a replication destination.</li>  </ul>',
    },
    is_multiprotocol_enabled: {
        field_name: 'isMultiProtocolEnabled',
        type: 'Boolean',
        desc: 'Indicates whether multiprotocol sharing mode is enabled.   This mode enables simultaneous file access for Windows and Unix users.   Values are:  <ul>  <li> true - Multiprotocol sharing mode is enabled. </li>  <li> false - Multiprotocol sharing mode is disabled. </li>  </ul>',
    },
    file_dns_server: {
        field_name: 'fileDNSServer',
        type: 'Optional[Hash]',
        desc: 'The fileDNSServer associated with the current nasServer',
    },
    replication_type: {
        field_name: 'replicationType',
        type: 'Integer',
        desc: 'Replication type.',
    },
    data_reduction_ration: {
        field_name: 'dataReductionRatio',
        type: 'Optional[Float]',
        desc: 'Data reduction ratio.  The data reduction ratio is the ratio between the size of the data and the amount of storage actually consumed.   For example,
        TB of data consuming 250GB would have a ration of 4:1. A 4: 1 data reduction ratio is equivalent to a 75% data reduction percentage.',
    },
    compression_ratio: {
        field_name: 'compressionRatio',
        type: 'Optional[Float]',
        desc: 'Compression ratio. This attribute is obsolete and will be removed in a future release. Please use nasServer.dataReductionRatio instead.',
    },
    is_packet_reflect_enabled: {
        field_name: 'isPacketReflectEnabled',
        type: 'Boolean',
        desc: 'Indicates whether the reflection of outbound (reply) packets through the same  interface that inbound (request) packets entered is enabled.  Values are:  <ul>  <li> true - (Default) Packet Reflect is enabled. </li>  <li> false - Packet Reflect is disabled. </li>  </ul>',
    },
    data_reduction_percent: {
        field_name: 'dataReductionPercent',
        type: 'Optional[Integer]',
        desc: 'Data reduction percentage is the percentage of the data that does not consume storage - the savings due to data reduction.   For example, if 1 TB of data is stored in 250 GB, the data reduction percentage is 75%. 75% data reduction percentage is equivalent   to a 4: 1 data reduction ratio.',
    },
    compression_percent: {
        field_name: 'compressionPercent',
        type: 'Optional[Integer]',
        desc: 'Percent compression. This attribute is obsolete and will be removed in a future release. Please use nasServer.dataReductionPercent instead.',
    },
    cifs_server: {
        field_name: 'cifsServer',
        type: 'Optional[Array[Hash]]',
        desc: 'The cifsServers associated with the current nasServer',
    },
    tenant: {
        field_name: 'tenant',
        type: 'Optional[Hash]',
        desc: 'Tenant to which the NAS Server belongs.',
    },
    size_allocated: {
        field_name: 'sizeAllocated',
        type: 'Integer',
        desc: 'Amount of storage pool space used for NAS server configuration.',
    },
    is_migration_destination: {
        field_name: 'isMigrationDestination',
        type: 'Boolean',
        desc: "Indicates whether the NAS server is a migration destination. It can't be modified by client.  Values are:  <ul>  <li>true - NAS server is a migration destination.</li>  <li>false - NAS server is a not a migration destination.</li>  </ul>",
    },
    is_backup_only: {
        field_name: 'isBackupOnly',
        type: 'Boolean',
        desc: 'Indicates whether the NAS server is used as backup only. Only a replication destination can be set as backup.  Values are:  <ul>  <li>true - NAS server acts as backup only.</li>  <li>false - Normal NAS server.</li>  </ul>',
    },
    home_sp: {
        field_name: 'homeSP',
        type: 'Hash',
        desc: 'Storage Processor on which the NAS Server is intended to run.',
    },
    health: {
        field_name: 'health',
        type: 'Hash',
        desc: 'Health information for the NAS server, as defined by the health resource type.',
    },
    is_windows_to_unix_username_mapping_enabled: {
        field_name: 'isWindowsToUnixUsernameMappingEnabled',
        type: 'Optional[Boolean]',
        desc: 'Indicates whether a Unix to/from Windows user name mapping is enabled.  Values are:  <ul>  <li> true - Unix to/from Windows user name mapping is enabled. </li>  <li> false - Unix to/from Windows user name mapping is disabled. </li>  </ul>',
    },
    preferred_interface_settings: {
        field_name: 'preferredInterfaceSettings',
        type: 'Hash',
        desc: 'The preferredInterfaceSettings associated with the current nasServer',
    },
  },
)
