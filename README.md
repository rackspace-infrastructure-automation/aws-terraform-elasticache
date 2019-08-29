# aws-terraform-elasticache

This module creates Elasticache-Memcached, Elasticache-Redis, or Elasticache-Redis Multi-Shard instances.

## Basic Usage

```HCL
module "elasticache_memcached" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.0.12"

  cluster_name               = "memc-${random_string.name_suffix.result}"
  create_route53_record      = true
  curr_connections_threshold = 500
  elasticache_engine_type    = "memcached14"
  evictions_threshold        = 10
  instance_class             = "cache.m4.large"
  internal_record_name       = "memcachedconfig"
  internal_zone_id           = "${module.internal_zone.internal_hosted_zone_id}"
  internal_zone_name         = "${module.internal_zone.internal_hosted_name}"
  security_group_list        = ["${module.security_groups.elastic_cache_memcache_security_group_id}"]
  subnets                    = ["${module.vpc.private_subnets}"]

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}
```

Full working references are available at [examples](examples)
## Other TF Modules Used
Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
	- evictions_alarm
	- cpu_utilization_alarm
	- curr_connections_alarm
	- swap_usage_alarm

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_tags | (memcached, redis, redis multi shard) Additional tags to be added to the Elasticache resources. Please see examples directory in this repo for examples. | map | `<map>` | no |
| at\_rest\_encrypted\_disk | (redis, redis multi shard) Indicates whether to enable encryption at rest. ONLY AVAILABLE FOR REDIS 3.2.6, 4.0.10 AND 5.0.0. `true` or `false`. | string | `"false"` | no |
| cache\_cluster\_port | (memcached, redis, redis multi shard) The port number on which each of the cache nodes will accept connections. Default for redis is 6379. Default for memcached is 11211 | string | `""` | no |
| cluster\_name | (memcached, redis, redis multi shard) Name of Cluster. Will also be used to name other provisioned resources. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints | string | n/a | yes |
| cluster\_name\_version | (memcached, redis, redis multi shard) NOTE: This needs to increment on update with new snapshot. If non empty cluster_name_version is being used, total length of cluster_name plus cluster_name_version should not exceed 19 due to string length constraints | string | `"v00"` | no |
| cpu\_high\_evaluations | (memcached, redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm. | string | `"5"` | no |
| cpu\_high\_threshold | (memcached, redis) The max CPU Usage % before generating an alarm. | string | `"90"` | no |
| create\_route53\_record | (memcached, redis, redis multi shard) Specifies whether or not to create a route53 CNAME record for the configuration/primary endpoint. internal_zone_id, internal_zone_name, and internal_record_name must be provided if set to true. true or false. | string | `"false"` | no |
| curr\_connections\_evaluations | (memcached, redis) The number of minutes current connections must remain above the specified threshold to generate an alarm. | string | `"5"` | no |
| curr\_connections\_threshold | (memcached, redis) The max number of current connections before generating an alarm. NOTE: If this variable is not set, the connections alarm will not be provisioned. | string | `""` | no |
| elasticache\_engine\_type | (memcached, redis, redis multi shard) The name of the cache engine to be used for this cluster. Valid values are: memcached14, memcached1510, redis28, redis2823, redis2822, redis2821, redis2819, redis286, redis32, redis326, redis3210, redis40, redis50, redis503, redis504 | string | n/a | yes |
| environment | (memcached, redis, redis multi shard) Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | string | `"Development"` | no |
| evictions\_evaluations | (memcached, redis) The number of minutes Evictions must remain above the specified threshold to generate an alarm. | string | `"5"` | no |
| evictions\_threshold | (memcached, redis) The max evictions before generating an alarm. NOTE: If this variable is not set, the evictions alarm will not be provisioned. | string | `""` | no |
| failover\_enabled | (redis) Enable Multi-AZ Failover. Failover is unsupported on the cache.t1.micro instance class. This is hardcoded as true for Redis multi-shard. | string | `"true"` | no |
| in\_transit\_encryption | (redis, redis multi shard) Indicates whether to enable encryption in transit. Because there is some processing needed to encrypt and decrypt the data at the endpoints, enabling in-transit encryption can have some performance impact.ONLY AVAILABLE FOR REDIS 3.2.6 AND 4.0.10. true or false | string | `"false"` | no |
| instance\_class | (memcached, redis, redis multi shard) The compute and memory capacity of the nodes within the ElastiCache cluster. Please see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/CacheNodes.SupportedTypes.html for valid instance types. | string | n/a | yes |
| internal\_record\_name | (memcached, redis, redis multi shard) Record Name for the new Resource Record in the Internal Hosted Zone | string | `""` | no |
| internal\_zone\_id | (memcached, redis, redis multi shard) The Route53 Internal Hosted Zone ID | string | `""` | no |
| internal\_zone\_name | (memcached, redis, redis multi shard) LD for Internal Hosted Zone | string | `""` | no |
| notification\_topic | (memcached, redis, redis multi shard) SNS Topic ARN to notify if there are any alarms | string | `""` | no |
| number\_of\_nodes | (memcached, redis) The number of cache nodes within the ElastiCache cluster. This number must be grearter or equal 2 to enable automatic failover. | string | `"1"` | no |
| number\_of\_read\_replicas\_per\_shard | (redis multi shard) Number of read replicas per shard | string | `"2"` | no |
| number\_of\_shards | (redis multi shard) Number of shards | string | `"2"` | no |
| preferred\_maintenance\_window | (memcached, redis, redis multi shard) The weekly time range (in UTC) during which system maintenance can occur. Example: Sun:05:00-Sun:07:00 | string | `"Sun:05:00-Sun:07:00"` | no |
| redis\_multi\_shard | (edis, redis multi shard) Is this a redis multi-shard instance? true or false | string | `"false"` | no |
| replication\_group\_description | (redis, redis multi shard) Description of Replication Group | string | `"Elasticache"` | no |
| security\_group\_list | (memcached, redis, redis multi shard) A list of EC2 security groups to assign to this resource. | list | n/a | yes |
| snapshot\_arn | (redis, redis multi shard) The S3 ARN of a snapshot to use for cluster creation.  Proper access to the S3 file must be granted prior to building instance.  See https://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/backups-seeding-redis.html#backups-seeding-redis-grant-access for details.  This parameter is ignored if a SnapshotName is provided. | string | `""` | no |
| snapshot\_name | (redis, redis multi shard) The name of a snapshot to use for cluster creation. This property overrides any value assigned to SnapshotArn. Snapshots are unsupported on cache.t1.micro instance class. | string | `""` | no |
| snapshot\_retention\_limit | (redis, redis multi shard) The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups. Snapshots are unsupported on cache.t1.micro instance class. | string | `"7"` | no |
| snapshot\_window | (redis, redis multi shard) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your node group. Snapshots are unsupported on cache.t1.micro instance class. | string | `"03:00-05:00"` | no |
| subnets | (memcached, redis, redis multi shard) List of subnets for use with this cache cluster | list | n/a | yes |
| swap\_usage\_evaluations | (memcached) The number of minutes SwapUsage must remain above the specified threshold to generate an alarm | string | `"5"` | no |
| swap\_usage\_threshold | (memcached) The max SwapUsage before generating an alarm | string | `"52428800"` | no |

## Outputs

| Name | Description |
|------|-------------|
| elasticache\_endpoint | Elasticache endpoint address |
| elasticache\_internal\_r53\_record | Internal Route 53 record FQDN for the Elasticache endpoint(s) |

