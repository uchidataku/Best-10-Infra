terraform {
  required_providers {
    google = {
      version = "~> 3.24"
    }

    kubernetes = {
      version = "2.16.1"
    }
  }
}


/*
  Namespaces
*/
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "best-10-${var.environment}"
  }
}

/*
  Ingresses
*/
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    namespace = kubernetes_namespace.namespace.metadata.0.name
    name      = "best-10-${var.environment}-ingress"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = var.global_ip.name
      "kubernetes.io/ingress.allow-http"            = false
    }
  }

  spec {
    tls {
      secret_name = "${var.project_name}-${var.environment}-tls-secret"
    }

    default_backend {
      service {
        name = kubernetes_service.service.metadata.0.name
        port {
          number = 3000
        }
      }
    }
  }
}

/*
  Services
*/
resource "kubernetes_service" "service" {
  metadata {
    namespace = kubernetes_namespace.namespace.metadata.0.name
    name      = "${var.project_name}-${var.environment}"
  }

  spec {
    selector = {
      app = kubernetes_deployment.deployment.metadata.0.name
    }

    port {
      name        = "app"
      port        = 3000
      target_port = 3000
    }

    type = "NodePort"
  }
}

/*
  Deployments
*/
resource "kubernetes_deployment" "deployment" {
  metadata {
    namespace = kubernetes_namespace.namespace.metadata.0.name
    name      = "${var.project_name}-${var.environment}"
  }

  spec {
    selector {
      match_labels = {
        app = "${var.project_name}-${var.environment}"
      }
    }

    strategy {
      rolling_update {
        max_unavailable = 0
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.project_name}-${var.environment}"
        }
      }

      spec {
        container {
          name    = "app"
          image   = var.app_image_url
          command = ["bundle", "exec", "puma", "-C", "config/puma.rb"]

          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
          }

          port {
            container_port = 3000
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata.0.name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.app_secret.metadata.0.name
            }
          }
        }
      }
    }
  }
}

/*
  Cron jobs
*/


/*
  Config maps
*/
resource "kubernetes_config_map" "app_config" {
  metadata {
    namespace = kubernetes_namespace.namespace.metadata.0.name
    name      = "${var.project_name}-${var.environment}-app-config"
  }

  data = {
    "RAILS_ENV"              = var.rails_env
    "DATABASE_HOST"          = var.database_host
    "DATABASE_NAME"          = var.database_name
    "DATABASE_USERNAME"      = var.database_username
#    "APP_HOST"               = "${var.subdomain_name}.${var.domain_name}"
    "APP_HOST"               = var.domain_name
    "GCP_PROJECT_NAME"       = var.project_name
    "DEFAULT_ADMIN_USERNAME" = var.default_admin_username
    "RAILS_LOG_TO_STDOUT"    = "true"
  }
}

/*
  Secrets
*/
resource "kubernetes_secret" "app_secret" {
  metadata {
    namespace = kubernetes_namespace.namespace.metadata.0.name
    name      = "${var.project_name}-${var.environment}-app-secret"
  }

  data = {
    "DATABASE_PASSWORD"      = var.database_password
    "RAILS_MASTER_KEY"       = var.rails_master_key
    "SENTRY_DSN"             = var.sentry_dsn
    "DEFAULT_ADMIN_PASSWORD" = var.default_admin_password
  }
}

resource "kubernetes_secret" "tls_secret" {
  type = "kubernetes.io/tls"

  metadata {
    namespace = kubernetes_namespace.namespace.metadata.0.name
    name      = "${var.project_name}-${var.environment}-tls-secret"
  }
  data = {
    "tls.crt" = var.tls_certificate
    "tls.key" = var.tls_certificate_key
  }
}