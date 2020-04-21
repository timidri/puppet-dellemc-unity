# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'unity_pool',
  docs: <<-EOS,
@summary a Unity lun pool 
@example
unity_pool { 'N-1':
  ensure => 'present',
}

EOS
  features: ['remote_resource'],
  attributes: {
    data_reduction_ratio: {
        field_name: 'dataReductionRatio',
        type:       'Optional[Float]',
        desc:       'Data reduction ratio.  The data reduction ratio is the ratio between the size of the data and the amount of storage actually consumed.   For example, 1TB of data consuming 250GB would have a ration of 4:1. A 4:1 data reduction ratio is equivalent to a 75% data reduction percentage.'
    },
    id: {
        field_name: 'id',
        behaviour:  :namevar,
        type:       'String',
        desc:       'Unique identifier of the pool instance.'
    },
    data_reduction_size_saved: {
        field_name: 'dataReductionSizeSaved',
        type:       'Optional[Integer]',
        desc:       'Amount of space saved for the pool by data reduction (includes savings from compression, deduplication and advanced deduplication).'
    },
    size_total: {
        field_name: 'sizeTotal',
        type:       'Integer',
        desc:       'The total size of space from the pool, which will be the sum of sizeFree, sizeUsed and   sizePreallocated space.'
    },
    compress_ratio: {
        field_name: 'compressionRatio',
        type:       'Optional[Float]',
        desc:       'compression ratio. This attribute is obsolete and will be removed in a future release. Please use pool.dataReductionRatio instead.'
    },
    has_compression_enabled_fs: {
        field_name: 'hasCompressionEnabledFs',
        type:       'Optional[Boolean]',
        desc:       '(Applies if Inline Compression is supported on the system and the corresponding license is installed.)  Indicates whether the pool has any File System that has inline compression ever turned on; Values are.  <ul>  <li>true -  File system(s) in this pool have had or currently have inline compression enabled.</li>  <li>false - No file system(s) in this pool have ever had inline compression enabled.</li>  </ul> This attribute is obsolete and will be removed in a future release. Please use pool.hasDataReductionEnabledFs instead.'
    },
    creation_time: {
        field_name: 'creationTime',
        type:       "String",
        desc:       'Date and time when the pool was created.'
    },
    tiers: {
        field_name: 'tiers',
        type:       'Array[Hash]',
        desc:       'Tiers in the pool, as defined by the poolTier resource type.'
    },
    has_data_reduction_enabled_luns: {
        field_name: 'hasDataReductionEnabledLuns',
        type:       'Optional[Boolean]',
        desc:       '(Applies if Data Reduction is supported on the system and the corresponding license is installed.)  Indicates whether the pool has any Lun that has data reduction ever turned on; Values are:  <ul>  <li>true -  Lun(s) in this pool have had or currently have data reduction enabled.</li>  <li>false - No lun(s) in this pool have ever had data reduction enabled.</li>  </ul>'
    },
    alert_threshold: {
        field_name: 'alertThreshold',
        type:       'Integer',
        desc:       'Threshold at which the system generates notifications about the size of  free space in the pool, specified as a percentage.  <p/>  This threshold is based on the percentage of allocated storage in the pool  compared to the total pool size.'
    },
    rebalance_progress: {
        field_name: 'rebalanceProgress',
        type:       'Optional[Integer]',
        desc:       '(Applies if FAST VP is supported on the system and the corresponding license is installed.)  Percent of work completed for data rebalancing.'
    },
    metadata_size_subscribed: {
        field_name: 'metadataSizeSubscribed',
        type:      'Integer',
        desc:      'Size of pool space subscribed for metadata.'
    },
    snap_size_subscribed: {
        field_name: 'snapSizeSubscribed',
        type:       'Integer',
        desc:       'Size of pool space subscribed for snapshots.'
    },
    type: {
        field_name: 'type',
        type:       'Integer',
        desc:       'Indicates type of this pool. Values are:  <ul>  <li>Dynamic - It is dynamic pool.</li>  <li>Traditional - It is traditional pool.</li>  </ul>'
    },
    is_all_flash: {
        field_name: 'isAllFlash',
        type:       'Boolean',
        desc:       'Indicates whether this pool contains only Flash drives. Values are:  <ul>  <li>true - It is an all Flash pool.</li>  <li>false - This pool contains drives other than Flash drives.</li>  </ul>'
    },
    metadata_size_used: {
        field_name: 'metadataSizeUsed',
        type:       'Integer',
        desc:       'Size of pool space used by metadata.'
    },
    non_base_size_used: {
        field_name: 'nonBaseSizeUsed',
        type:       'Integer',
        desc:       'Size of pool space used for thin clones and snapshots'
    },
    snap_size_used: {
        field_name: 'snapSizeUsed',
        type:       'Integer',
        desc:       'Size of pool space used by snapshots.'
    },
    non_base_size_subscribed: {
        field_name: 'nonBaseSizeSubscribed',
        type:       'Integer',
        desc:       'Size of pool space subscribed for thin clones and snapshots'
    },
    size_used: {
        field_name: 'sizeUsed',
        type:       'Integer',
        desc:       'Space allocated from the pool by storage resources, used for storing data.   This will be the sum of the sizeAllocated values of each storage resource in the pool.'
    },
    is_harvest_enabled: {
        field_name: 'isHarvestEnabled',
        type:       'Boolean',
        desc:       'Indicates whether the automatic deletion of snapshots through pool space harvesting  is enabled for the pool. See properties poolSpaceHarvestHighThreshold and poolSpaceHarvestLowThreshold.  Values are:  <ul>  <li>true - Automatic deletion of snapshots through pool harvesting is enabled  for the pool.</li>  <li>false - Automatic deletion of snapshots through pool harvesting is  disabled for the pool.</li>  </ul>'
    },
    size_preallocated: {
        field_name: 'sizePreallocated',
        type:       'Integer',
        desc:       'Space reserved form the pool by storage resources, for future needs to make writes more efficient.  The pool may be able to reclaim some of this if space is running low. This will be the sum of the   sizePreallocated values of each storage resource in the pool.'
    },
    snap_space_harvest_low_threshold: {
        field_name: 'snapSpaceHarvestLowThreshold',
        type:       'Float',
        desc:       "(Applies when the automatic deletion of snapshots based on snapshot space  usage is enabled for the system and pool.)  <br/>  <br/>  Space used by snapshot objects low threshold under which the system automatically stops  deleting snapshots in the pool, specified as a percentage with .01% granularity.  <br/>  <br/>  This threshold is based on the percentage of space used in the pool by snapshots only  compared to the total pool size. When the percentage of pool space used by  snapshot objects falls below this threshold, the system automatically stops deletion  of snapshots in the pool, until a high threshold (see snapSpaceHarvestHighThreshold) is reached again.  Note that if Base LUN has Thin Clones its snapshot space doesn't affect this threshold."
    },
    name: {
        field_name: 'name',
        type:       'String',
        desc:       'Pool name, unique in the storage system.'
    },
    data_reduction_percent: {
        field_name: 'dataReductionPercent',
        type:       'Optional[Integer]',
        desc:       'Data reduction percentage is the percentage of the data that does not consume storage - the savings due to data reduction.   For example, if 1 TB of data is stored in 250 GB, the data reduction percentage is 75%. 75% data reduction percentage is equivalent   to a 4:1 data reduction ratio.'
    },
    is_fast_cache_enabled: {
        field_name: 'isFASTCacheEnabled',
        type:       'Boolean',
        desc:       '(Applies if FAST Cache is supported on the system and the corresponding license is installed.)  Indicates whether the FAST Cache is enabled for the pool. Values are:  <ul>  <li>true - FAST Cache is enabled for the pool.</li>  <li>false - FAST Cache is disabled for the pool.</li>  FAST Cache is created from Flash SAS drives and applied only to RAID groups created of SAS and NL-SAS hard drives.  If the pool is populated by purely Flash drives the FAST Cache is not enabled.  </ul>'
    },
    is_snap_harvest_enabled: {
        field_name: 'isSnapHarvestEnabled',
        type:       'Boolean',
        desc:       'Indicates whether the automatic deletion of snapshots through snapshot  harvesting is enabled for the pool. See properties snapSpaceHarvestHighThreshold and snapSpaceHarvestLowThreshold.  Values are:  <ul>  <li>true - Automatic deletion of snapshots through snapshot harvesting is  enabled for the pool.</li>  <li>false - Automatic deletion of snapshots through snapshot harvesting is  disabled for the pool.</li>  </ul>'
    },
    has_data_reduction_enabled_fs: {
        field_name: 'hasDataReductionEnabledFs',
        type:       'Optional[Boolean]',
        desc:       '(Applies if Data Reduction is supported on the system and the corresponding license is installed.)  Indicates whether the pool has any File System that has data reduction ever turned on; Values are.  <ul>  <li>true -  File system(s) in this pool have had or currently have data reduction enabled.</li>  <li>false - No file system(s) in this pool have ever had data reduction enabled.</li>  </ul>'
    },
    raid_type: {
        field_name: 'raidType',
        type:       'Optional[Integer]',
        desc:       'RAID type with which the pool is configured. A value of Mixed indicates that  the pool consists of multiple RAID types.'
    },
    size_subscribed: {
        field_name: 'sizeSubscribed',
        type:       'Integer',
        desc:       'Size of space requested by the storage resources allocated in the pool for possible future allocations.   If this value is greater than the total size of the pool, the pool is considered oversubscribed.'
    },
    has_compression_enabled_luns: {
        field_name: 'hasCompressionEnabledLuns',
        type:       'Optional[Boolean]',
        desc:       '(Applies if Inline Compression is supported on the system and the corresponding license is installed.)  Indicates whether the pool has any Lun that has inline compression ever turned on; Values are:  <ul>  <li>true -  Lun(s) in this pool have had or currently have inline compression enabled.</li>  <li>false - No lun(s) in this pool have ever had inline compression enabled.</li>  </ul> This attribute is obsolete and will be removed in a future release. Please use pool.hasDataReductionEnabledLuns instead.'
    },
    pool_space_harvest_high_threshold: {
        field_name: 'poolSpaceHarvestHighThreshold',
        type:       'Float',
        desc:       '(Applies when the automatic deletion of snapshots based on pool space usage is  enabled for the system and pool.)  <br/>  <br/>  Pool used space high threshold at which the system automatically starts to delete  snapshot objects in the pool, specified as a percentage with .01% granularity.  <br/>  <br/>  This threshold is based on the percentage of space used in the pool by all types of objects compared  to the total pool size. When the percentage of used space reaches this  threshold, the system starts to automatically delete snapshot objects in the pool, until a low  threshold (see poolSpaceHarvestLowThreshold) is reached.'
    },
    description: {
        field_name: 'description',
        type:       'String',
        desc:       'Pool description.'
    },
    is_empty: {
        field_name: 'isEmpty',
        type:       'Boolean',
        desc:       'Indicates whether the pool is unused; that is, whether it has no storage  resources provisioned from it. Values are:  <ul>  <li>true - Pool is unused. </li>  <li>false - Pool is used..</li>  </ul>'
    },
    size_free: {
        field_name: 'sizeFree',
        type:       'Integer',
        desc:       'Size of free space available in the pool.'
    },
    snap_space_harvest_high_threshold: {
        field_name: 'snapSpaceHarvestHighThreshold',
        type:       'Float',
        desc:       "(Applies when the automatic deletion of snapshots based on snapshot space  usage is enabled for the system and pool.)  <br/>  <br/>  Space used by snapshot objects high threshold at which the system automatically starts to delete  snapshot objects in the pool, specified as a percentage with .01% granularity.  <br/>  <br/>  This threshold is based on the percentage of space used in the pool by snapshot objects only  compared to the total pool size. When the percentage of space used by snapshots  reaches this threshold, the system automatically starts to delete snapshots in the pool,  until a low threshold (see snapSpaceHarvestLowThreshold) is reached.  Note that if Base LUN has Thin Clones its snapshot space doesn't affect this threshold."
    },
    compression_percent: {
        field_name: 'compressionPercent',
        type:       'Optional[Integer]',
        desc:       'Percent compression rate. This attribute is obsolete and will be removed in a future release. Please use pool.dataReductionPercent instead.'
    },
    compression_size_saved: {
        field_name: 'compressionSizeSaved',
        type:       'Optional[Integer]',
        desc:       'Amount of space saved for the pool by inline compression. This attribute is obsolete and will be removed in a future release. Please use pool.dataReductionSizeSaved instead.'
    },
    pool_space_harvest_low_threshold: {
        field_name: 'poolSpaceHarvestLowThreshold',
        type:       'Float',
        desc:       '(Applies when the automatic deletion of snapshots based on pool space usage is  enabled for the system and pool.)  <br/>  <br/>  Pool used space low threshold under which the system stops automatically  deleting snapshots in the pool, specified as a percentage with .01% granularity.  <br/>  <br/>  This threshold is based on the percentage of space used in the pool by all types of objects compared to the  total pool size. When the percentage of used space in the pool falls below this  threshold, the system stops the automatic deletion of snapshot objects in the pool,  until a high threshold (see poolSpaceHarvestHighThreshold) is reached again.'
    },
    harvest_state: {
        field_name: 'harvestState',
        type:       'Integer',
        desc:       'Current state of pool space harvesting.'
    },
    pool_fast_vp: {
        field_name: 'poolFastVP',
        type:       'Hash',
        desc:       '(Applies if FAST VP is supported on the system and the corresponding license is installed.)  FAST VP information for the pool, as defined by the poolFastVP resource type.  Pool is not eligible to be a multi-tier pool until FAST VP license installed.'
    },
    health: {
        field_name: 'health',
        type:       'Hash',
        desc:       'Health information for the pool, as defined by the health resource type.'
    },
  },
)