# deploy/

proxy-service 的 sealos 集群镜像构建上下文（手动 `sealos build`）。CI（`../.github/workflows/build.yml`）只构建 app 镜像。

## 构建 + 部署

```bash
cd deploy
# IMAGE_TAG 替换成实际 app 镜像 tag（如 latest）
find manifests -name '*.tmpl' -exec sed -i 's|IMAGE_TAG|latest|g' {} +
# 登录 ghcr（拉取 app 镜像打包；镜像 public 可省略）
sudo sealos login -u <github-user> -p <token> ghcr.io
# 构建并推送集群镜像（app 镜像自包含打包进 registry/）
sudo sealos build -t ghcr.io/vlee0203/sealos-cloud-proxy-service:latest -f Kubefile .
sudo sealos push  ghcr.io/vlee0203/sealos-cloud-proxy-service:latest
# 部署（cloudDomain 拼 Ingress 域名）
sealos run ghcr.io/vlee0203/sealos-cloud-proxy-service:latest --env cloudDomain=<域名>
```

## 卸载

```bash
kubectl delete deployment,service,ingress dify-marketplace-proxy
```
