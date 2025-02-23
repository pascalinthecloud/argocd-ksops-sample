variable "argocd_gpg_key" {
  description = "GPG key for SOPS (needs to be base64 encoded)"
  type        = string
  sensitive   = true
}