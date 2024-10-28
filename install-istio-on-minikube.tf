# Configure Terraform backend
terraform {
 backend "local" {}
}

# Install Helm provider
provider "helm" {
 kubernetes {
  host   = "localhost:8080"
  namespace = "default"
  config_context = "minikube"
  token = "minikube"
 }
}

# Install Istio
resource "helm_release" "istio" {
 name    = "istio"
 namespace = "istio-system"
 repository = "https://istio.io/charts"
 chart   = "istio"
 version   = "1.17.3"
 set {
  name = "values.global.hub"
  value = "docker.io/istio"
 }
 set {
  name = "values.global.tag"
  value = "1.17.3"
 }
 set {
  name = "values.pilot.enabled"
  value = true
 }
 set {
  name = "values.global.meshConfig.defaultConfig.accessLogFormat"
  value = "DEFAULT"
 }
 set {
  name = "values.global.meshConfig.defaultConfig.accessLogFormat"
  value = "ALL"
 }
 set {
  name = "values.gateways.istio-ingressgateway.enabled"
  value = true
 }
 set {
  name = "values.gateways.istio-ingressgateway.hosts"
  value = ["ingress.istio.local"]
 }
 set {
  name = "values.gateways.istio-ingressgateway.type"
  value = "LoadBalancer"
 }
 set {
  name = "values.gateways.istio-ingressgateway.ports"
  value = ["15443", "80", "443"]
 }
 set {
  name = "values.gateways.istio-ingressgateway.k8s.service.annotations.\"external-dns.alpha.kubernetes.io/hostname\""
  value = "ingress.istio.local"
 }
 set {
  name = "values.gateways.istio-ingressgateway.k8s.service.annotations.\"external-dns.alpha.kubernetes.io/ttl\""
  value = "300"
 }
 set {
  name = "values.gateways.istio-ingressgateway.k8s.service.annotations.\"external-dns.alpha.kubernetes.io/owner\""
  value = "istio-ingressgateway"
 }
}

# Deploy Httpd sample application
resource "helm_release" "httpd" {
 name    = "httpd"
 namespace = "default"
 repository = "https://hub.docker.com/r/httpd"
 chart   = "stable/httpd"
 version   = "3.0.0"
}

# Wait for Istio to become ready
resource "null_resource" "istio_ready" {
 provisioner {
  local-exec {
   command = "kubectl -n istio-system get pods -l app=istio-pilot -o jsonpath='{.items[*].status.conditions[*].type}' | grep Ready | grep True"
  }
 }
}

# Install Istio Ingress Gateway
resource "null_resource" "ingressgateway" {
 provisioner {
  local-exec {
   command = "kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/ingress/http-ingress/http-ingress-gateway.yaml"
  }
 }
 depends_on = [helm_release.istio, helm_release.httpd]
}

# Ensure Httpd service is accessible via Ingress Gateway
resource "null_resource" "httpd_ingress" {
 provisioner {
  local-exec {
   command = "kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/ingress/http-ingress/http-ingress-service.yaml"
  }
 }
 depends_on = [null_resource.ingressgateway]
}

# Wait for Ingress Gateway to become ready
resource "null_resource" "ingressgateway_ready" {
 provisioner {
  local-exec {
   command = "kubectl -n istio-system get pods -l app=ingressgateway -o jsonpath='{.items[*].status.conditions[*].type}' | grep Ready | grep True"
  }
 }
}

# Output the ingress gateway address
output "ingress_address" {
 value = "ingress.istio.local"
}
