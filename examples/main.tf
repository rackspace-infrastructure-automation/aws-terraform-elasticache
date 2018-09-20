provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.1"
  vpc_name = "ElastiCache-Test-VPC-1"
}

module "internal_zone" {
  source        = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone?ref=v.0.0.1"
  zone_name     = "example.com"
  environment   = "Development"
  target_vpc_id = "${module.vpc.vpc_id}"
}

module "security_groups" {
  source        = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=v0.0.4"
  resource_name = "ElastiCacheTestSG"
  vpc_id        = "${module.vpc.vpc_id}"
  environment   = "Development"
}

module "elasticache_memcached" {
  source                     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.0.1"
  cluster_name               = "test-memcached"
  elasticache_engine_type    = "memcached14"
  subnets                    = ["${module.vpc.private_subnets}"]
  security_group_list        = ["${module.security_groups.elastic_cache_memcache_security_group_id}"]
  evictions_threshold        = 10
  curr_connections_threshold = 500
  internal_record_name       = "memcachedconfig"
  create_route53_record      = true
  internal_zone_id           = "${module.internal_zone.internal_hosted_zone_id}"
  internal_zone_name         = "${module.internal_zone.internal_hosted_name}"

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis_multi_shard" {
  source                  = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.0.1"
  cluster_name            = "test-redis-shard"
  elasticache_engine_type = "redis40"
  redis_multi_shard       = true
  subnets                 = ["${module.vpc.private_subnets}"]
  security_group_list     = ["${module.security_groups.elastic_cache_redis_security_group_id}"]
  internal_record_name    = "multishardconfig"
  create_route53_record   = true
  internal_zone_id        = "${module.internal_zone.internal_hosted_zone_id}"
  internal_zone_name      = "${module.internal_zone.internal_hosted_name}"

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis" {
  source                     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.0.1"
  cluster_name               = "test-redis"
  elasticache_engine_type    = "redis40"
  instance_class             = "cache.m3.medium"
  redis_multi_shard          = false
  subnets                    = ["${module.vpc.private_subnets}"]
  security_group_list        = ["${module.security_groups.elastic_cache_redis_security_group_id}"]
  evictions_threshold        = 10
  curr_connections_threshold = 500
  internal_record_name       = "redisconfig"
  create_route53_record      = true
  internal_zone_id           = "${module.internal_zone.internal_hosted_zone_id}"
  internal_zone_name         = "${module.internal_zone.internal_hosted_name}"

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

output "memcached_endpoint" {
  description = "Elasticache endpoint"
  value       = "${module.elasticache_memcached.elasticache_endpoint}"
}

output "memcached_internal_r53_record" {
  description = "Internal Route 53 record FQDN for the Elasticache endpoint(s)"
  value       = "${module.elasticache_memcached.elasticache_internal_r53_record}"
}

output "redis_endpoint" {
  description = "Redis endpoint"
  value       = "${module.elasticache_redis.elasticache_endpoint}"
}

output "redis_internal_r53_record" {
  description = "Internal Route 53 record FQDN for the Elasticache endpoint(s)"
  value       = "${module.elasticache_redis.elasticache_internal_r53_record}"
}

output "redis_multi_shard_endpoint" {
  description = "Redis Multi Shard endpoint"
  value       = "${module.elasticache_redis_multi_shard.elasticache_endpoint}"
}

output "redis_multi_shard_internal_r53_record" {
  description = "Internal Route 53 record FQDN for the Elasticache endpoint(s)"
  value       = "${module.elasticache_redis_multi_shard.elasticache_internal_r53_record}"
}
