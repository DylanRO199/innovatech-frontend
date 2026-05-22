# Stage 1: Build
FROM node:18-alpine AS build

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Usar npm install en lugar de npm ci (más flexible)
RUN npm install

# Copiar el resto del código
COPY . .

# Construir la aplicación
RUN npm run build

# Stage 2: Nginx
FROM nginx:alpine

# Crear usuario no root
RUN deluser --remove-home nginx && \
    addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Copiar los archivos compilados
COPY --from=build --chown=nginx:nginx /app/build /usr/share/nginx/html

# Eliminar archivos innecesarios
RUN rm -rf /etc/nginx/conf.d/default.conf

EXPOSE 80

USER nginx

CMD ["nginx", "-g", "daemon off;"]