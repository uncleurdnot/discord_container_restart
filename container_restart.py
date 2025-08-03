import docker
import discord
from dotenv import load_dotenv
from os import getenv

# Load environment variables
load_dotenv()

# Docker client
docker_client = docker.from_env()
CONTAINER_NAME = getenv("CONTAINER_NAME")
VALID_USERS = [uid.strip() for uid in getenv("VALID_USERS", "").split(",")]  # comma-separated list of user IDs as strings
BOT_TOKEN = getenv("BOT_TOKEN")
GUILD_ID = int(getenv("GUILD_ID"))
guild = discord.Object(id=GUILD_ID)

if not all([BOT_TOKEN, CONTAINER_NAME, GUILD_ID]):
    raise RuntimeError("Missing required environment variables!")


# Discord bot setup
intents = discord.Intents.default()
activity = discord.Game(name="/restart")
bot = discord.Client(intents=intents, activity=activity)
tree = discord.app_commands.CommandTree(bot)

@bot.event
async def on_ready():
    print(f"✅ Logged in as {bot.user} (ID: {bot.user.id})")
    try:
        tree.clear_commands(guild=None)
        print("Cleared global commands.")
        await tree.sync(guild=guild)
        print("✅ Slash commands synced.")
    except Exception as e:
        print(f"Error syncing commands: {e}")

@tree.command(name="restart", description="Restart the FoundryVTT container", guild=guild)
async def restart(interaction: discord.Interaction):
    if str(interaction.user.id) not in VALID_USERS:
        print(f"{interaction.user.id} not in {VALID_USERS}")
        await interaction.response.send_message("❌ Unauthorized.", ephemeral=True)
        return

    await interaction.response.send_message("🔄 Restarting container...", ephemeral=True)
    print(f"Container restart initiated by {interaction.user.name}")
    try:
        container = docker_client.containers.get(CONTAINER_NAME)
        container.restart()
        await interaction.followup.send(f"✅ Restarted container `{CONTAINER_NAME}`.", ephemeral=True)
        print("Container successfully restarted.")
    except Exception as e:
        await interaction.followup.send(f"❌ Error: {e}", ephemeral=True)

# Start the bot
bot.run(BOT_TOKEN)
