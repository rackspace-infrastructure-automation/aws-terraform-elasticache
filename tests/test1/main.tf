terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.2"
  region  = "us-west-2"
}

resource "random_string" "r_string" {
  length  = 8
  lower   = true
  upper   = false
  number  = false
  special = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.9"

  vpc_name = "ElastiCache-Test-VPC-1"
}

resource "random_string" "zone_name" {
  length  = 10
  lower   = true
  upper   = false
  number  = false
  special = false
}

module "internal_zone" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone?ref=v0.0.3"

  zone_name     = "${random_string.zone_name.result}.com"
  environment   = "Development"
  target_vpc_id = module.vpc.vpc_id
}

module "security_groups" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=v0.0.5"

  resource_name = "ElastiCacheTestSG"
  vpc_id        = module.vpc.vpc_id
  environment   = "Development"
}

module "elasticache_memcached" {
  source = "../../module"

  cluster_name               = "memc-${random_string.r_string.result}"
  elasticache_engine_type    = "memcached14"
  instance_class             = "cache.m4.large"
  subnets                    = [module.vpc.private_subnets]
  security_group_list        = [module.security_groups.elastic_cache_memcache_security_group_id]
  evictions_threshold        = 10
  curr_connections_threshold = 500
  internal_record_name       = "memcachedconfig"
  create_route53_record      = true
  internal_zone_id           = module.internal_zone.internal_hosted_zone_id
  internal_zone_name         = module.internal_zone.internal_hosted_name

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis_multi_shard" {
  source = "../../module"

  cluster_name            = "redms-${random_string.r_string.result}"
  elasticache_engine_type = "redis50"
  instance_class          = "cache.m4.large"
  redis_multi_shard       = true
  subnets                 = [module.vpc.private_subnets]
  security_group_list     = [module.security_groups.elastic_cache_redis_security_group_id]
  internal_record_name    = "multishardconfig"
  create_route53_record   = true
  internal_zone_id        = module.internal_zone.internal_hosted_zone_id
  internal_zone_name      = module.internal_zone.internal_hosted_name

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis_1" {
  source = "../../module"

  cluster_name            = "red-${random_string.r_string.result}-1"
  elasticache_engine_type = "redis50"
  instance_class          = "cache.t2.medium"
  redis_multi_shard       = false
  subnets                 = [module.vpc.private_subnets]
  security_group_list     = [module.security_groups.elastic_cache_redis_security_group_id]
  internal_record_name    = "redisconfigone"
  create_route53_record   = true
  internal_zone_id        = module.internal_zone.internal_hosted_zone_id
  internal_zone_name      = module.internal_zone.internal_hosted_name

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis_2" {
  source = "../../module"

  cluster_name               = "red-${random_string.r_string.result}-2"
  elasticache_engine_type    = "redis50"
  instance_class             = "cache.m4.large"
  redis_multi_shard          = false
  subnets                    = [module.vpc.private_subnets]
  security_group_list        = [module.security_groups.elastic_cache_redis_security_group_id]
  internal_record_name       = "redisconfigtwo"
  create_route53_record      = true
  internal_zone_id           = module.internal_zone.internal_hosted_zone_id
  internal_zone_name         = module.internal_zone.internal_hosted_name
  evictions_threshold        = 10
  curr_connections_threshold = 500

  # Test single-shard, single-node, no failover
  number_of_nodes  = 1
  failover_enabled = false

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

resource "random_string" "string_19" {
  length  = 19
  lower   = true
  upper   = false
  number  = false
  special = false
}

module "elasticache_redis_constructed_cluster_name_20_chars" {
  source = "../../module"

  cluster_name            = "${random_string.string_19.result}a"
  cluster_name_version    = "${random_string.string_19.result}a"
  elasticache_engine_type = "redis50"
  instance_class          = "cache.t2.medium"
  redis_multi_shard       = false
  subnets                 = [module.vpc.private_subnets]
  security_group_list     = [module.security_groups.elastic_cache_redis_security_group_id]
}

module "elasticache_redis_constructed_cluster_name_19_chars" {
  source = "../../module"

  cluster_name            = random_string.string_19.result
  cluster_name_version    = random_string.string_19.result
  elasticache_engine_type = "redis50"
  instance_class          = "cache.t2.medium"
  redis_multi_shard       = false
  subnets                 = [module.vpc.private_subnets]
  security_group_list     = [module.security_groups.elastic_cache_redis_security_group_id]
}

