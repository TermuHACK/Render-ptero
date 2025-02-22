# Этап 1: Сборка PteroVM
FROM node:16-alpine as pterovm-builder

RUN apk add --no-cache git && \
    git clone https://github.com/pterovm/pterovm /pterovm && \
    cd /pterovm && \
    npm install --production && \
    npm run build

# Этап 2: Сборка Gotty
FROM golang:alpine as gotty-builder

RUN apk add --no-cache git && \
    git clone https://github.com/sorenisanerd/gotty.git /gotty-src && \
    cd /gotty-src && \
    go build -o /gotty

# Этап 3: Финальный образ
FROM alpine:latest

# Установка 

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache \
        bash \
        sudo \
        curl \
        php81 \
        php81-cli \
        php81-curl \
        php81-xml \
        php81-mbstring \
        php81-zip \
        php81-session \
        lighttpd \
        nodejs \
        npm \
        qemu-user-static \
        docker-cli \
        git
# Создание пользователя Dvdr00 с рут-доступом
RUN adduser -D Dvdr00 && \
    echo "Dvdr00 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Копирование Gotty, PteroVM и Pterodactyl
COPY --from=gotty-builder /gotty /usr/local/bin/gotty
COPY --from=pterovm-builder /pterovm /home/Dvdr00/pterovm

# Настройка Pterodactyl
RUN git clone https://github.com/pterodactyl/panel.git /var/www/pterodactyl
RUN chown -R Dvdr00:Dvdr00 /var/www/pterodactyl && \
    chmod -R 755 /var/www/pterodactyl/storage /var/www/pterodactyl/bootstrap/cache

# Настройка Lighttpd
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf

# Переключение на пользователя Dvdr00
USER Dvdr00
WORKDIR /home/Dvdr00

# Запуск Pterodactyl, PteroVM и Gotty
CMD ["sh", "-c", "lighttpd -D -f /etc/lighttpd/lighttpd.conf & php -S 0.0.0.0:8080 -t /var/www/pterodactyl/public & cd /home/Dvdr00/pterovm && npm start & gotty bash"]
