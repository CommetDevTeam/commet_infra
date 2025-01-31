# 作業手順

## ProxmoxでのVMの作成

Proxmoxが動作しているホスト上で、以下のコマンドを実行し、VMを作成する。

```shell
/bin/bash <(curl -s "https://raw.githubusercontent.com/CommetDevTeam/commet_infra/main/onp-k8s/cluster-boot-up/scripts/proxmox-host-terminal/deploy-vm.sh") "main"
```

<details>
<summary>Nodeを追加する場合</summary>
以下のファイルにホスト名をを追記する。

- /onp-k8s/cluster-boot-up/ansible/hosts/k8s-servers/inventory
- /onp-k8s/cluster-boot-up/scripts/proxmox-host-terminal/deplot-vm.sh

</details>

## Terraformの実行

### 前準備

Terraformのvariablesを設定してください。

### Secretの作成

#### ArgocdでSSOするためのSecretを作成

GCP SecretManagerにアクセスして、以下の名前でSecretを作成してください。

- argocd_github_oauth_app_secret

`onp-k8s/manifests/argocd-helm-chart-values.yaml`の`config.cm.dex.config`内のclient IDを設定してください。

#### Cloudflare ApplicationでGithub SSOをするためのSecretを作成

GCP SecretManagerにアクセスして、以下の名前でSecretを作成してください。

- cloudflare_sso_github_client_id
- cloudflare_sso_github_client_secret
-

#### Github Actionsでterraformを実行するためのSecretを作成

`https://github.com/CommetDevTeam/commet_infra/settings/secrets/actions`
にアクセスして、以下の名前でSecretを作成してください。

- CLOUDFLARE_API_TOKEN

<details>
<summary>ローカルでTerraformを実行する場合</summary>

- 以下のコマンドを実行してkubeconfigを取得する。

 ```bash
/bin/bash <(curl -s "https://raw.githubusercontent.com/CommetDevTeam/commet_infra/main/onp-k8s/cluster-boot-up/scripts/local-terminal/obtain-kubeconfig.sh") "main"
 ```

- `provider.tf`内のCloudflareとkubernetes Providerのコメントアウトを解除する。
- CloudflareのAPI TOKENを指定する。
- gcloud cliでログインして、`gcloud auth application-default login`を実行。

</details>

#### Cloudflare Tunnelに使用するcert.pemを作成する。

以下のコマンドをcontrol planeで実行する。URLが表示されるので、ログインを行う。

```shell
bash -c '/bin/bash <(curl -s "https://raw.githubusercontent.com/CommetDevTeam/commet_infra/main/onp-k8s/cluster-boot-up/scripts/local-terminal/obtain-cloudflare-cert.sh") "main"'
kubectl create secret generic -n cloudflared-tunnel-exits cloudflared-tunnel-cert --from-file=TUNNEL_CREDENTIAL=${HOME}/.cloudflared/cert.pem
```

## ArgoCD

すべてのサービスをargocdを使って管理している。
github organization の peopleから 所属する組織を表示するためにpublicnに変更する必要がある。

### ログインする

```shell
argocd.commet.jp
```

### 初期パスワードの取得

ユーザーー名はadmin
パスワードは以下のコマンドで確認する。

```shell
kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 設定ファイルの変更を行う場合

Terraformで行うと時間がかかるため、直接変更する。

```shell
kubectl -n argocd edit configmap argocd-cm
```

## Cloudflare Tunnel

1. Cloudflaredに必要な tunnel certをsecretとして注入する。

```shell
/bin/bash <(curl -s "https://raw.githubusercontent.com/KanameImaichi/commet_infra/main/onp-k8s/cluster-boot-up/scripts/local-terminal/deploy-cloudflared-resource.sh") "main"
```

1. GitHub Actions で実行される terraform コマンドの実行に必要な `kubeconfig` を `seichi_infra` リポジトリの Actions
   secrets として設定します。

   https://github.com/CommetDevTeam/commet_infra/settings/secrets/actions にアクセスし
   `Repository secrets > TF_VAR_ONP_K8S_KUBECONFIG` に下記コマンドの標準出力を注入してください。
    ```bash
    ssh cloudinit@192.168.0.11 "cat ~/.kube/config" 
    ```

# External Secret Operator

/bin/bash <(curl
-s "https://raw.githubusercontent.com/KanameImaichi/commet_infra/main/onp-k8s/cluster-boot-up/scripts/local-terminal/obtain-cloudflare-cert.sh") "
main"
GCPのSecretManagerでGithub Actions Self Hosted などのSecretの管理取得を行っている。
サービスアカウントキーを使用してGCPへの認証を行うためSecretを追加する。

```shell
kubectl create namespace server-list
kubectl apply -f gcpsm-secret.yaml -n server-list 
```

サンプルは以下の通り。

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gcpsm-secret
  namespace: external-secrets
  labels:
    type: gcpsm
type: Opaque
stringData:
  secret-access-credentials: |
    {
    "YOUR JSON SERVICE ACCOUNT KEY"
    }


```

# Grafana

以下のコマンドでパスワードを取得する

```shell
kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-user}' | base64 -d; echo
kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```

# Special Thanks

https://github.com/GiganticMinecraft/seichi_infra