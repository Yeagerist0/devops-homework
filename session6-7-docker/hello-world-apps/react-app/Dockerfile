FROM node:22-alpine AS build
WORKDIR /app
COPY package.json index.html vite.config.js ./
COPY src ./src
RUN npm install
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/index.html /usr/share/nginx/html/index.html
EXPOSE 80
