# ArgoCD KSOPS Sample

This repository provides an example of deploying ArgoCD on a Kubernetes cluster using KSOPS and Kustomize. Additionally, it includes a Terraform example (folder /terraform) using Terraform Helm Provider.

## Prerequisites

- k8s cluster
- helm & kubectl
- gpg (for generating encryption key)
- KSOPS (for encrypting secrets)

## Preparation

1. **Create key for encryption**
    ```bash
    export GPG_NAME="test-key"
    export GPG_COMMENT="key for demonstration"
    
    gpg --batch --full-generate-key <<EOF
        %no-protection
        Key-Type: 1
        Key-Length: 4096
        Subkey-Type: 1
        Subkey-Length: 4096
        Expire-Date: 0
        Name-Comment: ${GPG_COMMENT}
        Name-Real: ${GPG_NAME}
    EOF
    ```
    <br>

2. **Getting the key ID**
    ```bash
    export GPG_KEY_ID=$(gpg --list-secret-keys "${GPG_NAME}" 2</dev/null | awk 'NR==2' | xargs)
    ```
    <br>
3. **Export the private key**

    The private key is used to decrypt the secrets. It should be kept secret and not stored in the repository. It should be stored in a secret manager like AWS Secrets Manager or HashiCorp Vault. 

    ```bash
    gpg --export-secret-keys --armor "${GPG_KEY_ID}" | sed -z '$ s/\n$//' > .sops.priv.key
    ``` 
    <details>
    <summary>When using Terraform</summary>    

    ```bash
    export TF_VAR_argocd_gpg_key=$(gpg --export-secret-keys --armor "${GPG_KEY_ID}" | sed -z '$ s/\n$//' | base64 -w 0)
     ```
    </details>
    <br>
 
4. **Export the public key**

    The public key is used to encrypt the secrets. It is safe to store it in the repository.
    ```bash
    gpg --export --armor "${GPG_KEY_ID}" > .sops.pub.key
    ```


## Installation
1. **Add helm repo**

    ```bash
    helm repo add argo https://argoproj.github.io/argo-helm
    ```

2. **Customize values.yaml**

    Customize the values.yaml file to your needs.<br>
    Possible values can be seen here: [ArgoCD Helm Chart](https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml)

3. **Install ArgoCD:**
    ```bash
    helm install argocd -n argocd --create-namespace argo/argo-cd -f values.yaml \
    --set-json 'extraObjects=[{"apiVersion": "v1", "data": {"sops.asc": "'$(base64 -w 0 .sops.priv.key)'"}, "kind": "Secret", "metadata": {"name": "sops-gpg"}, "type": "Opaque"}]'
    ```

## Installation using Terraform
1. **Customize values.yaml**
    
2. **Run Terraform**
    ```bash
    cd terraform
    terraform init
    (terraform plan)
    terraform apply
    ```
## Usage

1. **Access the ArgoCD UI:**

    ```sh
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

    Open your browser and navigate to `https://localhost:8080`.

2. **Login to ArgoCD:**

    Get the initial password for the `admin` user:

    ```sh
    kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
    ```

    Use `admin` as the username and the password retrieved above to login.

3. **Deploy Applications:**

    Use the ArgoCD UI or CLI to create and manage your applications.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [ArgoCD](https://argo-cd.readthedocs.io/)
- [KSOPS](https://github.com/viaduct-ai/kustomize-sops)
- [Kustomize](https://kustomize.io/)
