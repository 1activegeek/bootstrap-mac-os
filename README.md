# bootstrap-mac-os v2

Automated macOS setup using pure shell scripts, `brew bundle`, `chezmoi`, and modular ZSH.  
Replaces the previous Ansible-based approach with a lean, dependency-free bootstrap.

---

## Quick Start (fresh machine)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/1activegeek/bootstrap-mac-os/v2/bootstrap.sh)"
```

Or clone and run locally:

```bash
git clone https://github.com/1activegeek/bootstrap-mac-os.git ~/.bootstrap
~/.bootstrap/bootstrap.sh
```

---

## Before You Run

Complete these steps first — the script can't do them for you:

1. **Boot and set up macOS** — complete the welcome wizard and create your user account
2. **Sign into your Apple ID** — required for iCloud sync and Mac App Store
3. **Open the Mac App Store** — sign in so MAS apps install correctly
4. **Let iCloud sync** — wait for Documents / Desktop sync to complete (Obsidian configs, etc.)

---

## What It Does

```
bootstrap.sh
    │
    ▼
Interactive menu (profile, hostname, module toggles)
    │
    ▼
PHASE 1 — unattended after menu
  ├── 01 Homebrew + brew bundle (base Brewfile + profile overlay)
  ├── 02 Set hostname (optional)
  ├── 03 macOS system defaults
  ├── 04 Dock configuration (dockutil)
  ├── 05 ZSH setup (creates ~/.zshrc.d/)
  ├── 06 Chezmoi dotfiles (non-sensitive)
  ├── 07 Symlinks (~/projects, ~/.claude)
  └── 08 Homebrew autoupdate
    │
    ▼
PAUSE — sign into 1Password (GUI + CLI)
    │
    ▼
PHASE 2 — unattended
  ├── 09 Secrets via chezmoi + 1Password (SSH keys, etc.)
  └── 10 Post-install validation + summary
```

---

## Machine Profiles

| Profile    | Description                                      |
|------------|--------------------------------------------------|
| `personal` | Full personal setup (default)                   |
| `work`     | Work tools + personal base (adds Microsoft Teams, Azure CLI) |
| `homelab`  | K8s/GitOps focus (adds Flux, SOPS, go-task, etc.) |
| `minimal`  | Core tools only, no K8s/cloud modules            |

Each profile has an optional `profiles/Brewfile.<profile>` overlay on top of the base `Brewfile`.

---

## Key Design Decisions

| Component | Choice | Replaces |
|-----------|--------|----------|
| Orchestration | Pure bash | Ansible |
| Packages | `brew bundle` + Brewfile | Ansible homebrew tasks |
| Dotfiles | chezmoi | Mackup |
| Secrets | 1Password via chezmoi templates | — |
| ZSH prompt | Starship | Oh My Zsh themes |
| ZSH plugins | 15 modular `~/.zshrc.d/*.zsh` files | Oh My Zsh |
| Shell history | atuin | ZSH built-in history |
| Directory nav | zoxide | cd |
| ls | eza | ls |
| Terminal mux | zellij | tmux |
| System info | fastfetch | neofetch |

---

## ZSH Modules (`~/.zshrc.d/`)

| File | Purpose |
|------|---------|
| `01-history.zsh` | History config + atuin |
| `02-aliases.zsh` | Generic aliases (eza-based ls, navigation) |
| `03-git.zsh` | Git aliases + helpers |
| `04-brew.zsh` | Homebrew aliases |
| `05-macos.zsh` | macOS helpers (showfiles, flushdns, etc.) |
| `06-docker.zsh` | Docker + Compose aliases |
| `07-1password.zsh` | 1Password CLI helpers + SSH agent |
| `08-extract.zsh` | Universal archive extractor |
| `09-colorize.zsh` | Terminal color tests |
| `10-kubectl.zsh` | Kubernetes aliases + completion |
| `11-kube-ps1.zsh` | K8s context in prompt (kube-ps1) |
| `12-kubectx.zsh` | kubectx/kubens aliases |
| `13-sudo.zsh` | Esc-Esc to prepend sudo |
| `14-fzf.zsh` | fzf config + fbr/fkill helpers |
| `15-zoxide.zsh` | zoxide smart cd |

---

## Flags

```bash
./bootstrap.sh                  # Interactive mode (default)
./bootstrap.sh --unattended     # Skip menu, use env vars/defaults
./bootstrap.sh --phase2         # Resume Phase 2 after 1Password setup
./bootstrap.sh --debug          # Verbose debug logging
```

**Environment variables for `--unattended`:**

```bash
MACHINE_PROFILE=work \
NEW_HOSTNAME=my-macbook \
DOTFILES_REPO=https://github.com/you/dotfiles.git \
./bootstrap.sh --unattended
```

---

## Repository Structure

```
bootstrap-mac-os/
├── bootstrap.sh          # Entry point
├── Brewfile               # All packages (taps, formulae, casks, MAS)
├── lib/
│   ├── utils.sh           # Logging, helpers, module runner
│   ├── checks.sh          # Validation functions
│   └── menu.sh            # Interactive menu
├── modules/               # 10 modular install scripts
├── profiles/              # Profile-specific Brewfiles + shell config
├── config/                # Dock and other data files
└── dotfiles/              # Reference copy of chezmoi-managed files
```

Dotfiles are managed in a **separate repo**: `github.com/1activegeek/dotfiles`  
The `dotfiles/` directory here contains a reference copy of what chezmoi manages.

---

## Customisation

- **Packages:** Edit `Brewfile` and `profiles/Brewfile.<profile>`
- **macOS defaults:** Edit `modules/03-macos-defaults.sh`
- **Dock layout:** Edit `modules/04-dock.sh`
- **ZSH aliases:** Add/edit files in `dotfiles/dot_zshrc.d/`
- **Prompt:** Edit `dotfiles/dot_config/starship.toml`

---

## Phase 2: Resume After 1Password

If you quit after Phase 1 and want to run Phase 2 later:

```bash
# Authenticate 1Password CLI first
eval $(op signin)

# Then run Phase 2
./bootstrap.sh --phase2
```

---

## Manual Steps After Bootstrap

These cannot be fully automated:

- Configure Kap shortcut (Cmd+Shift+3) in Kap Preferences
- Disable screenshot shortcut in System Settings > Keyboard Shortcuts
- Set desktop wallpaper folders in System Settings > Wallpaper
- Set mouse cursor color in System Settings > Accessibility > Display
- Place `~/.ssh/id_gitea` key (raw, for Obsidian/Gitea sync)
- Import Raycast settings backup
- Sign into app-specific accounts (Slack, Discord, etc.)
- Install [enconvo](https://www.enconvo.com) manually (no Homebrew cask)
- Install AnkerSlicer manually (no Homebrew cask)

---

## Prior Version

The original Ansible-based bootstrap is preserved on the `master` branch.
