terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

locals {
  namespace = var.project_name

  msvc_orders_init_image = "ghcr.io/soat1stackgolang/msvc-orders:migs-debug-develop"
  msvc_orders_image      = "ghcr.io/soat1stackgolang/msvc-orders:debug-develop"
  msvc_payments_image    = "ghcr.io/soat1stackgolang/msvc-payments:debug-develop"
  msvc_production_image  = "ghcr.io/soat1stackgolang/msvc-production:debug-develop"

  lb_service_name_orders     = "lb-orders-svc"
  lb_service_port_orders     = 8080
  lb_service_name_production = "lb-production-svc"
  lb_service_port_production = 8082

  msvc_orders_port     = 8080  
  msvc_payments_port   = 8081  
  msvc_production_port = 8082

  msvc_orders_svc     = "msvc-orders-svc"
  msvc_payments_svc   = "msvc-payments-svc"
  msvc_production_svc = "msvc-production-svc"

  kvstore_uri         = "${var.redis_host}:${var.redis_port}"
  msvc_orders_uri     = "http://${local.msvc_orders_svc}.${local.namespace}.svc.cluster.local:${local.msvc_orders_port}"
  msvc_payments_uri   = "http://${local.msvc_payments_svc}.${local.namespace}.svc.cluster.local:${local.msvc_payments_port}"
  msvc_production_uri = "http://${local.msvc_production_svc}.${local.namespace}.svc.cluster.local:${local.msvc_production_port}"

  kvstore_db_msvc_orders     = 10
  kvstore_db_msvc_payments   = 11  
  kvstore_db_msvc_production = 12

  postgres_host     = "${var.database_host}"
  postgres_port     = "${var.database_port}"
  postgres_user     = "${var.database_username}"
  postgres_password = "${var.database_password}"
  postgres_db       = "${var.database_name}"
}


#---------------------------------------------------------------------------------------------------
#  Namespace
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "namespace" {
    yaml_body = <<YAML

apiVersion: v1
kind: Namespace
metadata:
  name: ${local.namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
    linkerd.io/inject: enabled
  labels:
    app: ${var.project_name}

YAML
}


#---------------------------------------------------------------------------------------------------
#  Secrets
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "secrets" {
    yaml_body = <<YAML

apiVersion: v1
kind: Secret
metadata:
  name: ${var.project_name}-secret
  namespace: ${local.namespace}
type: Opaque
stringData:
  DB_HOST: "${local.postgres_host}"
  DB_PORT: "${local.postgres_port}"
  DB_USER: "${local.postgres_user}"
  DB_PASSWORD: "${local.postgres_password}" 
  DB_NAME: "${local.postgres_db}"

YAML
}

#---------------------------------------------------------------------------------------------------
# Deployment Orders
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "msvc_orders_deployment" {
    yaml_body = <<YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  name: msvc-orders
  namespace: ${local.namespace}
  labels:
    app: msvc-orders
spec:
  selector:
    matchLabels:
      app: msvc-orders
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: msvc-orders
    spec:
      containers:
        - name: msvc-orders
          image: ${local.msvc_orders_image}
          imagePullPolicy: Always
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 10000
            capabilities:
              drop:
                - ALL
          resources:
            requests:
              cpu: 10m
              memory: 25Mi
            limits:
              cpu: 100m
              memory: 100Mi
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 5
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          readinessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          env:
            - name: KVSTORE_URI
              value: "${local.kvstore_uri}"
            - name: KVSTORE_DB
              value: "${local.kvstore_db_msvc_orders}"
            - name: ORDER_URI
              value: "${local.msvc_orders_uri}"
            - name: PAYMENT_URI
              value: "${local.msvc_payments_uri}"
            - name: PRODUCTION_URI
              value: "${local.msvc_production_uri}"
            - name: DB_HOST
              valueFrom:
                secretKeyRef:
                  name: ${var.project_name}-secret
                  key: DB_HOST
            - name: DB_PORT
              valueFrom:
                secretKeyRef:
                  name: ${var.project_name}-secret
                  key: DB_PORT
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: ${var.project_name}-secret
                  key: DB_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: ${var.project_name}-secret
                  key: DB_PASSWORD
            - name: DB_NAME
              valueFrom:
                secretKeyRef:
                  name: ${var.project_name}-secret
                  key: DB_NAME
          ports:
            - containerPort: 8080
              name: web
          
      restartPolicy: Always
YAML
}


resource "kubectl_manifest" "msvc_orders_service" {
    yaml_body = <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${local.msvc_orders_svc}
  namespace: ${local.namespace}
spec:
  selector:
    app: msvc-orders
  type: ClusterIP
  ports:
  - protocol: TCP
    port: ${local.msvc_orders_port}
    targetPort: 8080

YAML
}


#---------------------------------------------------------------------------------------------------
# Deployment Payments
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "msvc_payments_deployment" {
    yaml_body = <<YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  name: msvc-payments
  namespace: ${local.namespace}
  labels:
    app: msvc-payments
spec:
  selector:
    matchLabels:
      app: msvc-payments
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: msvc-payments
    spec:
      containers:
        - name: msvc-payments
          image: ${local.msvc_payments_image}
          imagePullPolicy: Always
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 10000
            capabilities:
              drop:
                - ALL
          resources:
            requests:
              cpu: 10m
              memory: 25Mi
            limits:
              cpu: 100m
              memory: 100Mi
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 5
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          readinessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          env:
            - name: KVSTORE_URI
              value: "${local.kvstore_uri}"
            - name: KVSTORE_DB
              value: "${local.kvstore_db_msvc_payments}"
            - name: ORDER_URI
              value: "${local.msvc_orders_uri}"
            - name: PAYMENT_URI
              value: "${local.msvc_payments_uri}"
            - name: PRODUCTION_URI
              value: "${local.msvc_production_uri}"
          ports:
            - containerPort: 8080
              name: web
          
      restartPolicy: Always
YAML
}


resource "kubectl_manifest" "msvc_payments_service" {
    yaml_body = <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${local.msvc_payments_svc}
  namespace: ${local.namespace}
spec:
  selector:
    app: msvc-payments
  type: ClusterIP
  ports:
  - protocol: TCP
    port: ${local.msvc_payments_port}
    targetPort: 8080

YAML
}



#---------------------------------------------------------------------------------------------------
# Deployment Production
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "msvc_production_deployment" {
    yaml_body = <<YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  name: msvc-production
  namespace: ${local.namespace}
  labels:
    app: msvc-production
spec:
  selector:
    matchLabels:
      app: msvc-production
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: msvc-production
    spec:
      containers:
        - name: msvc-production
          image: ${local.msvc_production_image}
          imagePullPolicy: Always
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 10000
            capabilities:
              drop:
                - ALL
          resources:
            requests:
              cpu: 10m
              memory: 25Mi
            limits:
              cpu: 100m
              memory: 100Mi
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 5
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          readinessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          env:
            - name: KVSTORE_URI
              value: "${local.kvstore_uri}"
            - name: KVSTORE_DB
              value: "${local.kvstore_db_msvc_production}"
            - name: ORDER_URI
              value: "${local.msvc_orders_uri}"
            - name: PAYMENT_URI
              value: "${local.msvc_payments_uri}"
            - name: PRODUCTION_URI
              value: "${local.msvc_production_uri}"
          ports:
            - containerPort: 8080
              name: web
          
      restartPolicy: Always
YAML
}


resource "kubectl_manifest" "msvc_production_service" {
    yaml_body = <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${local.msvc_production_svc}
  namespace: ${local.namespace}
spec:
  selector:
    app: msvc-production
  type: ClusterIP
  ports:
  - protocol: TCP
    port: ${local.msvc_production_port}
    targetPort: 8080

YAML
}



#---------------------------------------------------------------------------------------------------
# Load Balancers
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "lb-orders" {
    yaml_body = <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${local.lb_service_name_orders}
  namespace: ${local.namespace}
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-name: ${local.lb_service_name_orders}
    service.beta.kubernetes.io/aws-load-balancer-type: nlb

spec:
  selector:
    app: msvc-orders
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: ${local.lb_service_port_orders}
    targetPort: 8080

YAML
}


resource "kubectl_manifest" "lb-production" {
    yaml_body = <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${local.lb_service_name_production}
  namespace: ${local.namespace}
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-name: ${local.lb_service_name_production}
    service.beta.kubernetes.io/aws-load-balancer-type: nlb

spec:
  selector:
    app: msvc-production
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: ${local.lb_service_port_production}
    targetPort: 8080

YAML
}