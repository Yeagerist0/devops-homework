# Multi-stage security-hardened production image
FROM node:20-alpine AS dependencies
WORKDIR /app
COPY application/package*.json ./
RUN npm ci --only=production

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -g 1001 -S nodejs && adduser -S nodeuser -u 1001 -G nodejs
COPY --chown=nodeuser:nodejs --from=dependencies /app/node_modules ./node_modules
COPY --chown=nodeuser:nodejs application/ .
USER nodeuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/healthz || exit 1
CMD ["node", "server.js"]
