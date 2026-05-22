# Stage 1: Build
FROM node:18-alpine AS build

WORKDIR /app

# Configurar registro npm alternativo
RUN npm config set registry https://registry.npmmirror.com

COPY package.json ./

RUN npm install --no-package-lock --legacy-peer-deps

COPY . .

RUN npm run build

# Stage 2: Nginx
FROM nginx:alpine

RUN deluser --remove-home nginx && \
    addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

COPY --from=build --chown=nginx:nginx /app/build /usr/share/nginx/html

RUN rm -rf /etc/nginx/conf.d/default.conf

EXPOSE 80

USER nginx

CMD ["nginx", "-g", "daemon off;"]