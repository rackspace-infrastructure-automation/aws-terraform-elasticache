terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

resource "random_string" "r_string" {
  length  = 8
  lower   = true
  number  = false
  special = false
  upper   = false
}

resource "random_string" "r_string_40" {
  length  = 40
  lower   = true
  number  = false
  special = false
  upper   = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.1"

  name = "ElastiCache-Test-VPC-1"
}

resource "random_string" "zone_name" {
  length  = 10
  lower   = true
  number  = false
  special = false
  upper   = false
}

module "internal_zone" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone?ref=v0.12.1"

  environment = "Development"
  name        = "${random_string.zone_name.result}.com"
  vpc_id      = module.vpc.vpc_id
}

module "security_groups" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-security_group?ref=v0.12.1"

  environment = "Development"
  name        = "ElastiCacheTestSG"
  vpc_id      = module.vpc.vpc_id
}
############################################################
# NEW 0.12.2 VERSION deprecating `name` and `name_version` #
############################################################

module "elasticache_redis_constructed_cluster_name_50_chars" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.1"

  elasticache_engine_type       = "redis506"
  instance_class                = "cache.t2.medium"
  cluster_name                  = "${random_string.r_string_40.result}abcdefghij" # can accept up to 50 characters
  replication_group_description = random_string.r_string_40.result # can accept up to 40 characters
  redis_multi_shard             = false
  security_groups               = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                       = module.vpc.private_subnets
}

#############################
# PRE 0.12.1 VERSION FORMAT #
#############################

module "elasticache_memcached" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.1"

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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.1"

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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.1"

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

# single-shard, single-node, no failover
module "elasticache_redis_2" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.1"

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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.1"

  elasticache_engine_type = "redis506"
  instance_class          = "cache.t2.medium"
  name                    = "${random_string.string_19.result}a"
  name_version            = "${random_string.string_19.result}a"
  redis_multi_shard       = false
  security_groups         = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                 = module.vpc.private_subnets
}

module "elasticache_redis_constructed_cluster_name_19_chars" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-elasticache.git?ref=v0.12.1"

  elasticache_engine_type = "redis506"
  instance_class          = "cache.t2.medium"
  name                    = random_string.string_19.result
  name_version            = random_string.string_19.result
  redis_multi_shard       = false
  security_groups         = [module.security_groups.elastic_cache_redis_security_group_id]
  subnets                 = module.vpc.private_subnets
}

