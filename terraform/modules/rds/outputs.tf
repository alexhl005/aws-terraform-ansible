output "rds_endpoint" {
  description = "Endpoint de la base de datos Postgres"
  value       = aws_db_instance.main.address
}

#output "rds_endpoint" {
#  value = aws_rds_cluster.main.endpoint
#}
#
#output "reader_endpoint" {
#  value = aws_rds_cluster.main.reader_endpoint
#}