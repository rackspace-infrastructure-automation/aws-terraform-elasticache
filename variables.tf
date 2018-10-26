###<Common Parameters>###

variable "additional_tags" {
  description = "(memcached, redis, redis multi shard) Additional tags to be added to the Elasticache resources. Please see examples directory in this repo for examples."
  type        = "map"
  default     = {}
}

variable "cache_cluster_port" {
  description = "(memcached, redis, redis multi shard) The port number on which each of the cache nodes will accept connections. Default for redis is 6379. Default for memcached is 11211"
  default     = ""
  type        = "string"
}

variable "cluster_name" {
  description = "(memcached, redis, redis multi shard) Name of Cluster. Will also be used to name other provisioned resources. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints"
  type        = "string"
}

variable "cluster_name_version" {
  description = "(memcached, redis, redis multi shard) NOTE: This needs to increment on update with new snapshot. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints"
  default     = "v00"
  type        = "string"
}

variable "create_route53_record" {
  description = "(memcached, redis, redis multi shard) Specifies whether or not to create a route53 CNAME record for the configuration/primary endpoint. internal_zone_id, internal_zone_name, and internal_record_name must be provided if set to true. true or false."
  default     = false
  type        = "string"
}

variable "elasticache_engine_type" {
  description = "(memcached, redis, redis multi shard) The name of the cache engine to be used for this cluster. Valid values are: memcached14, redis326, redis28, redis40, redis3210, redis32"
  type        = "string"
}

variable "environment" {
  description = "(memcached, redis, redis multi shard) Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test"
  default     = "Development"
  type        = "string"
}

variable "instance_class" {
  description = "(memcached, redis, redis multi shard) The compute and memory capacity of the nodes within the ElastiCache cluster. Please see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/CacheNodes.SupportedTypes.html for valid instance types."
  type        = "string"
}

variable "internal_record_name" {
  description = "(memcached, redis, redis multi shard) Record Name for the new Resource Record in the Internal Hosted Zone"
  default     = ""
  type        = "string"
}

variable "internal_zone_id" {
  description = "(memcached, redis, redis multi shard) The Route53 Internal Hosted Zone ID"
  default     = ""
  type        = "string"
}

variable "internal_zone_name" {
  description = "(memcached, redis, redis multi shard) LD for Internal Hosted Zone"
  default     = ""
  type        = "string"
}

variable "notification_topic" {
  description = "(memcached, redis, redis multi shard) SNS Topic ARN to notify if there are any alarms"
  default     = ""
  type        = "string"
}

variable "preferred_maintenance_window" {
  description = "(memcached, redis, redis multi shard) The weekly time range (in UTC) during which system maintenance can occur. Example: Sun:05:00-Sun:07:00"
  default     = "Sun:05:00-Sun:07:00"
  type        = "string"
}

variable "redis_multi_shard" {
  description = "(edis, redis multi shard) Is this a redis multi-shard instance? true or false"
  default     = false
  type        = "string"
}

variable "security_group_list" {
  description = "(memcached, redis, redis multi shard) A list of EC2 security groups to assign to this resource."
  type        = "list"
}

variable "subnets" {
  description = "(memcached, redis, redis multi shard) List of subnets for use with this cache cluster"
  type        = "list"
}

###<\Common Parameters>###

###<Memcached and Redis non-multi-shard Parameters>###

variable "cpu_high_threshold" {
  description = "(memcached, redis) The max CPU Usage % before generating an alarm."
  default     = 90
  type        = "string"
}

variable "cpu_high_evaluations" {
  description = "(memcached, redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm."
  default     = 5
  type        = "string"
}

variable "curr_connections_evaluations" {
  description = "(memcached, redis) The number of minutes current connections must remain above the specified threshold to generate an alarm."
  default     = 5
  type        = "string"
}

variable "curr_connections_threshold" {
  description = "(memcached, redis) The max number of current connections before generating an alarm. NOTE: If this variable is not set, the connections alarm will not be provisioned."
  default     = ""
  type        = "string"
}

variable "evictions_evaluations" {
  description = "(memcached, redis) The number of minutes Evictions must remain above the specified threshold to generate an alarm."
  default     = 5
  type        = "string"
}

variable "evictions_threshold" {
  description = "(memcached, redis) The max evictions before generating an alarm. NOTE: If this variable is not set, the evictions alarm will not be provisioned."
  default     = ""
  type        = "string"
}

variable "number_of_nodes" {
  description = "(memcached, redis) The number of cache nodes within the ElastiCache cluster"
  default     = 1
  type        = "string"
}

###<\Memcached and Redis non-multi-shard Parameters>###

###<Redis and Redis multi-shard Parameters>###

variable "in_transit_encryption" {
  description = "(redis, redis multi shard) Indicates whether to enable encryption in transit. Because there is some processing needed to encrypt and decrypt the data at the endpoints, enabling in-transit encryption can have some performance impact.ONLY AVAILABLE FOR REDIS 3.2.6 AND 4.0.10. true or false"
  default     = false
  type        = "string"
}

variable "replication_group_description" {
  description = "(redis, redis multi shard) Description of Replication Group"
  default     = "Elasticache"
  type        = "string"
}

variable "snapshot_arn" {
  description = "(redis, redis multi shard) The S3 ARN of a snapshot to use for cluster creation.  Proper access to the S3 file must be granted prior to building instance.  See https://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/backups-seeding-redis.html#backups-seeding-redis-grant-access for details.  This parameter is ignored if a SnapshotName is provided."
  default     = ""
  type        = "string"
}

variable "snapshot_name" {
  description = "(redis, redis multi shard) The name of a snapshot to use for cluster creation. This property overrides any value assigned to SnapshotArn. Snapshots are unsupported on cache.t1.micro and cache.t2.* instance classes."
  default     = ""
  type        = "string"
}

variable "snapshot_window" {
  description = "(redis, redis multi shard) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your node group. Snapshots are unsupported on cache.t1.micro and cache.t2.* instance classes."
  default     = "03:00-05:00"
  type        = "string"
}

variable "at_rest_encrypted_disk" {
  description = "(redis, redis multi shard) Indicates whether to enable encryption at rest. ONLY AVAILABLE FOR REDIS 3.2.6 AND 4.0.10. true or false"
  default     = false
  type        = "string"
}

variable "snapshot_retention_limit" {
  description = "(redis, redis multi shard) The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups. Snapshots are unsupported on cache.t1.micro and cache.t2.* instance classes."
  default     = 7
  type        = "string"
}

###<\Redis and Redis multi-shard Parameters>###

###<Redis non multi shard Parameters>###
variable "failover_enabled" {
  description = "(redis) Enable Multi-AZ Failover.  Failover is unsupported on cache.t2.* instance classes. This is hardcoded as true for Redis multi-shard."
  default     = true
  type        = "string"
}

###<\Redis non multi shard Parameters>###

###<Redis multi shard Parameters>###

variable "number_of_read_replicas_per_shard" {
  description = "(redis multi shard) Number of read replicas per shard"
  default     = 2
  type        = "string"
}

variable "number_of_shards" {
  description = "(redis multi shard) Number of shards"
  default     = 2
  type        = "string"
}

###<\Redis multi shard Parameters>###

###<Memcached Parameters>###

variable "swap_usage_evaluations" {
  description = "(memcached) The number of minutes SwapUsage must remain above the specified threshold to generate an alarm"
  default     = 5
  type        = "string"
}

variable "swap_usage_threshold" {
  description = "(memcached) The max SwapUsage before generating an alarm"
  default     = 52428800
  type        = "string"
}

###<\Memcached Parameters>###

