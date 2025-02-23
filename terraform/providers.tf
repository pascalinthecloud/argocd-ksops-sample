terraform {
  required_version = "~> 1.10.5"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

provider "helm" {
  kubernetes {
    client_certificate     = base64decode(ovh_cloud_project_kube.test_cluster.kubeconfig_attributes[0].client_certificate)
    client_key             = base64decode(ovh_cloud_project_kube.test_cluster.kubeconfig_attributes[0].client_key)
    cluster_ca_certificate = base64decode(ovh_cloud_project_kube.test_cluster.kubeconfig_attributes[0].cluster_ca_certificate)
    host                   = ovh_cloud_project_kube.test_cluster.kubeconfig_attributes[0].host
  }
  # kubernetes {
  #     config_path = "../kubeconfig.yml"
  #   }
}
