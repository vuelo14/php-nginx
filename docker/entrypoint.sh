#!/bin/sh
set -e

# Fungsi untuk mengecek apakah file atau direktori merupakan mount point dari host
is_mounted() {
    awk '{print $2}' /proc/mounts | grep -qx "$1"
}

# Hanya lakukan penyesuaian otomatis jika default.conf TIDAK di-mount dari host
# Jika di-mount secara eksternal, konfigurasi host dipertahankan dan tidak diubah
if ! is_mounted "/etc/nginx/http.d/default.conf" && ! is_mounted "/etc/nginx/http.d"; then
    if [ -n "$DOCUMENT_ROOT" ]; then
        sed "s|root /var/www/html/public;|root $DOCUMENT_ROOT;|g" /etc/nginx/http.d/default.conf > /tmp/default.conf.tmp \
            && cat /tmp/default.conf.tmp > /etc/nginx/http.d/default.conf \
            && rm -f /tmp/default.conf.tmp
    elif [ ! -d "/var/www/html/public" ] && [ -f "/var/www/html/index.php" ]; then
        # Otomatis deteksi jika aplikasi tidak memiliki subfolder public/
        sed "s|root /var/www/html/public;|root /var/www/html;|g" /etc/nginx/http.d/default.conf > /tmp/default.conf.tmp \
            && cat /tmp/default.conf.tmp > /etc/nginx/http.d/default.conf \
            && rm -f /tmp/default.conf.tmp
    fi
fi

# Jalankan perintah CMD yang diteruskan (supervisord)
exec "$@"
