resource "kubernetes_secret" "rds_secret" {
  metadata {
    name      = "rds-secret"
    namespace = "webank"
  }
  data = {
    password = var.db_password
  }
}