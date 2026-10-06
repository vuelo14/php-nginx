#!/bin/sh
set -e

# Izinkan konfigurasi DOCUMENT_ROOT dinamis (default: /var/www/html/public)
if [ -n "$DOCUMENT_ROOT" ]; then
    sed -i "s|root /var/www/html/public;|root $DOCUMENT_ROOT;|g" /etc/nginx/http.d/default.conf
elif [ ! -d "/var/www/html/public" ] && [ -f "/var/www/html/index.php" ]; then
    # Otomatis deteksi jika aplikasi tidak memiliki subfolder public/
    sed -i "s|root /var/www/html/public;|root /var/www/html;|g" /etc/nginx/http.d/default.conf
fi

# Jalankan perintah CMD yang diteruskan (supervisord)
exec "$@"
