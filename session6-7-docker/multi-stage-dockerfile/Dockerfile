# -------------------------
# Stage 1: Build
# -------------------------
FROM node:24-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
## COPY . . copies everything from the build context into the working directory in the container
COPY . .

# -------------------------
# Stage 2: Production
# -------------------------
FROM node:24-alpine AS production
WORKDIR /app
## Copy required content from the builder stage to the production stage like compiled binaries, dependencies, etc. 
## COPY SYNTAX: COPY --from=<stage_name> <source_path> <destination_path>
COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/server.js ./
EXPOSE 3000
CMD ["npm", "start"]