# Dev Environment Setup

One-shot install script for spinning up a consistent development environment on Ubuntu/Debian Linux. Designed to work identically on local machines and fresh VMs.

## What It Installs

| Component      | Source                        | Notes                                              |
|----------------|-------------------------------|----------------------------------------------------|
| Base packages  | `apt`                         | git, gcc, g++, make, ripgrep, fd-find, unzip, curl, xclip, vim, tmux, libreadline-dev |
| Node.js 22     | NodeSource                    | Required for Copilot and other Neovim LSP tools    |
| Neovim         | GitHub releases (latest stable) | Symlinked to `/usr/local/bin/nvim`. Supports x86_64 and aarch64 |
| Lazygit        | GitHub releases (latest)      | Installed to `/usr/local/bin/lazygit`              |
| Neovim config  | `FrejaThoresen/nvim-config`   | Cloned to `~/.config/nvim`; plugins bootstrapped via `Lazy! sync` |
| Docker CE      | Docker's official repo        | Includes buildx and compose plugins. User added to `docker` group for no-sudo usage |

## Prerequisites

- Ubuntu or Debian Linux (tested on apt-based systems)
- `sudo` privileges
- Internet connection

## Usage

```bash
chmod +x install_script.sh
./install_script.sh
```

## Post-Install Steps
The script prints these at the end, but here's the expanded version:

1. Reboot (for Docker group)
```bash
sudo reboot
```

Required so the docker group membership takes effect.

2. Verify Docker
```bash
docker ps
```

Should run without sudo.

The docker-compose file contains the general setup. The ${PWD} resolves to wherever you run the command from (your project dir), and ${DEVENV_DIR} points to the dev-env repo. The opencode.json line mounts your personal config into the container at runtime - no copying needed.

Set environment variables in your shell profile
Add to ~/.bashrc or ~/.zshrc:

```bash
export DEVENV_DIR="$HOME/development-environment/docker"
export COMPOSE_FILE="$DEVENV_DIR/docker-compose.yml"
```

COMPOSE_FILE tells Docker Compose to always use your compose file, so from any project directory you just run:
```bash
export CONTAINER_NAME=my-project        # name for this container (defaults to "opencode")
docker compose up -d --build
docker compose exec -it opencode /bin/bash
```

`CONTAINER_NAME` sets the container's name, so you can run several containers with different names. To run fully independent instances at the same time (separate containers and volumes), also set a distinct project name before each one:
```bash
export CONTAINER_NAME=project-a
export COMPOSE_PROJECT_NAME=project-a
docker compose up -d --build
```

3. Start opencode
From your project directory containing the docker-compose.yml:

```bash
docker compose build --no-cache
docker compose up --build -d
docker compose exec -it opencode /bin/bash
opencode auth login
opencode
```

Optional: Before you start opencode, do make install and source .venv/bin/activate if you want opencode in your python env.

4. Launch Neovim
Preferably, first activate env
```bash
source .venv/bin/activate
nvim
```

If the script couldn't bootstrap plugins (e.g., headless mode failed), launching nvim interactively will trigger the plugin installer automatically.

5. Start tmux
```bash
tmux
```

Default prefix is Ctrl+b. Press ? for the keybinding list.

Architecture Support
Both x86_64 and aarch64 are supported. The script detects the architecture and selects the correct Neovim and Lazygit binaries accordingly.

Notes
fd-find: Debian/Ubuntu installs the binary as fdfind. The script symlinks it to /usr/local/bin/fd for Neovim compatibility.
Node.js: Only installed if absent or below version 22. Existing newer versions are left alone.
Docker: If Docker is already installed, the script skips installation but still verifies the service is running and the user is in the docker group.
Neovim config: The config lives in its own repo (FrejaThoresen/nvim-config). To customize, fork it and update the clone URL in the script.

# Optional setup
Use kitty terminal, and see the github repository https://github.com/dexpota/kitty-themes for themes.


If you want molten, do

```bash
source .venv/bin/activate 
uv add ipykernel
python -m ipykernel install --user --name "$(basename $PWD)"
```
