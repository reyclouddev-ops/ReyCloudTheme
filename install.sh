#!/bin/bash

set -e

PANEL="/var/www/pterodactyl"
THEME_DIR="$PANEL/public/reycloud-theme"
BACKUP_DIR="/var/backups/reycloud-theme"

echo ""
echo "=========================================="
echo "        REYCLOUD PTERODACTYL THEME"
echo "=========================================="
echo ""

if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] Jalankan sebagai root."
    exit 1
fi

if [ ! -d "$PANEL" ]; then
    echo "[ERROR] Pterodactyl tidak ditemukan:"
    echo "$PANEL"
    exit 1
fi

echo "[1/7] Mengecek Pterodactyl..."

if [ -f "$PANEL/artisan" ]; then
    echo "[OK] Pterodactyl ditemukan."
else
    echo "[ERROR] File artisan tidak ditemukan."
    exit 1
fi

VERSION=$(grep -m1 '"version"' "$PANEL/composer.json" 2>/dev/null | sed -E 's/.*"version": *"([^"]+)".*/\1/')

if [ -z "$VERSION" ]; then
    VERSION="unknown"
fi

echo "[INFO] Version: $VERSION"

echo "[2/7] Membuat backup..."

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="$BACKUP_DIR/reycloud-$(date +%Y%m%d-%H%M%S).tar.gz"

tar -czf "$BACKUP_FILE" \
    -C "$PANEL" \
    resources/views \
    public 2>/dev/null || true

echo "[OK] Backup:"
echo "$BACKUP_FILE"

echo "[3/7] Membuat folder theme..."

mkdir -p "$THEME_DIR"

echo "[4/7] Membuat CSS..."

cat > "$THEME_DIR/theme.css" <<'EOF'
:root {
    --rey-primary: #8b5cf6;
    --rey-secondary: #6366f1;
    --rey-bg: #0b0b12;
    --rey-card: #12121c;
    --rey-border: rgba(255,255,255,.08);
}

body {
    background:
        radial-gradient(
            circle at top right,
            rgba(139,92,246,.12),
            transparent 35%
        ),
        var(--rey-bg) !important;
}

* {
    scrollbar-width: thin;
    scrollbar-color: var(--rey-primary) transparent;
}

::-webkit-scrollbar {
    width: 7px;
}

::-webkit-scrollbar-thumb {
    background: linear-gradient(
        var(--rey-primary),
        var(--rey-secondary)
    );
    border-radius: 20px;
}

a {
    transition: .2s ease;
}

button,
a,
input {
    transition: .2s ease;
}

.reycloud-theme {
    font-family: Inter, system-ui, sans-serif;
}

.reycloud-brand {
    font-weight: 800;
    letter-spacing: -.4px;
    background: linear-gradient(
        90deg,
        #a78bfa,
        #6366f1
    );
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
}

.reycloud-card {
    background: rgba(18,18,28,.82);
    border: 1px solid var(--rey-border);
    border-radius: 16px;
    box-shadow:
        0 20px 50px rgba(0,0,0,.22);
    backdrop-filter: blur(16px);
}

.reycloud-glow {
    box-shadow:
        0 0 0 1px rgba(139,92,246,.08),
        0 15px 45px rgba(99,102,241,.12);
}
EOF

echo "[5/7] Membuat JavaScript theme..."

cat > "$THEME_DIR/theme.js" <<'EOF'
(function () {

    "use strict";

    function applyReyCloudTheme() {

        document.documentElement.classList.add(
            "reycloud-theme"
        );

        document.body.classList.add(
            "reycloud-theme"
        );

        document
            .querySelectorAll(
                ".login-container, .login-box, .card"
            )
            .forEach(function (element) {

                element.classList.add(
                    "reycloud-card"
                );

            });

        document
            .querySelectorAll(
                "h1, h2, h3"
            )
            .forEach(function (element) {

                if (
                    element.textContent
                        .trim()
                        .toLowerCase()
                        .includes("rey")
                ) {
                    element.classList.add(
                        "reycloud-brand"
                    );
                }

            });

    }

    if (
        document.readyState === "loading"
    ) {

        document.addEventListener(
            "DOMContentLoaded",
            applyReyCloudTheme
        );

    } else {

        applyReyCloudTheme();

    }

    const observer =
        new MutationObserver(function () {

            applyReyCloudTheme();

        });

    observer.observe(
        document.documentElement,
        {
            childList: true,
            subtree: true
        }
    );

})();
EOF

echo "[6/7] Membuat loader..."

cat > "$THEME_DIR/index.php" <<'EOF'
<?php
http_response_code(403);
exit;
EOF

echo "[7/7] Membersihkan cache..."

cd "$PANEL"

php artisan view:clear || true
php artisan config:clear || true
php artisan cache:clear || true

chmod -R 755 "$THEME_DIR"

if command -v systemctl >/dev/null 2>&1; then

    systemctl restart nginx 2>/dev/null || true
    systemctl restart apache2 2>/dev/null || true

fi

php artisan queue:restart 2>/dev/null || true

echo ""
echo "=========================================="
echo "       REYCLOUD THEME BERHASIL DIPASANG"
echo "=========================================="
echo ""
echo "Panel    : $PANEL"
echo "Version  : $VERSION"
echo "Backup   : $BACKUP_FILE"
echo ""
echo "Silakan refresh browser."
echo ""
