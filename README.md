# aws-terraform-elasticache

This module creates Elasticache-Memcached, Elasticache-Redis, or Elasticache-Redis Multi-Shard instances.

## Basic Usage

```
module "elasticache_memcached" {
  source                     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.0.1"
  cluster_name               = "test-memcached"
  cluster_name_version       = ""
  elasticache_engine_type    = "memcached14"
  subnets                    = ["${module.vpc.private_subnets}"]
  security_group_list        = ["${module.security_groups.elastic_cache_memcache_security_group_id}"]
  evictions_threshold        = 10
  curr_connections_threshold = 500
  internal_record_name       = "memcachedconfig"
  create_route53_record      = true
  internal_zone_id           = "${module.internal_zone.internal_hosted_zone_id}"
  internal_zone_name         = "${module.internal_zone.internal_hosted_name}"
}
```
Full working references are available at [examples](examples)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tags | (memcached, redis, redis multi shard) Additional tags to be added to the Elasticache resources. Please see examples directory in this repo for examples. | map | `<map>` | no |
| at_rest_encrypted_disk | (redis, redis multi shard) Indicates whether to enable encryption at rest. ONLY AVAILABLE FOR REDIS 3.2.6 AND 4.0.10. true or false | string | `false` | no |
| cache_cluster_port | (memcached, redis, redis multi shard) The port number on which each of the cache nodes will accept connections. Default for redis is 6379. Default for memcached is 11211 | string | `` | no |
| cluster_name | (memcached, redis, redis multi shard) Name of Cluster. Will also be used to name other provisioned resources. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints | string | - | yes |
| cluster_name_version | (memcached, redis, redis multi shard) NOTE: This needs to increment on update with new snapshot. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints | string | `v00` | no |
| cpu_high_evaluations | (memcached, redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm. | string | `5` | no |
| cpu_high_threshold | (memcached, redis) The max CPU Usage % before generating an alarm. | string | `90` | no |
| create_route53_record | (memcached, redis, redis multi shard) Specifies whether or not to create a route53 CNAME record for the configuration/primary endpoint. internal_zone_id, internal_zone_name, and internal_record_name must be provided if set to true. true or false. | string | `false` | no |
| curr_connections_evaluations | (memcached, redis) The number of minutes current connections must remain above the specified threshold to generate an alarm. | string | `5` | no |
| curr_connections_threshold | (memcached, redis) The max number of current connections before generating an alarm. | string | `` | no |
| elasticache_engine_type | (memcached, redis, redis multi shard) The name of the cache engine to be used for this cluster. Valid values are: memcached14, redis326, redis28, redis40, redis3210, redis32 | string | - | yes |
| environment | (memcached, redis, redis multi shard) Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | string | `Development` | no |
| evictions_evaluations | (memcached, redis) The number of minutes Evictions must remain above the specified threshold to generate an alarm. | string | `5` | no |
| evictions_threshold | (memcached, redis) The max evictions before generating an alarm. | string | `` | no |
| failover_enabled | (redis) Enable Multi-AZ Failover.  Failover is unsupported on cache.t2.* instance classes. This is hardcoded as true for Redis multi-shard. | string | `true` | no |
| in_transit_encryption | (redis, redis multi shard) Indicates whether to enable encryption in transit. Because there is some processing needed to encrypt and decrypt the data at the endpoints, enabling in-transit encryption can have some performance impact.ONLY AVAILABLE FOR REDIS 3.2.6 AND 4.0.10. true or false | string | `false` | no |
| instance_class | (memcached, redis, redis multi shard) The compute and memory capacity of the nodes within the ElastiCache cluster. Please see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/CacheNodes.SupportedTypes.html for valid instance types. | string | `cache.m3.medium` | no |
| internal_record_name | (memcached, redis, redis multi shard) Record Name for the new Resource Record in the Internal Hosted Zone | string | `` | no |
| internal_zone_id | (memcached, redis, redis multi shard) The Route53 Internal Hosted Zone ID | string | `` | no |
| internal_zone_name | (memcached, redis, redis multi shard) LD for Internal Hosted Zone | string | `` | no |
| notification_topic | (memcached, redis, redis multi shard) SNS Topic ARN to notify if there are any alarms | string | `` | no |
| number_of_nodes | (memcached, redis) The number of cache nodes within the ElastiCache cluster | string | `1` | no |
| number_of_read_replicas_per_shard | (redis multi shard) Number of read replicas per shard | string | `2` | no |
| number_of_shards | (redis multi shard) Number of shards | string | `2` | no |
| preferred_maintenance_window | (memcached, redis, redis multi shard) The weekly time range (in UTC) during which system maintenance can occur. Example: Sun:05:00-Sun:07:00 | string | `Sun:05:00-Sun:07:00` | no |
| redis_multi_shard | (edis, redis multi shard) Is this a redis multi-shard instance? true or false | string | `false` | no |
| replication_group_description | (redis, redis multi shard) Description of Replication Group | string | `Elasticache` | no |
| security_group_list | (memcached, redis, redis multi shard) A list of EC2 security groups to assign to this resource. | list | - | yes |
| snapshot_arn | (redis, redis multi shard) The S3 ARN of a snapshot to use for cluster creation.  Proper access to the S3 file must be granted prior to building instance.  See https://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/backups-seeding-redis.html#backups-seeding-redis-grant-access for details.  This parameter is ignored if a SnapshotName is provided. | string | `` | no |
| snapshot_name | (redis, redis multi shard) The name of a snapshot to use for cluster creation. This property overrides any value assigned to SnapshotArn. | string | `` | no |
| snapshot_retention_limit | (redis, redis multi shard) The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups. Snapshots are unsupported on cache.t2.* instance classes. | string | `7` | no |
| snapshot_window | (redis, redis multi shard) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your node group. Snapshots are unsupported on cache.t2.* instance classes. | string | `03:00-05:00` | no |
| subnets | (memcached, redis, redis multi shard) List of subnets for use with this cache cluster | list | - | yes |
| swap_usage_evaluations | (memcached) The number of minutes SwapUsage must remain above the specified threshold to generate an alarm | string | `5` | no |
| swap_usage_threshold | (memcached) The max SwapUsage before generating an alarm | string | `52428800` | no |

## Outputs

| Name | Description |
|------|-------------|
| elasticache_endpoint | Elasticache endpoint address |
| elasticache_internal_r53_record | Internal Route 53 record FQDN for the Elasticache endpoint(s) |
