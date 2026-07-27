# Multi-stage hardened production Dockerfile
FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
# Non-root security best practice
USER node
WORKDIR /home/node/app
COPY --chown=node:node --from=builder /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .
EXPOSE 8080
CMD ["node", "server.js"]
