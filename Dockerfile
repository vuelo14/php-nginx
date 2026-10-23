FROM php:8.3.36-fpm-alpine

# Set Working Directory
WORKDIR /var/www/html

# 1. Install Build Dependencies & Compile Ekstensi PHP
RUN apk update && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    oniguruma-dev \
    postgresql-dev \
    icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache \
    && apk del .build-deps

# 2. Install Runtime Libraries, Nginx, Supervisor, Node.js & Tools
RUN apk add --no-cache \
    nginx \
    supervisor \
    libcap \
    libwebp \
    libzip \
    libpng \
    libjpeg-turbo \
    freetype \
    oniguruma \
    libpq \
    curl \
    git \
    bash \
    nodejs \
    npm \
    unzip \
    icu-libs \
    icu-data-full

# 3. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Salin Konfigurasi Nginx, PHP, Supervisor, Source Default, dan Entrypoint
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/supervisor/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=www-data:www-data public/ /var/www/html/public/

# 5. Konfigurasi Izin & Keamanan Non-Root (User: www-data)
# - Izinkan Nginx bind ke privileged port (< 1024 seperti 80 & 443) tanpa hak root
# - Hapus 'user nginx;' dari nginx.conf agar tidak memicu warning unprivileged user
# - Buat direktori runtime supervisor & nginx, lalu atur kepemilikan ke www-data
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx \
    && sed -i 's/^user .*/# user directive disabled for unprivileged container;/g' /etc/nginx/nginx.conf \
    && mkdir -p \
        /run/nginx \
        /run/supervisor \
        /var/log/nginx \
        /var/log/supervisor \
        /var/lib/nginx/tmp \
        /etc/supervisor/conf.d \
        /home/www-data \
    && chown -R www-data:www-data \
        /run/nginx \
        /run/supervisor \
        /var/log/nginx \
        /var/log/supervisor \
        /var/lib/nginx \
        /etc/nginx \
        /etc/supervisor \
        /home/www-data \
        /var/www/html

# 6. Jalankan container sebagai user non-root (www-data)
USER www-data

# Expose Port Web Server
EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
