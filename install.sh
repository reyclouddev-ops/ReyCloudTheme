#!/usr/bin/env bash

set -e

PANEL_DIR="/var/www/pterodactyl"
BACKUP_DIR="/var/backups/reycloud-theme"
THEME_DIR="$PANEL_DIR/resources/scripts/reycloud"

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║           ☁ REYCLOUD THEME                 ║"
echo "║           PTERODACTYL 1.15.0                ║"
echo "╚════════════════════════════════════════════╝"
echo ""

if [ "$(id -u)" != "0" ]; then
    echo "❌ Jalankan sebagai root."
    exit 1
fi

if [ ! -d "$PANEL_DIR" ]; then
    echo "❌ Pterodactyl tidak ditemukan:"
    echo "$PANEL_DIR"
    exit 1
fi

if [ ! -f "$PANEL_DIR/artisan" ]; then
    echo "❌ Direktori tersebut bukan instalasi Pterodactyl."
    exit 1
fi

echo "✓ Pterodactyl ditemukan"

cd "$PANEL_DIR"

echo "✓ Memeriksa package frontend..."

if [ ! -f "package.json" ]; then
    echo "❌ package.json tidak ditemukan."
    exit 1
fi

VERSION="unknown"

if command -v php >/dev/null 2>&1; then
    VERSION=$(php artisan --version 2>/dev/null || echo "unknown")
fi

echo "✓ Version: $VERSION"

echo ""
echo "⚠️ Installer akan membuat backup sebelum perubahan."
echo ""

read -r -p "Lanjutkan install Theme ReyCloud? [y/N]: " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Dibatalkan."
    exit 0
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CURRENT_BACKUP="$BACKUP_DIR/$TIMESTAMP"

mkdir -p "$CURRENT_BACKUP"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Membuat backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cp -a "$PANEL_DIR/resources" "$CURRENT_BACKUP/resources"

if [ -f "$PANEL_DIR/package.json" ]; then
    cp "$PANEL_DIR/package.json" "$CURRENT_BACKUP/package.json"
fi

if [ -f "$PANEL_DIR/yarn.lock" ]; then
    cp "$PANEL_DIR/yarn.lock" "$CURRENT_BACKUP/yarn.lock"
fi

echo "✓ Backup:"
echo "$CURRENT_BACKUP"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Membuat asset ReyCloud"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "$THEME_DIR"

cat > "$THEME_DIR/reycloud.css" <<'EOF'
:root {
    --rey-bg: #080b14;
    --rey-panel: #101522;
    --rey-panel-2: #151b2b;
    --rey-border: rgba(255,255,255,.08);
    --rey-text: #f5f7ff;
    --rey-muted: #8c96aa;
    --rey-primary: #7c5cff;
    --rey-primary-2: #5b8cff;
    --rey-success: #32d583;
    --rey-danger: #ff5c7a;
    --rey-shadow: 0 20px 60px rgba(0,0,0,.25);
}

body {
    background:
        radial-gradient(
            circle at top right,
            rgba(124,92,255,.12),
            transparent 30%
        ),
        var(--rey-bg) !important;

    color: var(--rey-text);
}

* {
    scrollbar-width: thin;
    scrollbar-color: var(--rey-primary) transparent;
}

::-webkit-scrollbar {
    width: 7px;
}

::-webkit-scrollbar-track {
    background: transparent;
}

::-webkit-scrollbar-thumb {
    background: linear-gradient(
        var(--rey-primary),
        var(--rey-primary-2)
    );

    border-radius: 999px;
}

.reycloud-theme {
    font-family:
        Inter,
        ui-sans-serif,
        system-ui,
        -apple-system,
        BlinkMacSystemFont,
        "Segoe UI",
        sans-serif;
}

button,
a,
input,
textarea,
select {
    transition:
        background .2s ease,
        border-color .2s ease,
        color .2s ease,
        transform .2s ease,
        box-shadow .2s ease;
}

button:hover {
    transform: translateY(-1px);
}

input,
textarea,
select {
    border-color: var(--rey-border) !important;
    background: var(--rey-panel) !important;
    color: var(--rey-text) !important;
}

input:focus,
textarea:focus,
select:focus {
    border-color: var(--rey-primary) !important;
    box-shadow:
        0 0 0 3px rgba(124,92,255,.15) !important;
}

.reycloud-card {
    background:
        linear-gradient(
            145deg,
            rgba(255,255,255,.045),
            rgba(255,255,255,.015)
        ) !important;

    border: 1px solid var(--rey-border) !important;
    border-radius: 18px !important;
    box-shadow: var(--rey-shadow) !important;
    backdrop-filter: blur(18px);
}

.reycloud-gradient {
    background:
        linear-gradient(
            135deg,
            var(--rey-primary),
            var(--rey-primary-2)
        );
}

.reycloud-glow {
    box-shadow:
        0 0 35px rgba(124,92,255,.18);
}

.reycloud-brand {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 800;
    letter-spacing: -.02em;
}

.reycloud-brand-icon {
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;

    background:
        linear-gradient(
            135deg,
            var(--rey-primary),
            var(--rey-primary-2)
        );

    color: white;
    box-shadow:
        0 8px 25px rgba(124,92,255,.3);
}

.reycloud-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;

    padding: 6px 10px;
    border-radius: 999px;

    font-size: 11px;
    font-weight: 700;

    background: rgba(50,213,131,.1);
    color: var(--rey-success);
}

.reycloud-badge.offline {
    background: rgba(255,92,122,.1);
    color: var(--rey-danger);
}

@media (max-width: 768px) {
    .reycloud-card {
        border-radius: 14px !important;
    }
}
EOF

echo "✓ CSS ReyCloud dibuat"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Membuat komponen branding"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "$THEME_DIR/branding.ts" <<'EOF'
export const REYCLOUD_BRAND = {
    name: 'ReyCloud',
    subtitle: 'Cloud Infrastructure',
    version: '1.0.0',
};

export const REYCLOUD_COLORS = {
    primary: '#7c5cff',
    secondary: '#5b8cff',
    success: '#32d583',
    danger: '#ff5c7a',
};
EOF

echo "✓ Branding dibuat"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Mencari entry frontend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ENTRY=""

for FILE in \
    "resources/scripts/index.tsx" \
    "resources/scripts/index.ts" \
    "resources/scripts/index.jsx" \
    "resources/scripts/index.js"
do
    if [ -f "$PANEL_DIR/$FILE" ]; then
        ENTRY="$PANEL_DIR/$FILE"
        break
    fi
done

if [ -z "$ENTRY" ]; then
    echo "⚠️ Entry frontend tidak ditemukan otomatis."
    echo ""
    echo "Theme asset sudah dibuat di:"
    echo "$THEME_DIR"
    echo ""
    echo "Kirim struktur:"
    echo "resources/scripts"
    echo "agar patch Login + Dashboard bisa dibuat tepat."
    exit 0
fi

echo "✓ Entry ditemukan:"
echo "$ENTRY"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Memasang stylesheet"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

IMPORT_LINE="import './reycloud/reycloud.css';"

if ! grep -Fq "$IMPORT_LINE" "$ENTRY"; then
    cp "$ENTRY" "$ENTRY.reycloud-backup"

    {
        echo "$IMPORT_LINE"
        cat "$ENTRY"
    } > "$ENTRY.tmp"

    mv "$ENTRY.tmp" "$ENTRY"

    echo "✓ ReyCloud CSS diaktifkan"
else
    echo "✓ ReyCloud CSS sudah aktif"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Build frontend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v yarn >/dev/null 2>&1; then
    yarn build:production
elif command -v npm >/dev/null 2>&1; then
    npm run build:production
else
    echo "❌ Yarn/npm tidak ditemukan."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. Membersihkan cache"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

php artisan optimize:clear

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8. Permission"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if id www-data >/dev/null 2>&1; then
    chown -R www-data:www-data "$PANEL_DIR/storage"
    chown -R www-data:www-data "$PANEL_DIR/bootstrap/cache"
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║        ✓ REYCLOUD THEME BERHASIL          ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "Backup:"
echo "$CURRENT_BACKUP"
echo ""
echo "Silakan refresh panel Pterodactyl."
echo ""
