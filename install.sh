#!/bin/bash
set -ue

echo "📦 Setting up Container Restart Bot..."

# Ensure script is run with root privileges
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run as root (e.g. sudo ./setup.sh)"
  exit 1
fi

# Gets the user who invoked sudo
BOT_USER="$(logname)"
INSTALL_DIR="/usr/local/bin/container_restart"
VENV_PATH="$INSTALL_DIR/.venv"
SCRIPT_NAME="container_restart.py"
SERVICE_TEMPLATE="container_restart.service.template"
SERVICE_FILE="/etc/systemd/system/container_restart.service"

# Create nessecary folder
echo "📂 Creating directory: $INSTALL_DIR"
mkdir -p $INSTALL_DIR

# Create virtual environment and install dependencies
echo "🐍 Creating virtual environment at $VENV_PATH..."
# Ensure python3-venv is installed
PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if ! dpkg -s "python$PY_VER-venv" &> /dev/null; then
    echo "🔧 Installing python$PY_VER-venv..."
    sudo apt-get update
    sudo apt-get install -yq "python$PY_VER-venv"
else
    echo "✅ python$PY_VER-venv is already installed."
fi
python3 -m venv "$VENV_PATH"
echo "Installing requirements.txt"
"$VENV_PATH/bin/pip" install -q -r requirements.txt

# Copy Python script to known location
echo "📄 Installing bot to $INSTALL_DIR/$SCRIPT_NAME..."
cp "$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Copy .env.example to .env if it doesn't exist
if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp '.env.example' '.env'
    echo "✅ Created .env from .env.example."

    # Prompt the user to fill in required environment variables
    echo "🔧 Let's configure your .env file:"
    echo

    declare -A prompts=(
      ["BOT_TOKEN"]="Enter your Discord bot token"
      ["CONTAINER_NAME"]="Enter the Docker container name to restart"
      ["GUILD_ID"]="Enter your Discord server (guild) ID"
      ["VALID_USERS"]="Enter authorized Discord user IDs (comma-separated)"
    )

    for key in "${!prompts[@]}"; do
      current_value=$(grep "^$key=" '.env' | cut -d '=' -f2-)
      read -p "${prompts[$key]}: " input
      input=${input:-$current_value}
      # Escape any special characters in user input
      input_escaped=$(printf '%s\n' "$input" | sed -e 's/[\/&]/\\&/g')
      sed -i "s/^$key=.*/$key=\"$input_escaped\"/" '.env'
    done

    echo
    echo "✅ .env file configured!"
    mv '.env' "$INSTALL_DIR/.env"
    echo "Moved .env to installdir"
fi

# Generate systemd service
echo "⚙️ Installing systemd service as $BOT_USER..."
sed "s|REPLACE_WITH_USERNAME|$BOT_USER|g" "$SERVICE_TEMPLATE" > "$SERVICE_FILE"

# Reload and enable the service
echo "✅ Service installed. Starting it now..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now 'container_restart'
sudo systemctl start 'container_restart'

echo
echo "📋 Checking service status:"
if systemctl is-active --quiet container_restart; then
    echo "✅ Service is running."
else
    echo "❌ Service failed to start. Showing status log:"
    sudo systemctl status 'container_restart' --no-pager
    exit 1
fi


