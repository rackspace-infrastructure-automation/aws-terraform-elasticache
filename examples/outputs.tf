output "memcached_endpoint" {
  description = "Elasticache endpoint"
  value       = module.elasticache_memcached.elasticache_endpoint
}

output "redis_1_endpoint" {
  description = "Redis endpoint"
  value       = module.elasticache_redis_1.elasticache_endpoint
}

output "redis_2_endpoint" {
  description = "Redis endpoint"
  value       = module.elasticache_redis_2.elasticache_endpoint
}

output "redis_multi_shard_endpoint" {
  description = "Redis Multi Shard endpoint"
  value       = module.elasticache_redis_multi_shard.elasticache_endpoint
}

