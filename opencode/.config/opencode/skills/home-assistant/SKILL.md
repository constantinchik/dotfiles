---
name: home-assistant
description: Inspect and troubleshoot Home Assistant for the home-server project. Use when the user asks about Home Assistant state, logs, entities, configuration, Lovelace storage, Matter, HomeKit, or related Docker runtime behavior.
compatibility: opencode
---

# Home Assistant

Home Assistant runs on a remote host (reachable via `ssh home`), not on the client machine where this agent is currently running.

## Architecture

**Client machine** (where you are now): Contains this repository with configuration files and scripts.
**Remote host** (`home`): Runs the actual Home Assistant Docker container and all related services.

All runtime operations (checking logs, restarting containers, viewing state) require SSH access to the remote host.

## Access via SSH

Since Home Assistant runs remotely, you must use SSH to execute any runtime commands:

```bash
# Check container status
ssh home 'docker compose ps homeassistant'

# View recent logs
ssh home 'docker compose logs --tail=200 homeassistant'

# Inspect container filesystem
ssh home 'docker exec home-assistant ls /config/.storage'

# Restart Home Assistant
ssh home 'docker restart homeassistant'
```

### Discovering the Container Name

If the container name differs, discover it first:

```bash
ssh home 'docker ps --format "{{.Names}}" | grep -i home'
```

## Local Configuration vs Remote Runtime

**Configuration files** (edit locally in this repo):
- `config/homeassistant/configuration.yaml` - Main configuration
- `config/homeassistant/ui-lovelace.yaml` - Dashboard definitions
- `config/homeassistant/automations.yaml` - Automations
- `config/homeassistant/scripts.yaml` - Scripts
- `config/homeassistant/scenes.yaml` - Scenes

**Runtime data** (on remote host only):
- `/config/.storage/` - Entity registry, integration configs, state
- `/config/home-assistant.log` - Runtime logs
- Docker volumes and databases

## Deployment Workflow

1. **Edit** configuration files locally in `config/homeassistant/`
2. **Commit** changes to git
3. **Deploy** using the script (handles submodule updates and restart):
   ```bash
   ./deploy.sh
   ```

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

See: `/Users/cost/Projects/home-server/AGENTS.md`

## Key Technical Details

- **Lovelace dashboards**: Defined in `ui-lovelace.yaml` (YAML mode), stored in git
- **Matter Server**: Native macOS service at `ws://host.docker.internal:5580/ws`  
- **HomeKit**: Uses `scripts/homekit-mdns-proxy.sh` for Bonjour advertisements on ports `21064` and `21065`
- **Secrets**: Never expose `/config/secrets.yaml`, `.storage/`, tokens, or backup contents
- **Backup location**: `backups/` directory (not committed to git)

## Useful Remote Commands

```bash
# Check HomeKit proxy status
ssh home './scripts/homekit-mdns-proxy.sh status'

# View live logs
ssh home 'docker logs homeassistant -f'

# Check Matter server
ssh home 'launchctl list | grep matter'

# Validate YAML syntax
ssh home 'docker exec homeassistant python3 -c "import yaml; yaml.safe_load(open(\"/config/configuration.yaml\"))"'
```
