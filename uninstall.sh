#!/bin/bash

set -e

PTERO_DIR="/var/www/pterodactyl"
BACKUP_DIR="/var/backups/reycloud-theme"

echo ""
echo "========================================"
echo "       REYCLOUD THEME UNINSTALL"
echo "========================================"
echo ""

if [ "$(id -u)" != "0" ]; then
    echo "❌ Jalankan sebagai root."
    exit 1
fi

echo "📦 Backup tersedia:"
ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null || {
    echo "❌ Backup tidak ditemukan."
    exit 1
}

LATEST=$(ls -t "$BACKUP_DIR"/*.tar.gz | head -n 1)

echo ""
echo "Backup terbaru:"
echo "$LATEST"
echo ""

read -r -p "Restore backup ini? [y/N]: " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "❌ Dibatalkan."
    exit 0
fi

echo ""
echo "♻️ Restore..."

tar -xzf "$LATEST" -C "$PTERO_DIR"

rm -rf "$PTERO_DIR/public/reycloud"

cd "$PTERO_DIR"

php artisan optimize:clear

if command -v yarn >/dev/null 2>&1; then
    yarn build:production || true
fi

systemctl restart nginx 2>/dev/null || true
systemctl restart php8.3-fpm 2>/dev/null || true

echo ""
echo "========================================"
echo "       REYCLOUD THEME REMOVED"
echo "========================================"
echo ""
echo "✔ Backup telah direstore."
echo ""
