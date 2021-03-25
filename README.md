# aws-terraform-elasticache

This module creates Elasticache-Memcached, Elasticache-Redis, or Elasticache-Redis Multi-Shard instances.

## Basic Usage

```HCL
module "elasticache_memcached" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.0"

  create_internal_zone_record = true
  curr_connections_threshold  = 500
  elasticache_engine_type     = "memcached14"
  evictions_threshold         = 10
  instance_class              = "cache.m4.large"
  internal_record_name        = "memcachedconfig"
  internal_zone_id            = module.internal_zone.internal_hosted_zone_id
  internal_zone_name          = module.internal_zone.internal_hosted_name
  name                        = "memc-${random_string.name_suffix.result}"
  security_groups             = [module.security_groups.elastic_cache_memcache_security_group_id]
  subnets                     = module.vpc.private_subnets

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}
*
```

Full working references are available at [examples](examples)

## Other TF Modules Used  
Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
- evictions\_alarm
- cpu\_utilization\_alarm
- curr\_connections\_alarm
- swap\_usage\_alarm

## Terraform 0.12 upgrade

Several changes were required while adding terraform 0.12 compatibility.  The following changes should be  
made when upgrading from a previous release to version 0.12.0 or higher.

### Module variables

The following module variables were updated to better meet current Rackspace style guides:

- `additional_tags` -> `tags`
- `cluster_name` -> `name`
- `cluster_name_version` -> `name_version`
- `create_route53_record` -> `create_internal_zone_record`
- `security_group_list` -> `security_groups`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7.0 |
| null | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| cpu_utilization_alarm | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=0.12.6 |  |
| curr_connections_alarm | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=0.12.6 |  |
| evictions_alarm | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=0.12.6 |  |
| swap_usage_alarm | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=0.12.6 |  |

## Resources

| Name |
|------|
| [aws_elasticache_cluster](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/elasticache_cluster) |
| [aws_elasticache_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/elasticache_parameter_group) |
| [aws_elasticache_replication_group](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/elasticache_replication_group) |
| [aws_elasticache_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/elasticache_subnet_group) |
| [aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/route53_record) |
| [null_data_source](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| at\_rest\_encrypted\_disk | (redis, redis multi shard) Indicates whether to enable encryption at rest. ONLY AVAILABLE FOR REDIS 3.2.6, 4.0.10 AND 5.0.0. `true` or `false`. | `bool` | `false` | no |
| authentication\_token | (redis, redis multi shard) The password used to access a password protected server. Can be specified only if `in_transit_encryption = true` and will be ignored otherwise | `string` | `""` | no |
| cache\_cluster\_port | (memcached, redis, redis multi shard) The port number on which each of the cache nodes will accept connections. Default for redis is 6379. Default for memcached is 11211 | `string` | `""` | no |
| cluster\_name | (memcached, redis, redis multi shard) Name of the Cluster. Will also be used to name other provisioned resources. If this value is empty, `name` and `name_version` will be used for backwards compatibility. Should not exceed 50 characters due to string length constraints. NOTICE: Cluster Name allows 50 characters MAX. | `string` | `""` | no |
| cpu\_high\_evaluations | (memcached, redis) The number of minutes CPU usage must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| cpu\_high\_threshold | (memcached, redis) The max CPU Usage % before generating an alarm. | `number` | `90` | no |
| create\_internal\_zone\_record | (memcached, redis, redis multi shard) Specifies whether or not to create a route53 CNAME record for the configuration/primary endpoint. internal\_zone\_id, internal\_zone\_name, and internal\_record\_name must be provided if set to true. true or false. | `bool` | `false` | no |
| curr\_connections\_evaluations | (memcached, redis) The number of minutes current connections must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| curr\_connections\_threshold | (memcached, redis) The max number of current connections before generating an alarm. NOTE: If this variable is not set, the connections alarm will not be provisioned. | `string` | `""` | no |
| elasticache\_engine\_type | (memcached, redis, redis multi shard) The name of the cache engine to be used for this cluster. Valid values are: memcached14, memcached1510, memcached1516, redis28, redis2823, redis2822, redis2821, redis2819, redis286, redis32, redis326, redis3210, redis40, redis50, redis503, redis504, redis505, redis506 | `string` | n/a | yes |
| environment | (memcached, redis, redis multi shard) Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | `string` | `"Development"` | no |
| evictions\_evaluations | (memcached, redis) The number of minutes Evictions must remain above the specified threshold to generate an alarm. | `number` | `5` | no |
| evictions\_threshold | (memcached, redis) The max evictions before generating an alarm. NOTE: If this variable is not set, the evictions alarm will not be provisioned. | `string` | `""` | no |
| failover\_enabled | (redis) Enable Multi-AZ Failover. Failover is unsupported on the cache.t1.micro instance class. This is hardcoded as true for Redis multi-shard. | `bool` | `true` | no |
| in\_transit\_encryption | (redis, redis multi shard) Indicates whether to enable encryption in transit. Because there is some processing needed to encrypt and decrypt the data at the endpoints, enabling in-transit encryption can have some performance impact.ONLY AVAILABLE FOR REDIS 3.2.6, 4.0.10 and later. true or false | `bool` | `false` | no |
| instance\_class | (memcached, redis, redis multi shard) The compute and memory capacity of the nodes within the ElastiCache cluster. Please see https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/CacheNodes.SupportedTypes.html for valid instance types. | `string` | n/a | yes |
| internal\_record\_name | (memcached, redis, redis multi shard) Record Name for the new Resource Record in the Internal Hosted Zone | `string` | `""` | no |
| internal\_zone\_id | (memcached, redis, redis multi shard) The Route53 Internal Hosted Zone ID | `string` | `""` | no |
| internal\_zone\_name | (memcached, redis, redis multi shard) LD for Internal Hosted Zone | `string` | `""` | no |
| name | DEPRECATED, MAY REMOVE IN A FUTURE VERSION, USE `cluster_name` AND `replication_group_name`!! (memcached, redis, redis multi shard) Name of Cluster. Will also be used to name other provisioned resources. If non empty cluster\_name\_version is being used, total length of cluster\_name plus cluster\_name\_version should not exceed 19 due to string length constraints | `string` | `""` | no |
| name\_version | DEPRECATED, MAY REMOVE IN A FUTURE VERSION, USE `cluster_name` AND `replication_group_name`!! (memcached, redis, redis multi shard) NOTE: This needs to increment on update with new snapshot. If non empty cluster\_name\_version is being used, total length of cluster\_name plus cluster\_name\_version should not exceed 19 due to string length constraints | `string` | `"v00"` | no |
| notification\_topic | (memcached, redis, redis multi shard) SNS Topic ARN to notify if there are any alarms | `string` | `""` | no |
| number\_of\_nodes | (memcached, redis) The number of cache nodes within the ElastiCache cluster. This number must be grearter or equal 2 to enable automatic failover. | `number` | `1` | no |
| number\_of\_read\_replicas\_per\_shard | (redis multi shard) Number of read replicas per shard | `number` | `2` | no |
| number\_of\_shards | (redis multi shard) Number of shards | `number` | `2` | no |
| preferred\_maintenance\_window | (memcached, redis, redis multi shard) The weekly time range (in UTC) during which system maintenance can occur. Example: Sun:05:00-Sun:07:00 | `string` | `"Sun:05:00-Sun:07:00"` | no |
| redis\_multi\_shard | (edis, redis multi shard) Is this a redis multi-shard instance? true or false | `bool` | `false` | no |
| replication\_group\_description | (redis, redis multi shard) Description of Replication Group | `string` | `"Elasticache"` | no |
| replication\_group\_name | (memcached, redis, redis multi shard) Name of the Cluster replication group ID, must be unique. If this value is empty, `name` and `name_version` will be used for backwards compatibility. Should not exceed 40 characters due to string length constraints. NOTICE: Group ID allows 40 characters MAX. | `string` | `""` | no |
| security\_groups | (memcached, redis, redis multi shard) A list of EC2 security groups to assign to this resource. | `list(string)` | n/a | yes |
| snapshot\_arn | (redis, redis multi shard) The S3 ARN of a snapshot to use for cluster creation.  Proper access to the S3 file must be granted prior to building instance.  See https://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/backups-seeding-redis.html#backups-seeding-redis-grant-access for details.  This parameter is ignored if a SnapshotName is provided. | `string` | `""` | no |
| snapshot\_name | (redis, redis multi shard) The name of a snapshot to use for cluster creation. This property overrides any value assigned to SnapshotArn. Snapshots are unsupported on cache.t1.micro instance class. | `string` | `""` | no |
| snapshot\_retention\_limit | (redis, redis multi shard) The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups. Snapshots are unsupported on cache.t1.micro instance class. | `number` | `7` | no |
| snapshot\_window | (redis, redis multi shard) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your node group. Snapshots are unsupported on cache.t1.micro instance class. | `string` | `"03:00-05:00"` | no |
| subnets | (memcached, redis, redis multi shard) List of subnets for use with this cache cluster | `list(string)` | n/a | yes |
| swap\_usage\_evaluations | (memcached) The number of minutes SwapUsage must remain above the specified threshold to generate an alarm | `number` | `5` | no |
| swap\_usage\_threshold | (memcached) The max SwapUsage before generating an alarm | `number` | `52428800` | no |
| tags | (memcached, redis, redis multi shard) Additional tags to be added to the Elasticache resources. Please see examples directory in this repo for examples. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| elasticache\_endpoint | Elasticache endpoint address |
| elasticache\_internal\_r53\_record | Internal Route 53 record FQDN for the Elasticache endpoint(s) |
