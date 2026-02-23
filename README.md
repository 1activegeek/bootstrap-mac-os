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

## Profile Overlay

The base `Brewfile` installs all core packages. The interactive menu asks whether to also apply the **default profile overlay** (`profiles/Brewfile.default`), which adds:

- Work: Microsoft Teams, Azure CLI, Okta Verify
- Homelab: Flux CD, go-task, jq, sops, kustomize, yamllint, pre-commit

Answer **n** at the prompt to run base packages only. To add your own overlay, create `profiles/Brewfile.<name>` and pass `MACHINE_PROFILE=<name>` via `--unattended`.

---

## Key Design Decisions

| Component | Choice | Replaces |
|-----------|--------|----------|
| Orchestration | Pure bash | Ansible |
| Packages | `brew bundle` + Brewfile | Ansible homebrew tasks |
| Dotfiles | chezmoi | Mackup |
| Secrets | 1Password via chezmoi templates | — |
| ZSH prompt | Starship | Oh My Zsh themes |
| ZSH plugins | 16 modular `~/.zshrc.d/*.zsh` files | Oh My Zsh |
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
| `16-carapace.zsh` | carapace multi-shell argument completer |

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
# With default profile overlay (all extras)
MACHINE_PROFILE=default \
NEW_HOSTNAME=my-macbook \
DOTFILES_REPO=https://github.com/you/dotfiles.git \
./bootstrap.sh --unattended

# Base packages only (no overlay)
MACHINE_PROFILE="" \
NEW_HOSTNAME=my-macbook \
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

- **Packages:** Edit `Brewfile` (base) or `profiles/Brewfile.default` (overlay)
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

- Configure Kap shortcut (Cmd+Shift+3) in Kap Preferences (system screenshot shortcuts are disabled automatically)
- Set desktop wallpaper folders in System Settings > Wallpaper
- Set mouse cursor color in System Settings > Accessibility > Display
- Import Raycast settings backup
- Sign into app-specific accounts (Slack, Discord, etc.)

---

## Prior Version

The original Ansible-based bootstrap is preserved on the `master` branch.
