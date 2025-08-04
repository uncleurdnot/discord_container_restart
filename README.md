# discord_container_restart
I wanted to allow my friend to restart one of my docker containers as needed, without giving him ssh or portainer access.

## INSTALLATION
clone the repository, then run
```
sudo ./install.sh
📦 Setting up Container Restart Bot...
📂 Creating directory: /usr/local/bin/container_restart
🐍 Creating virtual environment at /usr/local/bin/container_restart/.venv...
✅ python3.12-venv is already installed.
Installing requirements.txt
📄 Installing bot to /usr/local/bin/container_restart/container_restart.py...
✅ Created .env from .env.example.
🔧 Let's configure your .env file:

Enter your Discord server (guild) ID: INPUT
Enter the Docker container name to restart: INPUT
Enter authorized Discord user IDs (comma-separated): INPUT
Enter your Discord bot token: INPUT

✅ .env file configured!
Moved .env to installdir
⚙️ Installing systemd service as quentin...
✅ Service installed. Starting it now...

📋 Checking service status:
✅ Service is running.
```

If you need help finding your userID or guild (server) id:

* Go to your User Settings in your Discord client. On Desktop, you can access User Settings by clicking on the cogwheel icon near the bottom-left, next to your username.
* Click on Advanced tab from the left-hand sidebar and toggle on Developer Mode.
* Right click on your username in discord and select "copy user ID"
* Right click on your target server in discord and select "copy server ID"

In discord, you should get an option for `/restart` as a slash command.  When you type this, it will restart the targeted server.

This could be made more general, enabling it to restart more than just one specified server, or allow certain roles to preform certain actions, but at this time I have no intent to expand for this functionality.

