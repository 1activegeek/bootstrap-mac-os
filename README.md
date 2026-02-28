# bootstrap-mac-os v2.1

Automated macOS setup using pure shell scripts, phased deployment, modular package selection, `brew bundle`, and `chezmoi`.

## Quick Start

```bash
/bin/bash -c "$(curl -fsSL https://git.thegeekybits.com/shawnmix/bootstrap-mac-os/raw/branch/v2/bootstrap.sh)"
```

Or run locally:

```bash
git clone https://git.thegeekybits.com/shawnmix/bootstrap-mac-os.git ~/.bootstrap
~/.bootstrap/bootstrap.sh
```

Note: the Gitea repo is currently the canonical source for `v2` testing.

## Deployment Model (4 Phases)

1. Phase 1 - Core Bootstrap
   - Installs bare minimum core module:
   - `chezmoi`, `gh`, `mas`, `1password`, `1password-cli`, `raycast`, `brave-browser`, `ghostty`, `handy`
2. Phase 2 - Core Config + Secrets
   - Runs config modules (`macOS defaults`, `zsh`, `chezmoi`, `autoupdate`)
   - Runs `1password` secrets deployment via chezmoi templates
   - Requires authenticated `op` CLI session
3. Phase 3 - Additional Modules
   - Installs optional package modules (developer tools, communication, media, infra, etc.)
4. Phase 4 - Final Customizations
   - Runs `dock`, `symlinks`, and `post-install validation`

## Interactive Modes

When you run `./bootstrap.sh`, you get an operation menu:

- Fresh bootstrap (default)
- Run Phase 2
- Run Phase 3
- Run Phase 4
- Update current apps
- Install modules
- Install individual apps

### Selection Defaults

- Fresh bootstrap defaults to `core` only.
- Phase 3 defaults to all additional modules selected (you can deselect).
- Install modules defaults to none selected.
- Install individual apps defaults to none selected.

## Single Package Config

All package/module definitions live in one file:

- `config/package-catalog.sh`

This file drives phase/module/app installs so package updates happen in one place.

## Flags

```bash
./bootstrap.sh                  # Interactive mode
./bootstrap.sh --unattended     # Non-interactive mode (use env vars)
./bootstrap.sh --phase2         # Run phase 2 directly
./bootstrap.sh --phase3         # Run phase 3 directly
./bootstrap.sh --phase4         # Run phase 4 directly
./bootstrap.sh --update         # Update installed packages/apps
./bootstrap.sh --dry-run        # Preview actions without making changes
./bootstrap.sh --debug          # Verbose debug logging
```

`--dry-run` can be combined with other flags (for example `--phase3 --dry-run`).

## Useful Unattended Examples

```bash
# Phase 1 core only
BOOTSTRAP_MODE=fresh ./bootstrap.sh --unattended

# Phase 3 with selected modules
BOOTSTRAP_MODE=phase3 \
SELECTED_MODULES=dev-cli,dev-gui,communication \
./bootstrap.sh --unattended

# Install individual apps later
BOOTSTRAP_MODE=install-apps \
SELECTED_PACKAGE_KEYS=cask:slack,cask:chatgpt,mas:497799835 \
./bootstrap.sh --unattended

# Preview without making any changes
BOOTSTRAP_MODE=phase3 \
SELECTED_MODULES=dev-cli,communication \
./bootstrap.sh --unattended --dry-run
```

## Notes

- Dotfiles source repo defaults to `https://github.com/1activegeek/dotfiles.git` (override with `DOTFILES_REPO`).
- Phase 2 performs a readiness checkpoint and blocks if `op` is not authenticated.
- Mac App Store sign-in is reminded before/around Phase 2 because MAS installs require it.
- Package installs are resilient: if one package fails, the installer continues and prints a final success/skip/failure summary.
