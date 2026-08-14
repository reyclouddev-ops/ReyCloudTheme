#!/bin/bash

set -e

PANEL="/var/www/pterodactyl"
THEME_DIR="$PANEL/public/reycloud-theme"

echo ""
echo "=========================================="
echo "      REYCLOUD THEME UNINSTALLER"
echo "=========================================="
echo ""

if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] Jalankan sebagai root."
    exit 1
fi

if [ ! -d "$PANEL" ]; then
    echo "[ERROR] Pterodactyl tidak ditemukan."
    exit 1
fi

echo "[1/4] Menghapus theme..."

rm -rf "$THEME_DIR"

echo "[2/4] Membersihkan cache..."

cd "$PANEL"

php artisan view:clear || true
php artisan config:clear || true
php artisan cache:clear || true

echo "[3/4] Restart queue..."

php artisan queue:restart 2>/dev/null || true

echo "[4/4] Selesai."

echo ""
echo "=========================================="
echo "       THEME BERHASIL DIHAPUS"
echo "=========================================="
echo ""
