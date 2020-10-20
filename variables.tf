variable "at_rest_encrypted_disk" {
  description = "(redis, redis multi shard) Indicates whether to enable encryption at rest. ONLY AVAILABLE FOR REDIS 3.2.6, 4.0.10 AND 5.0.0. `true` or `false`."
  type        = bool
  default     = false
}

variable "authentication_token" {
  description = "(redis, redis multi shard) The password used to access a password protected server. Can be specified only if `in_transit_encryption = true` and will be ignored otherwise"
  type        = string
  default     = ""
}

variable "cache_cluster_port" {
  description = "(memcached, redis, redis multi shard) The port number on which each of the cache nodes will accept connections. Default for redis is 6379. Default for memcached is 11211"
  type        = string
  default     = ""
}

variable "cpu_high_evaluations" {
  description = "(memcached, redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm."
  type        = number
  default     = 5
}

variable "cpu_high_threshold" {
  description = "(memcached, redis) The max CPU Usage % before generating an alarm."
  type        = number
  default     = 90
}

variable "create_internal_zone_record" {
  description = "(memcached, redis, redis multi shard) Specifies whether or not to create a route53 CNAME record for the configuration/primary endpoint. internal_zone_id, internal_zone_name, and internal_record_name must be provided if set to true. true or false."
  type        = bool
  default     = false
}

variable "curr_connections_evaluations" {
  description = "(memcached, redis) The number of minutes current connections must remain above the specified threshold to generate an alarm."
  type        = number
  default     = 5
}

variable "curr_connections_threshold" {
  description = "(memcached, redis) The max number of current connections before generating an alarm. NOTE: If this variable is not set, the connections alarm will not be provisioned."
  type        = string
  default     = ""
}

variable "elasticache_engine_type" {
  description = "(memcached, redis, redis multi shard) The name of the cache engine to be used for this cluster. Valid values are: memcached14, memcached1510, memcached1516, redis28, redis2823, redis2822, redis2821, redis2819, redis286, redis32, redis326, redis3210, redis40, redis50, redis503, redis504, redis505, redis506"
  type        = string
}

variable "environment" {
  description = "(memcached, redis, redis multi shard) Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test"
  type        = string
  default     = "Development"
}

variable "evictions_evaluations" {
  description = "(memcached, redis) The number of minutes Evictions must remain above the specified threshold to generate an alarm."
  type        = number
  default     = 5
}

variable "evictions_threshold" {
  description = "(memcached, redis) The max evictions before generating an alarm. NOTE: If this variable is not set, the evictions alarm will not be provisioned."
  type        = string
  default     = ""
}

variable "failover_enabled" {
  description = "(redis) Enable Multi-AZ Failover. Failover is unsupported on the cache.t1.micro instance class. This is hardcoded as true for Redis multi-shard."
  type        = bool
  default     = true
}

variable "in_transit_encryption" {
  description = "(redis, redis multi shard) Indicates whether to enable encryption in transit. Because there is some processing needed to encrypt and decrypt the data at the endpoints, enabling in-transit encryption can have some performance impact.ONLY AVAILABLE FOR REDIS 3.2.6, 4.0.10 and later. true or false"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "(memcached, redis, redis multi shard) The compute and memory capacity of the nodes within the ElastiCache cluster. Please see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/CacheNodes.SupportedTypes.html for valid instance types."
  type        = string
}

variable "internal_record_name" {
  description = "(memcached, redis, redis multi shard) Record Name for the new Resource Record in the Internal Hosted Zone"
  type        = string
  default     = ""
}

variable "internal_zone_id" {
  description = "(memcached, redis, redis multi shard) The Route53 Internal Hosted Zone ID"
  type        = string
  default     = ""
}

variable "internal_zone_name" {
  description = "(memcached, redis, redis multi shard) LD for Internal Hosted Zone"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "(memcached, redis, redis multi shard) Name of the Cluster. Will also be used to name other provisioned resources. If this value is empty, `name` and `name_version` will be used for backwards compatibility. Should not exceed 50 characters due to string length constraints. NOTICE: Cluster Name allows 50 characters MAX."
  type        = string
  default     = ""
}

variable "replication_group_name" {
  description = "(memcached, redis, redis multi shard) Name of the Cluster replication group ID, must be unique. If this value is empty, `name` and `name_version` will be used for backwards compatibility. Should not exceed 40 characters due to string length constraints. NOTICE: Group ID allows 40 characters MAX."
  type        = string
  default     = ""
}

variable "name" {
  description = "DEPRECATED, MAY REMOVE IN A FUTURE VERSION, USE `cluster_name` AND `replication_group_name`!! (memcached, redis, redis multi shard) Name of Cluster. Will also be used to name other provisioned resources. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints"
  type        = string
}

variable "name_version" {
  description = "DEPRECATED, MAY REMOVE IN A FUTURE VERSION, USE `cluster_name` AND `replication_group_name`!! (memcached, redis, redis multi shard) NOTE: This needs to increment on update with new snapshot. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints"
  type        = string
  default     = "v00"
}

variable "notification_topic" {
  description = "(memcached, redis, redis multi shard) SNS Topic ARN to notify if there are any alarms"
  type        = string
  default     = ""
}

variable "number_of_nodes" {
  description = "(memcached, redis) The number of cache nodes within the ElastiCache cluster. This number must be grearter or equal 2 to enable automatic failover."
  type        = number
  default     = 1
}

variable "number_of_read_replicas_per_shard" {
  description = "(redis multi shard) Number of read replicas per shard"
  type        = number
  default     = 2
}

variable "number_of_shards" {
  description = "(redis multi shard) Number of shards"
  type        = number
  default     = 2
}

variable "preferred_maintenance_window" {
  description = "(memcached, redis, redis multi shard) The weekly time range (in UTC) during which system maintenance can occur. Example: Sun:05:00-Sun:07:00"
  type        = string
  default     = "Sun:05:00-Sun:07:00"
}

variable "redis_multi_shard" {
  description = "(edis, redis multi shard) Is this a redis multi-shard instance? true or false"
  type        = bool
  default     = false
}

variable "replication_group_description" {
  description = "(redis, redis multi shard) Description of Replication Group"
  type        = string
  default     = "Elasticache"
}

variable "security_groups" {
  description = "(memcached, redis, redis multi shard) A list of EC2 security groups to assign to this resource."
  type        = list(string)
}

variable "snapshot_arn" {
  description = "(redis, redis multi shard) The S3 ARN of a snapshot to use for cluster creation.  Proper access to the S3 file must be granted prior to building instance.  See https://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/backups-seeding-redis.html#backups-seeding-redis-grant-access for details.  This parameter is ignored if a SnapshotName is provided."
  type        = string
  default     = ""
}

variable "snapshot_name" {
  description = "(redis, redis multi shard) The name of a snapshot to use for cluster creation. This property overrides any value assigned to SnapshotArn. Snapshots are unsupported on cache.t1.micro instance class."
  type        = string
  default     = ""
}

variable "snapshot_retention_limit" {
  description = "(redis, redis multi shard) The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups. Snapshots are unsupported on cache.t1.micro instance class."
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "(redis, redis multi shard) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your node group. Snapshots are unsupported on cache.t1.micro instance class."
  type        = string
  default     = "03:00-05:00"
}

variable "subnets" {
  description = "(memcached, redis, redis multi shard) List of subnets for use with this cache cluster"
  type        = list(string)
}

variable "swap_usage_evaluations" {
  description = "(memcached) The number of minutes SwapUsage must remain above the specified threshold to generate an alarm"
  type        = number
  default     = 5
}

variable "swap_usage_threshold" {
  description = "(memcached) The max SwapUsage before generating an alarm"
  type        = number
  default     = 52428800
}

variable "tags" {
  description = "(memcached, redis, redis multi shard) Additional tags to be added to the Elasticache resources. Please see examples directory in this repo for examples."
  type        = map(string)
  default     = {}
}
