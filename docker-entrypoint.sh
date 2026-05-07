#!/bin/bash
set -e

HOST="${DB_HOST:-${MYSQLHOST:-localhost}}"
PORT="${DB_PORT:-${MYSQLPORT:-3306}}"
USER="${DB_USER:-${MYSQLUSER:-root}}"
PASS="${DB_PASSWORD:-${MYSQLPASSWORD:-}}"
NAME="${DB_NAME:-${MYSQLDATABASE:-pets_game}}"

echo "==> Waiting for MySQL at $HOST:$PORT ..."
for i in $(seq 1 60); do
    if mysqladmin ping -h"$HOST" -P"$PORT" -u"$USER" ${PASS:+-p"$PASS"} --silent 2>/dev/null; then
        echo "==> MySQL is ready."
        break
    fi
    echo "    waiting... ($i)"
    sleep 2
done

echo "==> Initializing database..."
mysql -h"$HOST" -P"$PORT" -u"$USER" ${PASS:+-p"$PASS"} < /app/init.sql 2>/dev/null || true
echo "==> Database init done."

echo "==> Starting Tomcat on port ${PORT:-8080}..."
exec catalina.sh run
