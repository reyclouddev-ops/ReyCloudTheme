#!/bin/bash

set -e

PTERO_DIR="/var/www/pterodactyl"
THEME_DIR="$PTERO_DIR/public/reycloud"
BACKUP_DIR="/var/backups/reycloud-theme"

PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear

banner() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════╗"
    echo "║          REYCLOUD PTERODACTYL THEME        ║"
    echo "║                  v1.0.0                    ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

success() {
    echo -e "${GREEN}✔ $1${RESET}"
}

error() {
    echo -e "${RED}✖ $1${RESET}"
}

info() {
    echo -e "${CYAN}➜ $1${RESET}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
}

check_root() {
    if [ "$(id -u)" != "0" ]; then
        error "Script harus dijalankan sebagai root."
        exit 1
    fi
}

check_pterodactyl() {
    if [ ! -d "$PTERO_DIR" ]; then
        error "Pterodactyl tidak ditemukan."
        echo ""
        echo "Path yang dicek:"
        echo "$PTERO_DIR"
        exit 1
    fi

    success "Pterodactyl ditemukan."
}

backup() {
    mkdir -p "$BACKUP_DIR"

    local backup_file
    backup_file="$BACKUP_DIR/reycloud-$(date +%Y%m%d-%H%M%S).tar.gz"

    info "Membuat backup..."

    tar -czf "$backup_file" \
        -C "$PTERO_DIR" \
        resources public 2>/dev/null || true

    success "Backup dibuat:"
    echo "$backup_file"
}

install_theme() {
    echo ""
    info "Memulai instalasi ReyCloud Theme..."
    echo ""

    backup

    mkdir -p "$THEME_DIR"

    cat > "$THEME_DIR/theme.css" <<'EOF'
:root {
    --rey-primary: #8b5cf6;
    --rey-secondary: #6366f1;
    --rey-bg: #07070b;
    --rey-panel: #101018;
    --rey-panel-2: #151521;
    --rey-border: rgba(255,255,255,.08);
    --rey-text: #f8fafc;
    --rey-muted: #94a3b8;
}

html,
body {
    background:
        radial-gradient(
            circle at 15% 0%,
            rgba(139,92,246,.14),
            transparent 30%
        ),
        radial-gradient(
            circle at 100% 20%,
            rgba(99,102,241,.12),
            transparent 30%
        ),
        var(--rey-bg) !important;

    color: var(--rey-text) !important;
}

aside,
nav {
    background:
        rgba(10,10,16,.94) !important;

    border-color:
        var(--rey-border) !important;

    backdrop-filter:
        blur(18px);
}

.bg-gray-800,
.bg-gray-900,
.bg-neutral-800,
.bg-neutral-900 {
    background:
        linear-gradient(
            145deg,
            rgba(255,255,255,.045),
            rgba(255,255,255,.018)
        ) !important;
}

input,
textarea,
select {
    background:
        rgba(255,255,255,.035) !important;

    color:
        var(--rey-text) !important;

    border:
        1px solid var(--rey-border) !important;

    border-radius:
        11px !important;
}

input:focus,
textarea:focus,
select:focus {
    border-color:
        var(--rey-primary) !important;

    box-shadow:
        0 0 0 3px
        rgba(139,92,246,.12) !important;

    outline:
        none !important;
}

button {
    border-radius:
        10px !important;
}

.bg-blue-500,
.bg-primary-500 {
    background:
        linear-gradient(
            135deg,
            var(--rey-primary),
            var(--rey-secondary)
        ) !important;
}

a {
    transition:
        all .2s ease;
}

a:hover {
    color:
        #a78bfa !important;
}

.text-gray-300,
.text-gray-400,
.text-neutral-400,
.text-neutral-500 {
    color:
        var(--rey-muted) !important;
}

::-webkit-scrollbar {
    width:
        7px;

    height:
        7px;
}

::-webkit-scrollbar-track {
    background:
        transparent;
}

::-webkit-scrollbar-thumb {
    background:
        linear-gradient(
            var(--rey-primary),
            var(--rey-secondary)
        );

    border-radius:
        20px;
}

::selection {
    background:
        rgba(139,92,246,.35);
}
EOF

    cat > "$THEME_DIR/theme.js" <<'EOF'
(() => {
    "use strict";

    const BRAND = "ReyCloud";

    function loadTheme() {
        if (
            document.getElementById(
                "reycloud-theme"
            )
        ) {
            return;
        }

        const link =
            document.createElement("link");

        link.id =
            "reycloud-theme";

        link.rel =
            "stylesheet";

        link.href =
            "/reycloud/theme.css";

        document.head.appendChild(link);
    }

    function branding() {
        document.documentElement
            .setAttribute(
                "data-reycloud",
                "true"
            );

        if (document.title) {
            document.title =
                document.title.replace(
                    /Pterodactyl/gi,
                    BRAND
                );
        }
    }

    function init() {
        loadTheme();
        branding();
    }

    if (
        document.readyState ===
        "loading"
    ) {
        document.addEventListener(
            "DOMContentLoaded",
            init
        );
    } else {
        init();
    }

    new MutationObserver(() => {
        branding();
    }).observe(
        document.documentElement,
        {
            childList: true,
            subtree: true
        }
    );
})();
EOF

    success "Asset theme dibuat."

    cd "$PTERO_DIR"

    info "Membersihkan Laravel cache..."

    php artisan optimize:clear || true

    success "Cache dibersihkan."

    if command -v yarn >/dev/null 2>&1; then
        info "Installing frontend dependencies..."

        yarn install --frozen-lockfile \
            || yarn install

        info "Building frontend..."

        yarn build:production || {
            warning "Frontend build gagal."
            warning "Theme asset tetap tersimpan."
        }

        success "Proses build selesai."
    else
        warning "Yarn tidak ditemukan."
    fi

    chown -R www-data:www-data \
        "$PTERO_DIR/storage" \
        "$PTERO_DIR/bootstrap/cache" \
        2>/dev/null || true

    chmod -R 755 "$THEME_DIR"

    restart_services

    echo ""
    success "ReyCloud Theme berhasil dipasang."
}

update_theme() {
    echo ""

    if [ ! -d "$THEME_DIR" ]; then
        warning "Theme belum terinstall."
        install_theme
        return
    fi

    backup

    info "Memperbarui theme..."

    install_theme

    success "Theme berhasil diperbarui."
}

uninstall_theme() {
    echo ""

    if [ ! -d "$THEME_DIR" ]; then
        warning "ReyCloud Theme tidak ditemukan."
        return
    fi

    echo ""
    warning "Theme akan dihapus."
    echo ""

    read -r -p "Lanjutkan? [y/N]: " answer

    if [[ "$answer" != "y" &&
          "$answer" != "Y" ]]; then
        info "Dibatalkan."
        return
    fi

    backup

    rm -rf "$THEME_DIR"

    cd "$PTERO_DIR"

    php artisan optimize:clear || true

    if command -v yarn >/dev/null 2>&1; then
        yarn build:production || true
    fi

    restart_services

    success "ReyCloud Theme dihapus."
}

restore_backup() {
    echo ""

    if [ ! -d "$BACKUP_DIR" ]; then
        error "Folder backup tidak ditemukan."
        return
    fi

    local latest

    latest=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n 1)

    if [ -z "$latest" ]; then
        error "Backup tidak ditemukan."
        return
    fi

    echo ""
    echo "Backup terbaru:"
    echo "$latest"
    echo ""

    read -r -p "Restore backup ini? [y/N]: " answer

    if [[ "$answer" != "y" &&
          "$answer" != "Y" ]]; then
        info "Dibatalkan."
        return
    fi

    info "Restore backup..."

    tar -xzf "$latest" \
        -C "$PTERO_DIR"

    rm -rf "$THEME_DIR"

    cd "$PTERO_DIR"

    php artisan optimize:clear || true

    if command -v yarn >/dev/null 2>&1; then
        yarn build:production || true
    fi

    restart_services

    success "Backup berhasil direstore."
}

rebuild_panel() {
    echo ""

    cd "$PTERO_DIR"

    info "Membersihkan cache..."

    php artisan optimize:clear || true

    if command -v yarn >/dev/null 2>&1; then
        info "Building frontend..."

        yarn build:production
    else
        warning "Yarn tidak tersedia."
    fi

    restart_services

    success "Panel berhasil direbuild."
}

restart_services() {
    info "Restart service..."

    systemctl restart nginx \
        2>/dev/null || true

    systemctl restart php8.3-fpm \
        2>/dev/null || true

    systemctl restart php8.2-fpm \
        2>/dev/null || true

    success "Service selesai direstart."
}

menu() {
    while true; do

        clear
        banner

        echo "1. Install Theme"
        echo "2. Update Theme"
        echo "3. Uninstall Theme"
        echo "4. Restore Backup"
        echo "5. Rebuild Panel"
        echo "6. Restart Service"
        echo "0. Exit"
        echo ""

        read -r -p "Pilih menu: " choice

        case "$choice" in

            1)
                check_pterodactyl
                install_theme
                ;;

            2)
                check_pterodactyl
                update_theme
                ;;

            3)
                check_pterodactyl
                uninstall_theme
                ;;

            4)
                check_pterodactyl
                restore_backup
                ;;

            5)
                check_pterodactyl
                rebuild_panel
                ;;

            6)
                restart_services
                ;;

            0)
                echo ""
                info "Bye 👋"
                exit 0
                ;;

            *)
                error "Pilihan tidak valid."
                ;;
        esac

        echo ""
        read -r -p "Tekan ENTER untuk kembali..."
    done
}

check_root
menu
