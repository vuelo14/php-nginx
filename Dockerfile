FROM php:8.3-fpm-alpine

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

# 4. Konfigurasi Nginx & Izin Folder
# Samakan user Nginx menjadi www-data agar selaras dengan PHP-FPM
RUN sed -i 's/user nginx;/user www-data;/g' /etc/nginx/nginx.conf \
    && mkdir -p /run/nginx /var/log/supervisor /var/lib/nginx/tmp \
    && chown -R www-data:www-data /var/lib/nginx /var/log/nginx /run/nginx /var/www/html

# 5. Salin Konfigurasi Nginx, PHP, Supervisor, dan Entrypoint
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose Port Web Server
EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]