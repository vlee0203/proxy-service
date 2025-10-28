# ----------- 构建阶段 -----------
FROM node:20-alpine AS builder

WORKDIR /app

# 只复制 package.json 和 lock 文件，避免源代码变更导致重新安装依赖
COPY package*.json ./

# 安装依赖（只保留生产依赖）
RUN npm ci --only=production

# ----------- 运行阶段 -----------
FROM node:20-alpine

WORKDIR /app

# 从 builder 镜像复制 node_modules
COPY --from=builder /app/node_modules ./node_modules

# 复制源码
COPY server.js ./
COPY package*.json ./

EXPOSE 8080

CMD ["npm", "start"]

