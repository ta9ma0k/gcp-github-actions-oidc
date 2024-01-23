# GithubActionsでOIDC連携でGCPのサービスアカウントへログインするサンプル

## gcloudで構築する

### 有効化するAPI

- iam.googleapis.com
- cloudresourcemanager.googleapis.com
- iamcredentials.googleapis.com
- sts.googleapis.com

### 必要なロール

- ID プール管理者（roles/iam.workloadIdentityPoolAdmin）
- サービスアカウント管理者（roles/iam.serviceAccountAdmin）

### gcloud

```
# プールを作成
gcloud iam workload-identity-pools create "<任意のID>" \
  --project="<プロジェクトID>" \
  --location="global"

# プロバイダを作成
gcloud iam workload-identity-pools providers create-oidc "<任意のID>" \
  --project="<プロジェクトID>" \
  --location="global" \
  --workload-identity-pool="<プールID>" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor" \
  --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam service-accounts add-iam-policy-binding \
  "<サービスアカウントのメールアドレス>" \
  --project="<プロジェクトID>" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/<プロジェクト番号>/locations/global/workloadIdentityPools/<プールID>/attribute.repository/<GitHubユーザー名>/<GitHubリポジトリ名>"
```

## Github Actions sample

```
name: Auth Gcp

on:
  push:
    branches:
      - main

jobs:
  auth-gcp:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v3
      - id: 'auth'
        name: 'Authenticate to GCP'
        uses: google-github-actions/auth@v1
        with:
          service_account: service_account_id
          workload_identity_provider: workload_identity_provider_name
```
