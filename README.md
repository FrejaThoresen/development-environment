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

## Post-Install Steps
The script prints these at the end, but here's the expanded version:

1. Reboot (for Docker group)
sudo reboot

Required so the docker group membership takes effect.

2. Verify Docker
docker ps

Should run without sudo.

3. Start opencode
From your project directory containing the docker-compose.yml:

docker compose build --no-cache
docker compose up --build -d
docker compose exec -it opencode /bin/bash
opencode auth login
opencode

4. Launch Neovim
nvim

If the script couldn't bootstrap plugins (e.g., headless mode failed), launching nvim interactively will trigger the plugin installer automatically.

5. Start tmux
tmux

Default prefix is Ctrl+b. Press ? for the keybinding list.

Architecture Support
Both x86_64 and aarch64 are supported. The script detects the architecture and selects the correct Neovim and Lazygit binaries accordingly.

Notes
fd-find: Debian/Ubuntu installs the binary as fdfind. The script symlinks it to /usr/local/bin/fd for Neovim compatibility.
Node.js: Only installed if absent or below version 22. Existing newer versions are left alone.
Docker: If Docker is already installed, the script skips installation but still verifies the service is running and the user is in the docker group.
Neovim config: The config lives in its own repo (FrejaThoresen/nvim-config). To customize, fork it and update the clone URL in the script.

