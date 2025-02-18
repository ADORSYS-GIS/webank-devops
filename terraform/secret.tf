resource "kubernetes_secret" "rds_secret" {
  metadata {
    name      = "rds-secret"
    namespace = "webank"
  }
  data = {
    password = var.db_password
  }
}

resource "kubernetes_secret" "webank_prs_secret" {
  metadata {
    name      = "webank-prs-secret"
    namespace = "webank"
  }
  data = {
    SERVER_PRIVATE_KEY_JSON = var.prs_private_key
    SERVER_PUBLIC_KEY_JSON =  var.prs_public_key
    JWT_ISSUER = var.jwt_issuer
    JWT_EXPIRATION_TIME_MS = var.jwt_expiration
    TWILIO_ACCOUNT_SID = var.twilio_account_sid
    TWILIO_AUTH_TOKEN = var.twilio_auth_token
    TWILIO_PHONE_NUMBER = var.twilio_phone_number
    OTP_SALT = var.otp_salt
  }
}

resource "kubernetes_secret" "webank_obs_secret" {  
  metadata {
    name      = "webank-obs-secret"
    namespace = "webank"
  }
  data = {
    SERVER_PRIVATE_KEY_JSON = var.prs_private_key
    SERVER_PUBLIC_KEY_JSON =  var.prs_public_key
    JWT_ISSUER = var.jwt_issuer
    JWT_EXPIRATION_TIME_MS = var.jwt_expiration

}
}