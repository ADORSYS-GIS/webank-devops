resource "kubernetes_secret" "rds_secret" {
  metadata {
    name      = "rds-secret"
    namespace = "webank"
  }
  data = {
    password = base64encode(var.db_password)
  }
}

