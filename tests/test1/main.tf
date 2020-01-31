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
  number  = false
  special = false
  upper   = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=master"

  cidr_range          = "172.18.0.0/16"
  name                = "ElastiCache-Test-VPC-1"
  private_cidr_ranges = ["172.18.0.0/21", "172.18.8.0/21"]
  public_cidr_ranges  = ["172.18.168.0/22", "172.18.172.0/22"]
}

resource "random_string" "zone_name" {
  length  = 10
  lower   = true
  number  = false
  special = false
  upper   = false
}

module "internal_zone" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone?ref=master"

  environment = "Development"
  name        = "${random_string.zone_name.result}.com"
  vpc_id      = module.vpc.vpc_id
}

module "security_groups" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=master"

  environment = "Development"
  name        = "ElastiCacheTestSG"
  vpc_id      = module.vpc.vpc_id
}

module "elasticache_memcached" {
  source = "../../module"

  create_internal_zone_record = true
  curr_connections_threshold  = 500
  elasticache_engine_type     = "memcached14"
  evictions_threshold         = 10
  instance_class              = "cache.m4.large"
  internal_record_name        = "memcachedconfig"
  internal_zone_id            = module.internal_zone.internal_hosted_zone_id
  internal_zone_name          = module.internal_zone.internal_hosted_name
  name                        = "memc-${random_string.r_string.result}"
  security_groups             = [module.security_groups.elastic_cache_memcache_security_group_id]
  subnets                     = module.vpc.private_subnets

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis_multi_shard" {
  source = "../../module"

  create_internal_zone_record = true
  elasticache_engine_type     = "redis506"
  instance_class              = "cache.m4.large"
  internal_record_name        = "multishardconfig"
  internal_zone_id            = module.internal_zone.internal_hosted_zone_id
  internal_zone_name          = module.internal_zone.internal_hosted_name
  name                        = "redms-${random_string.r_string.result}"
  redis_multi_shard           = true
  security_groups             = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                     = module.vpc.private_subnets

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis_1" {
  source = "../../module"

  create_internal_zone_record = true
  elasticache_engine_type     = "redis506"
  instance_class              = "cache.t2.medium"
  internal_record_name        = "redisconfigone"
  internal_zone_id            = module.internal_zone.internal_hosted_zone_id
  internal_zone_name          = module.internal_zone.internal_hosted_name
  name                        = "red-${random_string.r_string.result}-1"
  redis_multi_shard           = false
  security_groups             = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                     = module.vpc.private_subnets

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "elasticache_redis_2" {
  source = "../../module"

  create_internal_zone_record = true
  curr_connections_threshold  = 500
  elasticache_engine_type     = "redis506"
  evictions_threshold         = 10
  failover_enabled            = false
  instance_class              = "cache.m4.large"
  internal_record_name        = "redisconfigtwo"
  internal_zone_id            = module.internal_zone.internal_hosted_zone_id
  internal_zone_name          = module.internal_zone.internal_hosted_name
  name                        = "red-${random_string.r_string.result}-2"
  number_of_nodes             = 1
  redis_multi_shard           = false
  security_groups             = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                     = module.vpc.private_subnets

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

resource "random_string" "string_19" {
  length  = 19
  lower   = true
  number  = false
  special = false
  upper   = false
}

module "elasticache_redis_constructed_cluster_name_20_chars" {
  source = "../../module"

  elasticache_engine_type = "redis506"
  instance_class          = "cache.t2.medium"
  name                    = "${random_string.string_19.result}a"
  name_version            = "${random_string.string_19.result}a"
  redis_multi_shard       = false
  security_groups         = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                 = module.vpc.private_subnets
}

module "elasticache_redis_constructed_cluster_name_19_chars" {
  source = "../../module"

  elasticache_engine_type = "redis506"
  instance_class          = "cache.t2.medium"
  name                    = random_string.string_19.result
  name_version            = random_string.string_19.result
  redis_multi_shard       = false
  security_groups         = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                 = module.vpc.private_subnets
}

