# Добавление репозиториев Alpine
RUN echo "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories

# Установка базовых пакетов (разделено для отладки)
RUN apk update && apk add --no-cache \
    bash \
    sudo \
    curl \
    lighttpd \
    nodejs \
    npm \
    qemu-user-static \
    docker-cli \
    git

# Установка PHP и его расширений отдельно (может быть проблемой)
RUN apk add --no-cache \
    php81 \
    php81-cli \
    php81-curl \
    php81-xml \
    php81-mbstring \
    php81-zip \
    php81-session