resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.4"
  lint             = true
  namespace        = "argocd"
  create_namespace = true
  values = [
    file("${path.module}/../values.yaml")
  ]
  set_sensitive {
    name  = "extraObjects[0]"
    value = <<EOT
apiVersion: v1
data:
  sops.asc: ${var.argocd_gpg_key} # needs to be a base64 encoded GPG key
kind: Secret
metadata:
  name: sops-gpg
type: Opaque
EOT
    type  = "auto"
  }
}
