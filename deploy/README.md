# deploy/ — Sealos 集群镜像构建上下文（手动构建）

GitHub Actions（`.github/workflows/build.yml`）**只构建并推送 app 镜像** `ghcr.io/vlee0203/proxy-service`（multi-arch，sha + latest）。**sealos 集群镜像不在 CI 构建**——本目录是手动 `sealos build` 集群镜像的构建上下文。

manifests 采用 **Sealos Cloud app-deploy-manager 格式**（资源名 `dify-marketplace-proxy`，`cloud.sealos.io/app-deploy-manager` 标签、`wildcard-cert` TLS、CORS），`sealos run` 部署到 Sealos Cloud 后由应用管理器托管。

## 目录结构

```
deploy/
├── Kubefile              # FROM scratch + COPY registry/manifests/scripts + ENV + CMD bash scripts/init.sh
├── manifests/
│   ├── deploy.yaml.tmpl  # Deployment(app-deploy-manager 标签 + originImageName) + Service
│   └── ingress.yaml.tmpl # Ingress：host=dify-marketplace-proxy.{{ .cloudDomain }}，wildcard-cert TLS，CORS
└── scripts/
    └── init.sh           # kubectl apply 渲染后的 manifests/*.yaml
```

## 两类占位符（构建期 vs 运行期）

| 占位符 | 何时替换 | 谁替换 |
|--------|---------|--------|
| `IMAGE_TAG` | 手动 build 集群镜像前 | `sed`（替换成 app 镜像 tag，如 `latest` 或 sha） |
| `{{ .cloudDomain }}` / `{{ .target }}` / `{{ .httpsProxy }}` | 运行期（sealos run） | sealos 的 `.tmpl` 渲染（sealctl render 用 ENV 执行 Go 模板） |

## 手动构建 + 部署 sealos 集群镜像

```bash
# 前提：CI 已把 app 镜像推到 ghcr.io/vlee0203/proxy-service:latest

cd deploy
# 1) 把 manifests 里的 IMAGE_TAG 替换成实际 app 镜像 tag
find manifests -name '*.tmpl' -exec sed -i "s|IMAGE_TAG|latest|g" {} +
# 2) sealos 登录 ghcr（拉取 app 镜像需要）
sudo sealos login -u <github-user> -p <token> ghcr.io
# 3) 构建 + 推送集群镜像（按需分架构 + manifest，或单架构）
sudo sealos build -t ghcr.io/vlee0203/sealos-cloud-proxy-service:latest -f Kubefile .
sudo sealos push  ghcr.io/vlee0203/sealos-cloud-proxy-service:latest
# 4) 部署到 Sealos Cloud 集群
sealos run ghcr.io/vlee0203/sealos-cloud-proxy-service:latest --env cloudDomain=<你的域名>
```

`.tmpl` 渲染：`sealos run` 的 MountRootfs 阶段用 ENV（Kubefile ENV + `--env`）把 `manifests/*.tmpl` 渲染成同名 `.yaml` 并删 `.tmpl`，再由 init.sh `kubectl apply`。

## Sealos Cloud app 格式要点

- 资源名 `dify-marketplace-proxy`（镜像才是 `proxy-service`）
- `cloud.sealos.io/app-deploy-manager` 标签 + `originImageName` 注解 → Sealos Cloud 应用管理器托管
- Ingress TLS `secretName: wildcard-cert`（Sealos Cloud 自带通配证书）+ CORS 注解
- `automountServiceAccountToken: false`、resources、rollingUpdate
- 无 namespace（按 apply 上下文；Sealos Cloud 进当前用户命名空间）

## 卸载

```bash
kubectl delete deployment,service,ingress dify-marketplace-proxy
```
