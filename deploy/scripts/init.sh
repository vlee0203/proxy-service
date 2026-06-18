#!/bin/bash
set -e

# sealos run 的 MountRootfs 阶段会用 ENV（Kubefile ENV + sealos run --env）把
# manifests/*.tmpl 渲染成同名 .yaml（Go 模板 {{ .xxx }} → 值，sealctl render --clear 还会删掉 .tmpl）。
# 这里直接 apply 渲染后的具体 .yaml 文件。
kubectl apply -f manifests/deploy.yaml -f manifests/ingress.yaml
