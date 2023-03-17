output "type" {
  value = "mongodb"
  description = "The type of the database (mongodb)"
  depends_on = [ibm_resource_key.mongodb_key]
}

output "host" {
  description = "The host name for the database instance"
  value = local.credentials.connection.mongodb.hosts[0].hostname
}

output "port" {
  description = "The port for the database instance"
  value = local.credentials.connection.mongodb.hosts[0].port
}

output "database_name" {
  description = "The database name for the database instance"
  value = local.credentials.connection.mongodb.database
}

output "username" {
  description = "The username for the database instance"
  value = local.credentials.connection.mongodb.authentication.username
}

output "password" {
  value = local.credentials.connection.mongodb.authentication.password
  description = "The password for the database instance"
  sensitive: true
}

output "ca_cert" {
  description = "The ca_cert used to sign the TLS certificate for the connection, if applicable"
  value = local.credentials.connection.certificate.certificate_base64
}
