#!/bin/sh
set -e

# Pastikan folder runtime supervisor dan nginx sudah ada
mkdir -p /run/supervisor /run/nginx /var/log/supervisor /var/log/nginx /var/lib/nginx/tmp /etc/supervisor/conf.d 2>/dev/null || true

# Fungsi untuk mengecek apakah file atau direktori merupakan mount point dari host
is_mounted() {
    awk '{print $2}' /proc/mounts | grep -qx "$1"
}

# 1. Penyesuaian Document Root Nginx secara dinamis
# Hanya lakukan jika default.conf TIDAK di-mount dari host
if ! is_mounted "/etc/nginx/http.d/default.conf" && ! is_mounted "/etc/nginx/http.d"; then
    if [ -n "$DOCUMENT_ROOT" ]; then
        sed "s|root /var/www/html/public;|root $DOCUMENT_ROOT;|g" /etc/nginx/http.d/default.conf > /tmp/default.conf.tmp \
            && cat /tmp/default.conf.tmp > /etc/nginx/http.d/default.conf \
            && rm -f /tmp/default.conf.tmp
    elif [ ! -d "/var/www/html/public" ] && [ -f "/var/www/html/index.php" ]; then
        sed "s|root /var/www/html/public;|root /var/www/html;|g" /etc/nginx/http.d/default.conf > /tmp/default.conf.tmp \
            && cat /tmp/default.conf.tmp > /etc/nginx/http.d/default.conf \
            && rm -f /tmp/default.conf.tmp
    fi
fi

# 2. Konfigurasi Queue Worker otomatis jika ENABLE_WORKER=true
if [ "${ENABLE_WORKER:-false}" = "true" ] || [ "${ENABLE_QUEUE_WORKER:-false}" = "true" ]; then
    WORKER_CMD="${WORKER_COMMAND:-php /var/www/html/artisan queue:work --sleep=3 --tries=3 --max-time=3600}"
    WORKER_NUM="${WORKER_NUMPROCS:-1}"

    cat <<EOF > /etc/supervisor/conf.d/worker.conf
[program:worker]
process_name=%(program_name)s_%(process_num)02d
command=${WORKER_CMD}
directory=/var/www/html
autostart=true
autorestart=true
numprocs=${WORKER_NUM}
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF
fi

# 3. Konfigurasi Scheduler otomatis jika ENABLE_SCHEDULER=true
if [ "${ENABLE_SCHEDULER:-false}" = "true" ]; then
    SCHEDULER_CMD="${SCHEDULER_COMMAND:-php /var/www/html/artisan schedule:work}"

    cat <<EOF > /etc/supervisor/conf.d/scheduler.conf
[program:scheduler]
command=${SCHEDULER_CMD}
directory=/var/www/html
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF
fi

# Jalankan perintah CMD (default: /usr/bin/supervisord -c /etc/supervisord.conf)
exec "$@"
