locals {
  elasticache_engine = {
    memcached14 = {
      version              = "1.4.34"
      name                 = "memcached"
      family               = "memcached1.4"
      encryption_supported = false
    }

    redis326 = {
      version              = "3.2.6"
      name                 = "redis"
      family               = "redis3.2"
      encryption_supported = true
    }

    redis28 = {
      version              = "2.8.24"
      name                 = "redis"
      family               = "redis2.8"
      encryption_supported = false
    }

    redis40 = {
      version              = "4.0.10"
      name                 = "redis"
      family               = "redis4.0"
      encryption_supported = true
    }

    redis3210 = {
      version              = "3.2.10"
      name                 = "redis"
      family               = "redis3.2"
      encryption_supported = false
    }

    redis32 = {
      version              = "3.2.4"
      name                 = "redis"
      family               = "redis3.2"
      encryption_supported = false
    }
  }

  elasticache_family   = "${lookup(local.elasticache_engine["${var.elasticache_engine_type}"], "family")}"
  elasticache_name     = "${lookup(local.elasticache_engine["${var.elasticache_engine_type}"], "name")}"
  elasticache_version  = "${lookup(local.elasticache_engine["${var.elasticache_engine_type}"], "version")}"
  encryption_supported = "${lookup(local.elasticache_engine["${var.elasticache_engine_type}"], "encryption_supported")}"

  # Determine if this qualifies as a redis multi shard instance
  redis_multishard = "${local.elasticache_name == "redis" && var.redis_multi_shard ? true : false}"

  # Construct cluster naming with cluster version here
  # There is a 20 char limit on cluster naming. Cluster naming is usually made up of the provided inputs to var.cluster_name,
  # var.cluster_name_version, and a hyphen. 19 is being used as a limit to take account the hyphen that will be used.
  # Since there is a limit, we must determine how much of the provided input to var.cluster_name can be used.
  # Total length is (full length of var.cluster_name_version) + (length of hyphen) + (substring of var.cluster_name_version)
  # So if the constructed cluster name is too long, var.cluster_name will trimmed off.
  substring_length = "${19 - length(var.cluster_name_version) > length(var.cluster_name) ? length(var.cluster_name) : 19 - length(var.cluster_name_version)}"

  constructed_cluster_name = "${var.cluster_name_version != "" ? replace(join("-", list(substr(var.cluster_name, 0, local.substring_length), var.cluster_name_version)), "/^-/", "") : substr(var.cluster_name, 0, local.substring_length)}"

  truncated_constructed_cluster_name = "${substr(local.constructed_cluster_name, 0, min(20, length(local.constructed_cluster_name)))}"

  # For non-multi-shard redis or memcached, determine alarm counts
  redis_memcached_alarm_count = "${local.elasticache_name == "memcached" ? 1 : var.number_of_nodes}"

  # If redis multi shard and memcached is specified, consider this a conflict to prevent resources from being created.
  conflict_exists = "${var.redis_multi_shard && local.elasticache_name == "memcached" ? true : false}"

  # Set default port
  default_port = "${local.elasticache_name == "memcached" ? "11211" : "6379"}"
  set_port     = "${var.cache_cluster_port != "" ? var.cache_cluster_port : local.default_port}"

  # Determine if Instance Class is T2 instance. This condition is being checked since automatic failover
  # is not supported on t2 instances for elasticache redis replication groups.
  instance_prefix = "${element(split(".",var.instance_class), 1)}"

  is_t2 = "${local.instance_prefix == "t2" ? true : false}"

  snapshot_supported = "${local.instance_prefix == "t2" || var.instance_class == "cache.t1.micro" ? false : true}"

  tags = {
    Environment     = "${var.environment}"
    ServiceProvider = "Rackspace"
  }
}

###<Common Resources>###

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  count      = "${local.conflict_exists ? 0 : 1}"
  name       = "${var.cluster_name}-subnetgroup"
  subnet_ids = ["${var.subnets}"]
}

resource "aws_elasticache_parameter_group" "elasticache_parameter_group" {
  count  = "${local.redis_multishard || local.conflict_exists ? 0 : 1}"
  name   = "${var.cluster_name}-ecparamgroup"
  family = "${local.elasticache_family}"
}

resource "aws_route53_record" "internal_record_set_elasticache" {
  count   = "${var.create_route53_record && !(local.conflict_exists) ? 1 : 0}"
  name    = "${var.internal_record_name}.${var.internal_zone_name}"
  type    = "CNAME"
  zone_id = "${var.internal_zone_id}"
  ttl     = "300"
  records = ["${element(coalescelist(aws_elasticache_replication_group.redis_rep_group.*.primary_endpoint_address, aws_elasticache_replication_group.redis_multi_shard_rep_group.*.configuration_endpoint_address, aws_elasticache_cluster.cache_cluster.*.configuration_endpoint),0)}"]
}

###<\Common Resources>###

###<Elasticache Memcached and Redis non-multi-shard Shared Resources>###

resource "aws_cloudwatch_metric_alarm" "evictions_alarm" {
  count               = "${!(local.redis_multishard) && !(local.conflict_exists) && var.evictions_threshold != "" ? local.redis_memcached_alarm_count : 0}"
  alarm_name          = "${local.redis_memcached_alarm_count > 1 ? "${var.cluster_name}-Node${count.index}EvictionsAlarm" : "${var.cluster_name}-EvictionsAlarm"}"
  evaluation_periods  = "${var.evictions_evaluations}"
  alarm_actions       = ["${compact(list(var.notification_topic))}"]
  alarm_description   = "Evictions over ${var.evictions_threshold}"
  namespace           = "AWS/Elasticache"
  period              = "60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = "${var.evictions_threshold}"
  metric_name         = "Evictions"

  dimensions {
    CacheClusterId = "${element(coalescelist(aws_elasticache_cluster.cache_cluster.*.cluster_id, flatten(aws_elasticache_replication_group.redis_rep_group.*.member_clusters)), count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  count               = "${!(local.redis_multishard) && !(local.conflict_exists) ? local.redis_memcached_alarm_count : 0}"
  alarm_name          = "${local.redis_memcached_alarm_count > 1 ? "${var.cluster_name}-Node${count.index}CPUUtilizationAlarm" : "${var.cluster_name}-CPUUtilizationAlarm"}"
  evaluation_periods  = "${var.cpu_high_evaluations}"
  alarm_actions       = ["${compact(list(var.notification_topic))}"]
  alarm_description   = "CPUUtilization over ${var.cpu_high_threshold}"
  namespace           = "AWS/Elasticache"
  period              = "60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = "${var.cpu_high_threshold}"
  metric_name         = "CPUUtilization"

  dimensions {
    CacheClusterId = "${element(coalescelist(aws_elasticache_cluster.cache_cluster.*.cluster_id, flatten(aws_elasticache_replication_group.redis_rep_group.*.member_clusters)), count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "curr_connections_alarm" {
  count               = "${!(local.redis_multishard) && !(local.conflict_exists) && var.curr_connections_threshold != "" ? local.redis_memcached_alarm_count : 0}"
  alarm_name          = "${local.redis_memcached_alarm_count > 1 ? "${var.cluster_name}-Node${count.index}CurrConnectionsAlarm" : "${var.cluster_name}-CurrConnectionsAlarm"}"
  evaluation_periods  = "${var.curr_connections_evaluations}"
  alarm_actions       = ["${compact(list(var.notification_topic))}"]
  alarm_description   = "CurrConnections over ${var.curr_connections_threshold}"
  namespace           = "AWS/Elasticache"
  period              = "60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = "${var.curr_connections_threshold}"
  metric_name         = "CurrConnections"

  dimensions {
    CacheClusterId = "${element(coalescelist(aws_elasticache_cluster.cache_cluster.*.cluster_id, flatten(aws_elasticache_replication_group.redis_rep_group.*.member_clusters)), count.index)}"
  }
}

###<\Elasticache Memcached and Redis non-multi-shard Shared Resources>###

###<Elasticache Memcached Resources>###

resource "aws_elasticache_cluster" "cache_cluster" {
  count                = "${local.elasticache_name == "memcached" && !(local.conflict_exists) ? 1 : 0}"
  cluster_id           = "${local.truncated_constructed_cluster_name}"
  engine               = "${local.elasticache_name}"
  parameter_group_name = "${aws_elasticache_parameter_group.elasticache_parameter_group.name}"
  num_cache_nodes      = "${var.number_of_nodes}"
  security_group_ids   = ["${compact(var.security_group_list)}"]
  engine_version       = "${local.elasticache_version}"
  az_mode              = "${var.number_of_nodes > 1 ? "cross-az" : "single-az"}"
  node_type            = "${var.instance_class}"
  port                 = "${local.set_port}"
  maintenance_window   = "${var.preferred_maintenance_window}"
  subnet_group_name    = "${aws_elasticache_subnet_group.elasticache_subnet_group.name}"

  tags = "${merge(
    map("Name", "${local.truncated_constructed_cluster_name}"),
    local.tags,
    var.additional_tags
  )}"
}

resource "aws_cloudwatch_metric_alarm" "swap_usage_alarm" {
  count               = "${local.elasticache_name == "memcached" && !(local.conflict_exists) ? 1 : 0}"
  alarm_name          = "${join("-", list("SwapUsageAlarm", var.cluster_name))}"
  evaluation_periods  = "${var.swap_usage_evaluations}"
  alarm_actions       = ["${compact(list(var.notification_topic))}"]
  alarm_description   = "CacheCluster ${aws_elasticache_cluster.cache_cluster.cluster_id} SwapUsage over ${var.swap_usage_threshold}"
  namespace           = "AWS/Elasticache"
  period              = "60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  threshold           = "${var.swap_usage_threshold}"
  metric_name         = "SwapUsage"

  dimensions {
    CacheClusterId = "${aws_elasticache_cluster.cache_cluster.cluster_id}"
  }
}

###<\Elasticache Memcached Resources>###

###<Redis non-multi-shard Resources>###

resource "aws_elasticache_replication_group" "redis_rep_group" {
  count                         = "${local.elasticache_name != "memcached" && !(local.redis_multishard) ? 1 : 0}"
  replication_group_description = "${var.replication_group_description}"
  engine                        = "${local.elasticache_name}"
  engine_version                = "${local.elasticache_version}"
  parameter_group_name          = "${aws_elasticache_parameter_group.elasticache_parameter_group.name}"
  snapshot_arns                 = ["${compact(list(var.snapshot_arn))}"]
  transit_encryption_enabled    = "${var.in_transit_encryption}"
  snapshot_retention_limit      = "${local.snapshot_supported ? var.snapshot_retention_limit : 0}"
  snapshot_name                 = "${local.snapshot_supported ? var.snapshot_name : ""}"
  snapshot_window               = "${local.snapshot_supported ? var.snapshot_window : ""}"
  at_rest_encryption_enabled    = "${local.encryption_supported ? var.at_rest_encrypted_disk : false}"
  replication_group_id          = "${local.truncated_constructed_cluster_name}"
  security_group_ids            = ["${compact(var.security_group_list)}"]
  node_type                     = "${var.instance_class}"
  notification_topic_arn        = "${var.notification_topic}"
  port                          = "${local.set_port}"
  maintenance_window            = "${var.preferred_maintenance_window}"
  subnet_group_name             = "${aws_elasticache_subnet_group.elasticache_subnet_group.name}"
  automatic_failover_enabled    = "${local.is_t2 ? false : var.failover_enabled}"
  number_cache_clusters         = "${var.number_of_nodes}"

  tags = "${merge(
    map("Name", "${local.truncated_constructed_cluster_name}"),
    local.tags,
    var.additional_tags
  )}"
}

###</Redis non-multi-shard Resources>###

###<Redis multi-shard Resources>###

resource "aws_elasticache_replication_group" "redis_multi_shard_rep_group" {
  count                         = "${local.redis_multishard && local.elasticache_name != "memcached" ? 1 : 0}"
  replication_group_description = "${var.replication_group_description}"
  engine                        = "${local.elasticache_name}"
  engine_version                = "${local.elasticache_version}"
  parameter_group_name          = "${aws_elasticache_parameter_group.redis_multi_shard_param_group.name}"
  snapshot_arns                 = ["${compact(list(var.snapshot_arn))}"]
  transit_encryption_enabled    = "${var.in_transit_encryption}"
  snapshot_retention_limit      = "${var.snapshot_retention_limit}"
  snapshot_name                 = "${var.snapshot_name}"
  snapshot_window               = "${var.snapshot_window}"
  at_rest_encryption_enabled    = "${local.encryption_supported ? var.at_rest_encrypted_disk : false}"
  replication_group_id          = "${local.truncated_constructed_cluster_name}"
  security_group_ids            = ["${compact(var.security_group_list)}"]
  node_type                     = "${var.instance_class}"
  notification_topic_arn        = "${var.notification_topic}"
  port                          = "${local.set_port}"
  maintenance_window            = "${var.preferred_maintenance_window}"
  subnet_group_name             = "${aws_elasticache_subnet_group.elasticache_subnet_group.name}"
  automatic_failover_enabled    = true

  cluster_mode {
    num_node_groups         = "${var.number_of_shards}"
    replicas_per_node_group = "${var.number_of_read_replicas_per_shard}"
  }

  tags = "${merge(
    map("Name", "${local.truncated_constructed_cluster_name}"),
    local.tags,
    var.additional_tags
  )}"
}

resource "aws_elasticache_parameter_group" "redis_multi_shard_param_group" {
  count  = "${local.redis_multishard ? 1 : 0}"
  name   = "${var.cluster_name}-ecparamgroup"
  family = "${local.elasticache_family}"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}
