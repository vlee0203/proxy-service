# Proxy Service

一个基于 Node.js 的简单反向代理服务。  
支持通过上游代理（`HTTPS_PROXY`）转发请求，常用于需要走代理才能访问外部服务的场景，例如 `https://marketplace.dify.ai` 或 `https://github.com`。

---

## 功能特性

- 支持 HTTP → HTTPS 反向代理
- 支持通过环境变量指定上游代理（`HTTPS_PROXY`）
- 支持通过环境变量配置目标地址（`TARGET`）
- 使用 Docker 多阶段构建，镜像体积更小、更安全

---

## 环境变量说明

- `TARGET`：必选，要代理的目标地址，例如 `https://marketplace.dify.ai`
- `HTTPS_PROXY`：可选，上游代理地址，例如 `http://proxy.example.com:7890`

---

## 构建镜像

```bash
docker build -t proxy-service .
```

---

## 运行容器

```bash
docker run -d \
  -e TARGET=https://marketplace.dify.ai \
  -e HTTPS_PROXY=http://your-proxy:port \
  -p 8080:8080 \
  proxy-service
```

启动后访问：

```arduino
http://localhost:8080
```

即会通过上游代理访问 `https://marketplace.dify.ai`。

---

## Docker Compose 示例

```yaml
version: '3'

services:
  proxy:
    image: proxy-service:latest
    build: .
    ports:
      - "8080:8080"
    environment:
      TARGET: https://marketplace.dify.ai
      HTTPS_PROXY: http://your-proxy:port
```

运行：

```bash
docker-compose up -d
```

---

## 本地开发调试

如果你希望在本地开发或调试，不使用 Docker，可以直接运行 Node.js：

1. 安装依赖：

```bash
npm install
```

2. 设置环境变量

- macOS/Linux：

```bash
export TARGET=https://marketplace.dify.ai
export HTTPS_PROXY=http://your-proxy:port
```

- Windows PowerShell：

```powershell
$env:TARGET="https://marketplace.dify.ai"
$env:HTTPS_PROXY="http://your-proxy:port"
```

3. 启动服务：

```bash
npm start
```

4. 打开浏览器访问：

```arduino
http://localhost:8080
```

---

## License

MIT
