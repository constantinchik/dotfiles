---
name: home-assistant
description: Inspect and troubleshoot Home Assistant for the home-server project. Use when the user asks about Home Assistant state, logs, entities, configuration, Lovelace storage, Matter, HomeKit, or related Docker runtime behavior.
compatibility: opencode
---

# Home Assistant

Home Assistant runs **locally on this server** via Docker. Commands execute directly without SSH.

**Note:** This is the server-specific skill. On client machines, use SSH to access this server.

## Architecture

**This machine** (the mac mini server): Runs the Home Assistant Docker container and all related services natively.

All runtime operations use local Docker commands.

## Local Docker Access

Since Home Assistant runs on this server, use local Docker commands:

\`\`\`bash
# Check container status
docker compose ps homeassistant

# View recent logs
docker compose logs --tail=200 homeassistant

# Inspect container filesystem
docker exec home-assistant ls /config/.storage

# Restart Home Assistant
docker restart homeassistant
\`\`\`

### Discovering the Container Name

If the container name differs, discover it first:

\`\`\`bash
docker ps --format "{{.Names}}" | grep -i home
\`\`\`

## Configuration vs Runtime

**Configuration files** (edit locally in this repo):
- \`config/homeassistant/configuration.yaml\` - Main configuration
- \`config/homeassistant/ui-lovelace.yaml\` - Dashboard definitions
- \`config/homeassistant/automations.yaml\` - Automations
- \`config/homeassistant/scripts.yaml\` - Scripts
- \`config/homeassistant/scenes.yaml\` - Scenes

**Runtime data** (local on this machine):
- \`/config/.storage/\` - Entity registry, integration configs, state
- \`/config/home-assistant.log\` - Runtime logs
- Docker volumes and databases

## Deployment Workflow

1. **Edit** configuration files locally in \`config/homeassistant/\`
2. **Commit** changes to git
3. **Deploy** using the script (handles submodule updates and restart):
   \`\`\`bash
   ./deploy.sh
   \`\`\`

The deploy script will:
- Pull latest Home Assistant configuration from the submodule
- Create a backup automatically
- Restart the Home Assistant container
- Check for startup errors

## Project Documentation

For complete project documentation including:
- Full architecture overview
- Port conventions (40xxx for web services, 21064-21065 for HomeKit, etc.)
- Home Assistant YAML dashboard configuration guide
- Troubleshooting common issues (mDNS, Matter, HomeKit)
- Backup and restore procedures

See: \`/Users/cost/Projects/home-server/AGENTS.md\`

## Key Technical Details

- **Lovelace dashboards**: Defined in \`ui-lovelace.yaml\` (YAML mode), stored in git
- **Matter Server**: Native macOS service at \`ws://host.docker.internal:5580/ws\`  
- **HomeKit**: Uses \`scripts/homekit-mdns-proxy.sh\` for Bonjour advertisements on ports \`21064\` and \`21065\`
- **Secrets**: Never expose \`/config/secrets.yaml\`, \`.storage/\`, tokens, or backup contents
- **Backup location**: \`backups/\` directory (not committed to git)

## Useful Local Commands

\`\`\`bash
# Check HomeKit proxy status
./scripts/homekit-mdns-proxy.sh status

# View live logs
docker logs homeassistant -f

# Check Matter server
launchctl list | grep matter

# Validate YAML syntax
docker exec homeassistant python3 -c "import yaml; yaml.safe_load(open(\"/config/configuration.yaml\"))"
\`\`\`
