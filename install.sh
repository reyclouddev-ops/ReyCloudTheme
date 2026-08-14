#!/bin/bash

set -e

PTERO_DIR="/var/www/pterodactyl"
BACKUP_DIR="/var/backups/reycloud-theme"
THEME_DIR="$PTERO_DIR/public/reycloud"

echo ""
echo "========================================"
echo "       REYCLOUD PTERODACTYL THEME"
echo "========================================"
echo ""

if [ "$(id -u)" != "0" ]; then
    echo "❌ Jalankan sebagai root."
    exit 1
fi

if [ ! -d "$PTERO_DIR" ]; then
    echo "❌ Pterodactyl tidak ditemukan:"
    echo "$PTERO_DIR"
    exit 1
fi

echo "✔ Pterodactyl ditemukan"
echo ""

mkdir -p "$BACKUP_DIR"

BACKUP="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "📦 Membuat backup..."
tar -czf "$BACKUP" \
    -C "$PTERO_DIR" \
    resources public 2>/dev/null || true

echo "✔ Backup:"
echo "$BACKUP"
echo ""

echo "🎨 Membuat ReyCloud Theme..."

mkdir -p "$THEME_DIR"

cat > "$THEME_DIR/theme.css" <<'EOF'
:root {
    --rey-primary: #8b5cf6;
    --rey-secondary: #6366f1;
    --rey-bg: #08080d;
    --rey-card: #11111a;
    --rey-card-2: #161620;
    --rey-border: rgba(255,255,255,.08);
    --rey-text: #f8fafc;
    --rey-muted: #94a3b8;
}

body {
    background:
        radial-gradient(
            circle at 10% 0%,
            rgba(139,92,246,.13),
            transparent 30%
        ),
        radial-gradient(
            circle at 100% 20%,
            rgba(99,102,241,.10),
            transparent 30%
        ),
        var(--rey-bg) !important;

    color: var(--rey-text) !important;
}

.bg-neutral-800,
.bg-gray-800,
.bg-gray-900,
.bg-neutral-900 {
    background-color: var(--rey-card) !important;
}

.border-gray-700,
.border-neutral-700,
.border-gray-800 {
    border-color: var(--rey-border) !important;
}

.text-gray-300,
.text-gray-400,
.text-neutral-400,
.text-neutral-500 {
    color: var(--rey-muted) !important;
}

input,
textarea,
select {
    background: rgba(255,255,255,.035) !important;
    border: 1px solid var(--rey-border) !important;
    color: var(--rey-text) !important;
    border-radius: 10px !important;
}

input:focus,
textarea:focus,
select:focus {
    border-color: var(--rey-primary) !important;
    box-shadow:
        0 0 0 3px
        rgba(139,92,246,.12) !important;
}

button {
    border-radius: 10px !important;
}

.bg-blue-500,
.bg-primary-500,
.bg-green-500 {
    background:
        linear-gradient(
            135deg,
            var(--rey-primary),
            var(--rey-secondary)
        ) !important;
}

.shadow,
.shadow-md,
.shadow-lg {
    box-shadow:
        0 12px 40px
        rgba(0,0,0,.25) !important;
}

a {
    transition: .2s ease;
}

::-webkit-scrollbar {
    width: 7px;
}

::-webkit-scrollbar-track {
    background: transparent;
}

::-webkit-scrollbar-thumb {
    background:
        linear-gradient(
            var(--rey-primary),
            var(--rey-secondary)
        );

    border-radius: 20px;
}
EOF

echo "✔ Theme CSS dibuat"
echo ""

echo "🧩 Membuat branding..."

cat > "$THEME_DIR/branding.js" <<'EOF'
(() => {
    const BRAND = "ReyCloud";

    const update = () => {
        document.title = document.title
            .replace(/Pterodactyl/gi, BRAND);

        document.documentElement
            .setAttribute(
                "data-reycloud",
                "true"
            );
    };

    if (
        document.readyState ===
        "loading"
    ) {
        document.addEventListener(
            "DOMContentLoaded",
            update
        );
    } else {
        update();
    }
})();
EOF

echo "✔ Branding dibuat"
echo ""

cd "$PTERO_DIR"

echo "🧹 Membersihkan cache..."

php artisan optimize:clear

echo "✔ Cache dibersihkan"
echo ""

if command -v yarn >/dev/null 2>&1; then

    echo "📦 Installing frontend dependencies..."

    yarn install --frozen-lockfile \
        || yarn install

    echo ""
    echo "🏗️ Building frontend..."

    yarn build:production

else

    echo "⚠️ Yarn tidak ditemukan."
    echo "Theme asset tetap dibuat."
fi

echo ""

echo "🔐 Mengatur permission..."

chown -R www-data:www-data \
    "$PTERO_DIR/storage" \
    "$PTERO_DIR/bootstrap/cache" \
    2>/dev/null || true

chmod -R 755 "$THEME_DIR"

echo ""
echo "🔄 Restart service..."

systemctl restart nginx 2>/dev/null || true
systemctl restart php8.3-fpm 2>/dev/null || true

echo ""
echo "========================================"
echo "       REYCLOUD THEME INSTALLED"
echo "========================================"
echo ""
echo "🎨 Theme : ReyCloud"
echo "📦 Panel : Pterodactyl"
echo "💾 Backup:"
echo "$BACKUP"
echo ""
echo "✔ Installation selesai."
echo ""
