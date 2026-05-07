#!/bin/bash
HOST="${MYSQLHOST:-localhost}"
PORT="${MYSQLPORT:-3306}"
USER="${MYSQLUSER:-root}"
PASS="${MYSQLPASSWORD:-}"
DB="${MYSQLDATABASE:-pets_game}"
echo "==> Waiting for MySQL at $HOST:$PORT ..."
for i in $(seq 1 30); do
    if mysqladmin ping -h"$HOST" -P"$PORT" -u"$USER" ${PASS:+-p"$PASS"} --silent 2>/dev/null; then
        echo "==> MySQL ready."
        break
    fi
    sleep 2
done
echo "==> Init database tables..."
mysql -h"$HOST" -P"$PORT" -u"$USER" ${PASS:+-p"$PASS"} -D"$DB" < /app/init.sql 2>/dev/null || true
echo "==> Starting Tomcat..."
exec "$@"
