output "elasticache_endpoint" {
  description = "Elasticache endpoint address"
  value = element(
    coalescelist(
      aws_elasticache_replication_group.redis_rep_group.*.primary_endpoint_address,
      aws_elasticache_replication_group.redis_multi_shard_rep_group.*.configuration_endpoint_address,
      aws_elasticache_cluster.cache_cluster.*.configuration_endpoint,
      ["novalue"],
    ),
    0,
  )
}

output "elasticache_internal_r53_record" {
  description = "Internal Route 53 record FQDN for the Elasticache endpoint(s)"
  value       = aws_route53_record.internal_record_set_elasticache.*.fqdn
}

