#!/bin/bash
clear

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

echo "${CYAN}"
cat << "EOF"
-----------------------------------------------------------
|                                                         |
|          Emby Unlocker for Lifetime Premiere            |
|               https://github.com/arg0WAK                |
|                                                         |
-----------------------------------------------------------
EOF
echo "${RESET}"

echo "${YELLOW}[ℹ]${RESET} Checking for administrative privileges..."
if [ "$(id -u)" -ne 0 ]; then
    echo "${RED}[✖]${RESET} This script must be run as root (sudo)!"
    exit 1
else
    echo "${GREEN}[✔]${RESET} Root privileges confirmed."
fi

HOST_FILE="/etc/hosts"
IP_ARG0=$(ping -c 1 arg0.dev | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p' || echo "")

if [ -z "$IP_ARG0" ]; then
    echo "${RED}[✖]${RESET} Failed to resolve fake validation server. Please check your network connection."
    exit 1
fi

echo "${YELLOW}[ℹ]${RESET} Adding entry to $HOST_FILE..."
sleep 2
PROXY="$IP_ARG0 mb3admin.com"
if ! grep -Fxq "$PROXY" "$HOST_FILE"; then
    echo "$PROXY" >> "$HOST_FILE"
    echo "${GREEN}[✔]${RESET} Entry successfully added: $PROXY"
else
    echo "${CYAN}[✔]${RESET} Entry already exists, skipping."
fi

echo "${YELLOW}[ℹ]${RESET} Downloading certificate..."
CERT_FILE="mb3admin.crt"
CERT_URL="https://arg0.dev/emby/$CERT_FILE"
TEMP_CERT="/tmp/$CERT_FILE"

if curl --progress-bar -L "$CERT_URL" -o "$TEMP_CERT"; then
    echo "${GREEN}[✔]${RESET} Certificate downloaded: $TEMP_CERT"
else
    echo "${RED}[✖]${RESET} Failed to download certificate. Please check the URL."
    exit 1
fi

echo "${YELLOW}[ℹ]${RESET} Installing certificate to system store..."
sleep 2
cp "$TEMP_CERT" "/usr/local/share/ca-certificates/mb3admin.crt"
chmod 644 "/usr/local/share/ca-certificates/mb3admin.crt"
update-ca-certificates

if [ $? -eq 0 ]; then
    echo "${GREEN}[✔]${RESET} Certificate successfully added to system store."
else
    echo "${RED}[✖]${RESET} Failed to install certificate."
    exit 1
fi

echo "${YELLOW}[ℹ]${RESET} Cleaning up temporary files..."
sleep 2
rm -f "$TEMP_CERT"
echo "${GREEN}[✔]${RESET} Temporary certificate file removed."

echo "${YELLOW}[ℹ]${RESET} Restarting network services (flushing DNS cache)..."
sleep 2
systemd-resolve --flush-caches || resolvectl flush-caches || echo "${YELLOW}[ℹ]${RESET} Could not flush DNS cache with systemd-resolve."

echo "${YELLOW}[ℹ]${RESET} Testing network connectivity..."
sleep 10
IP_MB3ADMIN=$(ping -c 1 mb3admin.com | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p')

if [ "$IP_MB3ADMIN" = "$IP_ARG0" ]; then
    echo "${GREEN}[✔]${RESET} Both domains match the same IP address: $IP_MB3ADMIN"
else
    echo "${RED}[✖]${RESET} The domains do not match the same IP address. Please flush your DNS cache manually."
    exit 1
fi

echo "${YELLOW}[ℹ]${RESET} Checking SSL to mb3admin.com..."
sleep 2
SSL_STATUS=$(echo | openssl s_client -connect mb3admin.com:443 -servername mb3admin.com 2>/dev/null | openssl x509 -noout -subject)

if [ $? -eq 0 ]; then
    echo "${GREEN}[✔]${RESET} SSL certificate is valid."
else
    echo "${RED}[✖]${RESET} SSL certificate is invalid or not trusted."
    exit 1
fi

sleep 2

clear

echo "${CYAN}"
cat << "EOF"
---------------------------------------------------------------
|                                                             |
|            Emby Premiere is now fully unlocked.             |
|      You can use any license key and enjoy all features!    |
|                                                             |
---------------------------------------------------------------
EOF
echo "${RESET}"

echo "${YELLOW}[ℹ]${RESET} If you want to support my work, please consider starring my GitHub repository!"
echo "${CYAN}[ℹ]${RESET} telegram: @arg0WAK"
echo ""

sleep 3

xdg-open https://github.com/arg0WAK

