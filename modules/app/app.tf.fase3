terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

#provider "kubectl" {
#  host                   = var.cluster_endpoint
#  cluster_ca_certificate = var.cluster_ca_certificate
#  token                  = var.cluster_token
#  load_config_file       = false
#}

#data "kubectl_filename_list" "manifests" {
#    pattern = "./raw-manifests/*.yaml"
#}

#resource "kubectl_manifest" "test" {
#    count = length(data.kubectl_filename_list.manifests.matches)
#    yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
#}


#---------------------------------------------------------------------------------------------------
#  Namespace
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "namespace" {
    yaml_body = <<YAML

apiVersion: v1
kind: Namespace
metadata:
  name: ${var.project_name}
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
  namespace: ${var.project_name}
type: Opaque
stringData:
  DB_HOST: "${var.database_host}"
  DB_PORT: "${var.database_port}"
  DB_USER: "${var.database_username}"
  DB_PASSWORD: "${var.database_password}" 
  DB_NAME: "${var.database_name}"

YAML
}

#---------------------------------------------------------------------------------------------------
# Deployment 
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "deployment" {
    yaml_body = <<YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${var.project_name}
  namespace: ${var.project_name}
  labels:
    app: ${var.project_name}
spec:
  selector:
    matchLabels:
      app: ${var.project_name}
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: ${var.project_name}
    spec:
      containers:
        - name: ${var.project_name}
          #image: ghcr.io/soat1stackgolang/tech-challenge:main-develop
          image: ghcr.io/soat1stackgolang/tech-challenge:debug-develop
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
              port: ${var.lb_service_port}
            initialDelaySeconds: 5
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          readinessProbe:
            tcpSocket:
              port: ${var.lb_service_port}
            initialDelaySeconds: 5
            timeoutSeconds: 2
            successThreshold: 1
            failureThreshold: 3
            periodSeconds: 10
          env:
            - name: PORT
              value: "${var.lb_service_port}"
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
            - containerPort: ${var.lb_service_port}
              name: web
          
      restartPolicy: Always
YAML
}

#---------------------------------------------------------------------------------------------------
# Service
#---------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "service" {
    yaml_body = <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${var.lb_service_name}
  namespace: ${var.project_name}
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-name: ${var.lb_service_name}
    service.beta.kubernetes.io/aws-load-balancer-type: nlb

spec:
  selector:
    app: ${var.project_name}
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: ${var.lb_service_port}
    targetPort: ${var.lb_service_port}

YAML
}