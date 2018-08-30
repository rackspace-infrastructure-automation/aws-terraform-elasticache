output "elasticache_endpoint" {
  description = "Elasticache endpoint address"
  value       = "${element(coalescelist(aws_elasticache_replication_group.redis_rep_group.*.primary_endpoint_address, aws_elasticache_replication_group.redis_multi_shard_rep_group.*.configuration_endpoint_address, aws_elasticache_cluster.cache_cluster.*.configuration_endpoint, list("novalue")),0)}"
}
