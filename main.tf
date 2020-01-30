/**
 * # aws-terraform-elasticache
 *
 * This module creates Elasticache-Memcached, Elasticache-Redis, or Elasticache-Redis Multi-Shard instances.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "elasticache_memcached" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.0"
 *
 *   create_internal_zone_record = true
 *   curr_connections_threshold  = 500
 *   elasticache_engine_type     = "memcached14"
 *   evictions_threshold         = 10
 *   instance_class              = "cache.m4.large"
 *   internal_record_name        = "memcachedconfig"
 *   internal_zone_id            = module.internal_zone.internal_hosted_zone_id
 *   internal_zone_name          = module.internal_zone.internal_hosted_name
 *   name                        = "memc-${random_string.name_suffix.result}"
 *   security_groups             = [module.security_groups.elastic_cache_memcache_security_group_id]
 *   subnets                     = module.vpc.private_subnets
 *
 *   tags = {
 *     MyTag1 = "MyValue1"
 *     MyTag2 = "MyValue2"
 *     MyTag3 = "MyValue3"
 *   }
 * }
 *```
 *
 * Full working references are available at [examples](examples)
 *
 * ## Other TF Modules Used
 * Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 * - evictions_alarm
 * - cpu_utilization_alarm
 * - curr_connections_alarm
 * - swap_usage_alarm
 *
 * ## Terraform 0.12 upgrade
 *
 * Several changes were required while adding terraform 0.12 compatibility.  The following changes should be
 * made when upgrading from a previous release to version 0.12.0 or higher.
 *
 * ### Module variables
 *
 * The following module variables were updated to better meet current Rackspace style guides:
 *
 * - `additional_tags` -> `tags`  
 * - `cluster_name` -> `name`
 * - `cluster_name_version` -> `name_version`
 * - `create_route53_record` -> `create_internal_zone_record`
 * - `security_group_list` -> `security_groups`
 *
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.1.0"
  }
}

locals {
  elasticache_engine = {
    memcached14 = {
      version              = "1.4.34"
      name                 = "memcached"
      family               = "memcached1.4"
      encryption_supported = false
    }
    memcached1510 = {
      version              = "1.5.10"
      name                 = "memcached"
      family               = "memcached1.5"
      encryption_supported = false
    }
    memcached1516 = {
      version              = "1.5.16"
      name                 = "memcached"
      family               = "memcached1.5"
      encryption_supported = false
    }
    redis286 = {
      version              = "2.8.6"
      name                 = "redis"
      family               = "redis2.8"
      encryption_supported = false
    }
    redis2819 = {
      version              = "2.8.19"
      name                 = "redis"
      family               = "redis2.8"
      encryption_supported = false
    }
    redis2821 = {
      version              = "2.8.21"
      name                 = "redis"
      family               = "redis2.8"
      encryption_supported = false
    }
    redis2822 = {
      version              = "2.8.22"
      name                 = "redis"
      family               = "redis2.8"
      encryption_supported = false
    }
    redis2823 = {
      version              = "2.8.23"
      name                 = "redis"
      family               = "redis2.8"
      encryption_supported = false
    }
    redis28 = {
      version              = "2.8.24"
      name                 = "redis"
      family               = "redis2.8"
      encryption_supported = false
    }
    redis32 = {
      version              = "3.2.4"
      name                 = "redis"
      family               = "redis3.2"
      encryption_supported = false
    }
    redis326 = {
      version              = "3.2.6"
      name                 = "redis"
      family               = "redis3.2"
      encryption_supported = true
    }
    redis3210 = {
      version              = "3.2.10"
      name                 = "redis"
      family               = "redis3.2"
      encryption_supported = false
    }
    redis40 = {
      version              = "4.0.10"
      name                 = "redis"
      family               = "redis4.0"
      encryption_supported = true
    }
    redis50 = {
      version              = "5.0.0"
      name                 = "redis"
      family               = "redis5.0"
      encryption_supported = true
    }
    redis503 = {
      version              = "5.0.3"
      name                 = "redis"
      family               = "redis5.0"
      encryption_supported = true
    }
    redis504 = {
      version              = "5.0.4"
      name                 = "redis"
      family               = "redis5.0"
      encryption_supported = true
    }
    redis505 = {
      version              = "5.0.5"
      name                 = "redis"
      family               = "redis5.0"
      encryption_supported = true
    }
    redis506 = {
      version              = "5.0.6"
      name                 = "redis"
      family               = "redis5.0"
      encryption_supported = true
    }
  }

  elasticache_family   = local.elasticache_engine[var.elasticache_engine_type]["family"]
  elasticache_name     = local.elasticache_engine[var.elasticache_engine_type]["name"]
  elasticache_version  = local.elasticache_engine[var.elasticache_engine_type]["version"]
  encryption_supported = local.elasticache_engine[var.elasticache_engine_type]["encryption_supported"]

  # Determine if this qualifies as a redis multi shard instance
  redis_multishard = local.elasticache_name == "redis" && var.redis_multi_shard ? true : false

  # Construct cluster naming with cluster version here
  # There is a 20 char limit on cluster naming. Cluster naming is usually made up of the provided inputs to var.name,
  # var.name_version, and a hyphen. 19 is being used as a limit to take account the hyphen that will be used.
  # Since there is a limit, we must determine how much of the provided input to var.name can be used.
  # Total length is (full length of var.name_version) + (length of hyphen) + (substring of var.name_version)
  # So if the constructed cluster name is too long, var.name will trimmed off.

  substring_length = min(19 - length(var.name_version), length(var.name))
  name_parts       = compact([substr(var.name, 0, local.substring_length), var.name_version])
  constructed_name = join("-", local.name_parts)

  truncated_name = replace(
    substr(local.constructed_name, 0, min(20, length(local.constructed_name))),
    "/-$/",
    "",
  )

  # For non-multi-shard redis or memcached, determine alarm counts
  redis_memcached_alarm_count = local.elasticache_name == "memcached" ? 1 : var.number_of_nodes

  # If redis multi shard and memcached is specified, consider this a conflict to prevent resources from being created.
  conflict_exists = var.redis_multi_shard && local.elasticache_name == "memcached" ? true : false

  # Set default port
  default_port = local.elasticache_name == "memcached" ? "11211" : "6379"
  set_port     = var.cache_cluster_port != "" ? var.cache_cluster_port : local.default_port

  snapshot_supported = var.instance_class == "cache.t1.micro" ? false : true

  tags = merge(
    var.tags,
    {
      Environment     = var.environment
      Name            = local.truncated_name
      ServiceProvider = "Rackspace"
    }
  )
}

###<Common Resources>###

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  count = local.conflict_exists ? 0 : 1

  name       = "${var.name}-subnetgroup"
  subnet_ids = var.subnets
}

resource "aws_elasticache_parameter_group" "elasticache_parameter_group" {
  count = local.redis_multishard || local.conflict_exists ? 0 : 1

  family = local.elasticache_family
  name   = "${var.name}-ecparamgroup"
}

resource "aws_route53_record" "internal_record_set_elasticache" {
  count = var.create_internal_zone_record && false == local.conflict_exists ? 1 : 0

  name    = "${var.internal_record_name}.${var.internal_zone_name}"
  ttl     = "300"
  type    = "CNAME"
  zone_id = var.internal_zone_id

  records = coalescelist(
    aws_elasticache_replication_group.redis_rep_group.*.primary_endpoint_address,
    aws_elasticache_replication_group.redis_multi_shard_rep_group.*.configuration_endpoint_address,
    aws_elasticache_cluster.cache_cluster.*.configuration_endpoint,
  )
}

###<\Common Resources>###

###<Elasticache Memcached and Redis non-multi-shard Shared Resources>###
data "null_data_source" "alarm_dimensions" {
  count = false == local.redis_multishard && false == local.conflict_exists ? local.redis_memcached_alarm_count : 0

  inputs = {
    CacheClusterId = element(
      coalescelist(
        aws_elasticache_cluster.cache_cluster.*.cluster_id,
        flatten(aws_elasticache_replication_group.redis_rep_group.*.member_clusters),
      ),
      count.index,
    )
  }
}

module "evictions_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.0"

  alarm_count              = false == local.redis_multishard && false == local.conflict_exists && var.evictions_threshold != "" ? local.redis_memcached_alarm_count : 0
  alarm_description        = "Evictions over ${var.evictions_threshold}"
  alarm_name               = "${var.name}-EvictionsAlarm"
  customer_alarms_enabled  = true
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = var.evictions_evaluations
  metric_name              = "Evictions"
  namespace                = "AWS/ElastiCache"
  notification_topic       = [var.notification_topic]
  period                   = 60
  rackspace_alarms_enabled = false
  statistic                = "Average"
  threshold                = var.evictions_threshold
}

module "cpu_utilization_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.0"

  alarm_count              = false == local.redis_multishard && false == local.conflict_exists ? local.redis_memcached_alarm_count : 0
  alarm_name               = "${var.name}-CPUUtilizationAlarm"
  alarm_description        = "CPUUtilization over ${var.cpu_high_threshold}"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = var.cpu_high_evaluations
  metric_name              = "CPUUtilization"
  namespace                = "AWS/ElastiCache"
  notification_topic       = [var.notification_topic]
  period                   = 60
  rackspace_alarms_enabled = false
  statistic                = "Average"
  threshold                = var.cpu_high_threshold
}

module "curr_connections_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.0"

  alarm_count              = false == local.redis_multishard && false == local.conflict_exists && var.curr_connections_threshold != "" ? local.redis_memcached_alarm_count : 0
  alarm_name               = "${var.name}-CurrConnectionsAlarm"
  alarm_description        = "CurrConnections over ${var.curr_connections_threshold}"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = var.curr_connections_evaluations
  metric_name              = "CurrConnections"
  namespace                = "AWS/ElastiCache"
  notification_topic       = [var.notification_topic]
  period                   = 60
  rackspace_alarms_enabled = false
  statistic                = "Average"
  threshold                = var.curr_connections_threshold
}

###<\Elasticache Memcached and Redis non-multi-shard Shared Resources>###

###<Elasticache Memcached Resources>###

resource "aws_elasticache_cluster" "cache_cluster" {
  count = local.elasticache_name == "memcached" && false == local.conflict_exists ? 1 : 0

  az_mode              = var.number_of_nodes > 1 ? "cross-az" : "single-az"
  cluster_id           = local.truncated_name
  engine               = local.elasticache_name
  engine_version       = local.elasticache_version
  maintenance_window   = var.preferred_maintenance_window
  node_type            = var.instance_class
  num_cache_nodes      = var.number_of_nodes
  parameter_group_name = aws_elasticache_parameter_group.elasticache_parameter_group[0].name
  port                 = local.set_port
  security_group_ids   = compact(var.security_groups)
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group[0].name
  tags                 = local.tags
}

locals {
  memcache_cluster_id = element(
    concat(aws_elasticache_cluster.cache_cluster.*.cluster_id, [""]),
    0,
  )
}

module "swap_usage_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.0"

  alarm_count              = local.elasticache_name == "memcached" && false == local.conflict_exists ? 1 : 0
  alarm_description        = "CacheCluster ${local.memcache_cluster_id} SwapUsage over ${var.swap_usage_threshold}"
  alarm_name               = "${var.name}-SwapUsageAlarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = var.swap_usage_evaluations
  metric_name              = "SwapUsage"
  namespace                = "AWS/ElastiCache"
  notification_topic       = [var.notification_topic]
  period                   = 60
  rackspace_alarms_enabled = false
  statistic                = "Average"
  threshold                = var.swap_usage_threshold

  dimensions = [
    {
      CacheClusterId = local.memcache_cluster_id
    },
  ]
}

###<\Elasticache Memcached Resources>###

###<Redis non-multi-shard Resources>###

resource "aws_elasticache_replication_group" "redis_rep_group" {
  count = local.elasticache_name != "memcached" && false == local.redis_multishard ? 1 : 0

  at_rest_encryption_enabled    = local.encryption_supported ? var.at_rest_encrypted_disk : false
  automatic_failover_enabled    = var.instance_class != "cache.t1.micro" && var.number_of_nodes >= 2 ? var.failover_enabled : false
  engine                        = local.elasticache_name
  engine_version                = local.elasticache_version
  maintenance_window            = var.preferred_maintenance_window
  node_type                     = var.instance_class
  notification_topic_arn        = var.notification_topic
  number_cache_clusters         = var.number_of_nodes
  parameter_group_name          = aws_elasticache_parameter_group.elasticache_parameter_group[0].name
  port                          = local.set_port
  replication_group_description = var.replication_group_description
  replication_group_id          = local.truncated_name
  security_group_ids            = compact(var.security_groups)
  snapshot_arns                 = compact([var.snapshot_arn])
  snapshot_name                 = local.snapshot_supported ? var.snapshot_name : ""
  snapshot_retention_limit      = local.snapshot_supported ? var.snapshot_retention_limit : 0
  snapshot_window               = local.snapshot_supported ? var.snapshot_window : ""
  subnet_group_name             = aws_elasticache_subnet_group.elasticache_subnet_group[0].name
  tags                          = local.tags
  transit_encryption_enabled    = var.in_transit_encryption
}

###</Redis non-multi-shard Resources>###

###<Redis multi-shard Resources>###

resource "aws_elasticache_replication_group" "redis_multi_shard_rep_group" {
  count = local.redis_multishard && local.elasticache_name != "memcached" ? 1 : 0

  at_rest_encryption_enabled    = local.encryption_supported ? var.at_rest_encrypted_disk : false
  automatic_failover_enabled    = true
  engine                        = local.elasticache_name
  engine_version                = local.elasticache_version
  maintenance_window            = var.preferred_maintenance_window
  node_type                     = var.instance_class
  notification_topic_arn        = var.notification_topic
  parameter_group_name          = aws_elasticache_parameter_group.redis_multi_shard_param_group[0].name
  port                          = local.set_port
  replication_group_description = var.replication_group_description
  replication_group_id          = local.truncated_name
  security_group_ids            = compact(var.security_groups)
  snapshot_arns                 = compact([var.snapshot_arn])
  snapshot_name                 = var.snapshot_name
  snapshot_retention_limit      = var.snapshot_retention_limit
  snapshot_window               = var.snapshot_window
  subnet_group_name             = aws_elasticache_subnet_group.elasticache_subnet_group[0].name
  tags                          = local.tags
  transit_encryption_enabled    = var.in_transit_encryption

  cluster_mode {
    num_node_groups         = var.number_of_shards
    replicas_per_node_group = var.number_of_read_replicas_per_shard
  }
}

resource "aws_elasticache_parameter_group" "redis_multi_shard_param_group" {
  count = local.redis_multishard ? 1 : 0

  family = local.elasticache_family
  name   = "${var.name}-ecparamgroup"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

