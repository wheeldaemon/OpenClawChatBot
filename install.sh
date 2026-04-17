#!/bin/bash
set -e
echo "=== OpenClawChatBot Installer (OpenRouter) ==="
[ "$EUID" -ne 0 ] && { echo "Run with sudo"; exit 1; }
apt-get update -y
apt-get install -y curl git python3 python3-pip python3-venv systemd rsync
BOT_USER="qwenbot"
BOT_DIR="/opt/qwenbot"
ENV_FILE="$BOT_DIR/.env"
id "$BOT_USER" &>/dev/null || useradd -r -m -d "$BOT_DIR" -s /bin/bash "$BOT_USER"
mkdir -p "$BOT_DIR" "$BOT_DIR/workspace" "$BOT_DIR/data"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -r "$SCRIPT_DIR/bot" "$SCRIPT_DIR/workspace" "$SCRIPT_DIR/data" "$SCRIPT_DIR/requirements.txt" "$BOT_DIR/" 2>/dev/null || true
chown -R "$BOT_USER:$BOT_USER" "$BOT_DIR"
echo ">>> OpenRouter:"
read -p "OPENROUTER_API_KEY: " OR_KEY
read -p "MODEL_NAME: " MODEL
read -p "TELEGRAM_BOT_TOKEN: " TG_TOKEN
read -p "TELEGRAM_CHAT_ID: " TG_ID
read -p "GROQ_API_KEY (optional): " GROQ
cat > "$ENV_FILE" <<EOENV
OPENROUTER_API_KEY=$OR_KEY
MODEL_NAME=$MODEL
TELEGRAM_BOT_TOKEN=$TG_TOKEN
TELEGRAM_CHAT_ID=$TG_ID
GROQ_API_KEY=$GROQ
QWEN_TIMEOUT=600
WORKSPACE_DIR=$BOT_DIR/workspace
DATA_DIR=$BOT_DIR/data
EOENV
chmod 600 "$ENV_FILE"
chown "$BOT_USER:$BOT_USER" "$ENV_FILE"
cd "$BOT_DIR"
python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt 2>/dev/null || pip install aiogram python-dotenv requests
cat > "/etc/systemd/system/qwenbot.service" <<EOSVC
[Unit]
Description=OpenClawChatBot
After=network.target
[Service]
User=$BOT_USER
WorkingDirectory=$BOT_DIR
EnvironmentFile=$ENV_FILE
ExecStart=$BOT_DIR/venv/bin/python3 $BOT_DIR/bot/main.py
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOSVC
systemctl daemon-reload
systemctl enable qwenbot
echo "=== Done! ==="
echo "Start: systemctl start qwenbot"
echo "Logs: journalctl -u qwenbot -f"
