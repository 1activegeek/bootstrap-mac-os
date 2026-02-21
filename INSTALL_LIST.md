# Bootstrap macOS v2 — Complete Install List

> Generated from `Brewfile` + `profiles/Brewfile.*`  
> Last updated: 2026-02-21 · macOS Sequoia 15.x · Apple Silicon  
> **ALL profiles** share the base list. Profile additions are called out separately.

---

## Homebrew Taps

| Tap | Purpose |
|-----|---------|
| `hashicorp/tap` | Terraform (official HashiCorp tap) |
| `anomalyco/tap` | opencode CLI |
| `oven-sh/bun` | Bun JavaScript runtime |

**Homelab profile adds:**

| Tap | Purpose |
|-----|---------|
| `fluxcd/tap` | Flux CD |
| `go-task/tap` | go-task (Taskfile) |

---

## Homebrew Formulae (CLI Tools)

### Shell & Terminal

| Formula | Description |
|---------|-------------|
| `atuin` | Shell history with sync + fuzzy search (replaces Ctrl+R) |
| `bat` | Better `cat` with syntax highlighting |
| `bat-extras` | bat integrations: batgrep, batman, batdiff, etc. |
| `carapace` | Multi-shell multi-command argument completer |
| `eza` | Modern `ls` replacement with icons and git status |
| `fastfetch` | System info display (replaces deprecated neofetch) |
| `fd` | Fast `find` replacement (used by fzf as default command) |
| `fzf` | Fuzzy finder for files, processes, git branches |
| `starship` | Cross-shell prompt (replaces Oh My Zsh themes) |
| `tmux` | Terminal multiplexer (keeping alongside zellij for now) |
| `zellij` | Modern terminal multiplexer |
| `zoxide` | Smart `cd` with frecency ranking |
| `zsh-autosuggestions` | Fish-style inline command suggestions |
| `zsh-syntax-highlighting` | Live command syntax highlighting |

### Dotfile & Config Management

| Formula | Description |
|---------|-------------|
| `chezmoi` | Dotfile manager with 1Password template support |

### Core Utilities

| Formula | Description |
|---------|-------------|
| `age` | Modern file encryption |
| `awscli` | AWS command-line interface |
| `chroma` | Syntax highlighting library |
| `dockutil` | Dock management via CLI (formula, not cask) |
| `duti` | Set default applications for file types |
| `fabric-ai` | AI augmentation framework (fabric) |
| `ffmpeg` | Audio/video conversion and streaming |
| `gemini-cli` | Google Gemini AI command-line interface |
| `gh` | GitHub CLI |
| `mas` | Mac App Store CLI installer |
| `mole` | SSH tunnel manager (formula, not cask) |
| `pygments` | Python syntax highlighting library |
| `switchaudio-osx` | CLI audio device switcher |
| `watch` | Run commands on a repeating interval |
| `yt-dlp` | Feature-rich audio/video downloader |

### JavaScript Runtime

| Formula | Description |
|---------|-------------|
| `oven-sh/bun/bun` | Bun — fast JavaScript runtime, bundler, and package manager |

### DevOps & Infrastructure

| Formula | Description |
|---------|-------------|
| `helm` | Kubernetes package manager |
| `k9s` | Kubernetes cluster terminal UI |
| `kube-ps1` | K8s context/namespace in shell prompt |
| `kubectx` | Fast Kubernetes context/namespace switching |
| `kubernetes-cli` | kubectl |
| `hashicorp/tap/terraform` | Terraform IaC tool (HashiCorp official tap) |

### AI & Developer Tools

| Formula | Description |
|---------|-------------|
| `anomalyco/tap/opencode` | opencode — AI coding assistant CLI |

---

### Work Profile — Additional Formulae

| Formula | Description |
|---------|-------------|
| `azure-cli` | Microsoft Azure command-line interface |

### Homelab Profile — Additional Formulae

| Formula | Description |
|---------|-------------|
| `fluxcd/tap/flux` | Flux CD — GitOps continuous delivery operator |
| `direnv` | Per-directory environment variable loading |
| `go-task/tap/go-task` | Taskfile runner (modern make alternative) |
| `ipcalc` | IP address and subnet calculator |
| `jq` | JSON processor and query tool |
| `kustomize` | Kubernetes configuration customization |
| `pre-commit` | Git hook framework |
| `sops` | Secrets OPerationS — config file encryption |
| `yamllint` | YAML linter |

---

## Homebrew Casks (GUI Applications)

### Security & Password Management

| Cask | App Name | Description |
|------|----------|-------------|
| `1password` | 1Password 8 | Password manager (installed early — needed for auth) |
| `1password-cli` | 1Password CLI (`op`) | CLI for chezmoi secrets integration |

### Productivity

| Cask | App Name | Description |
|------|----------|-------------|
| `raycast` | Raycast | Launcher, automation, and productivity hub |

### Browsers

| Cask | App Name | Description |
|------|----------|-------------|
| `brave-browser` | Brave Browser | Privacy-focused browser |
| `google-chrome` | Google Chrome | Chrome browser |
| `tor-browser` | Tor Browser | Privacy-focused Tor network browser |

### Communication

| Cask | App Name | Description |
|------|----------|-------------|
| `discord` | Discord | Gaming and community chat |
| `slack` | Slack | Team messaging and collaboration |
| `zoom` | Zoom | Video conferencing |

**Work profile adds:**

| Cask | App Name | Description |
|------|----------|-------------|
| `microsoft-teams` | Microsoft Teams | Microsoft corporate communication |

### Development

| Cask | App Name | Description |
|------|----------|-------------|
| `antigravity` | Antigravity | AI coding IDE |
| `claude` | Claude | Anthropic Claude desktop app |
| `claude-code` | Claude Code | Claude Code CLI |
| `codex` | Codex | OpenAI Codex agent |
| `docker` | Docker Desktop | Container platform |
| `gcloud-cli` | Google Cloud CLI | Google Cloud SDK |
| `ghostty` | Ghostty | GPU-accelerated terminal emulator |
| `opencode-desktop` | opencode Desktop | opencode desktop client |
| `orbstack` | OrbStack | Fast, lightweight Docker and Linux on Mac |
| `visual-studio-code` | Visual Studio Code | Code editor |
| `yaak` | Yaak | REST, GraphQL and gRPC API client |

### Media & Content

| Cask | App Name | Description |
|------|----------|-------------|
| `handbrake` | HandBrake | Open-source video transcoder |
| `kap` | Kap | Screen recorder |
| `obs` | OBS Studio | Streaming and screen recording |
| `vlc` | VLC | Universal media player |

### AI Tools

| Cask | App Name | Description |
|------|----------|-------------|
| `chatgpt` | ChatGPT | OpenAI ChatGPT desktop app |
| `lm-studio` | LM Studio | Run local LLMs with a GUI |
| `ollama` | Ollama | Run local LLMs via CLI |

### Utilities

| Cask | App Name | Description |
|------|----------|-------------|
| `appcleaner` | AppCleaner | Thorough app uninstaller |
| `balenaetcher` | balenaEtcher | Flash OS images to USB/SD cards |
| `browserosaurus` | Browserosaurus | Browser picker on link open ⚠️ Deprecated Aug 2026 |
| `disk-inventory-x` | Disk Inventory X | Disk usage treemap visualizer |
| `flux` | f.lux | Screen color temperature adjustment |
| `handy` | Handy | Speech-to-text with LLM reformatting |
| `home-assistant` | Home Assistant | Home Assistant companion app |
| `keka` | Keka | Archive utility (zip, rar, 7z, etc.) |
| `keyboard-cowboy` | Keyboard Cowboy | Keyboard shortcut automation |
| `knockknock` | KnockKnock | Persistent process and startup item monitor |
| `leader-key` | Leader Key | Leader-key based keyboard shortcut launcher |
| `lunar` | Lunar | External monitor brightness and color control |
| `mactracker` | Mactracker | Apple hardware specifications database |
| `obsidian` | Obsidian | Knowledge base and note-taking |
| `shottr` | Shottr | Screenshot tool with annotation and OCR |
| `superwhisper` | SuperWhisper | Dictation tool with LLM reformatting |
| `tailscale` | Tailscale | Mesh VPN (cask preferred over MAS) |
| `taskexplorer` | TaskExplorer | Process and network activity inspector |
| `thaw` | Thaw | Unfreeze stuck macOS apps |
| `the-unarchiver` | The Unarchiver | Archive extraction (many formats) |

### 3D Printing & Design

| Cask | App Name | Description |
|------|----------|-------------|
| `bambu-studio` | Bambu Studio | Bambu Lab slicer |
| `eufymake-studio` | EufyMake Studio | Slicer for AnkerMake/EufyMake printers |
| `openscad@snapshot` | OpenSCAD (Snapshot) | Programmatic 3D CAD modeler (snapshot build — stable is outdated 2021) |
| `orcaslicer` | OrcaSlicer | 3D printing slicer (Bambu, Prusa, etc.) |
| `prusaslicer` | PrusaSlicer | PrusaSlicer for 3D printing |
| `shapr3d` | Shapr3D | Professional 3D CAD for Mac and iPad |
| `thumbhost3mf` | Thumbhost 3MF | Finder thumbnail previews for .3mf files |

### Fonts

| Cask | App Name | Description |
|------|----------|-------------|
| `font-jetbrains-mono-nerd-font` | JetBrains Mono Nerd Font | Coding font with Nerd Font icons |

### Security (Installed Last)

| Cask | App Name | Description |
|------|----------|-------------|
| `lulu` | LuLu | Outbound network firewall |
| `blockblock` | BlockBlock | Monitors macOS persistence locations |

---

## Mac App Store Apps

### Safari Extensions

| App | MAS ID | Description |
|-----|--------|-------------|
| 1Password for Safari | 1569813296 | 1Password browser extension |
| Auto HD FPS for YouTube | 1546729687 | Force HD quality on YouTube |
| DuckDuckGo Privacy Essentials | 1482920575 | DuckDuckGo tracker blocking extension |
| Hush | 1544743900 | Cookie/notification banner blocker |
| PayPal Honey | 1472777122 | Automatic coupon finder |
| The Camelizer | 1532579087 | Amazon price history tracker |
| uBlock Origin Lite | 6745342698 | Ad blocker for Safari |
| Userscripts | 1463298887 | Run custom scripts in Safari |

### Obsidian Extensions

| App | MAS ID | Description |
|-----|--------|-------------|
| Obsidian Web Clipper | 6720708363 | Clip web content to Obsidian |

### Productivity & Apps

| App | MAS ID | Description |
|-----|--------|-------------|
| Actions | 1586435171 | Additional actions for Apple Shortcuts |
| Data Jar | 1453273600 | Structured data store for Shortcuts |
| DuckDuckGo | 663592361 | DuckDuckGo privacy browser |
| Microsoft Remote Desktop | 1295203466 | RDP client for Windows/Azure |
| Perplexity | 6714467650 | AI-powered search assistant |
| Raycast Companion | 6738274497 | Raycast companion app |
| Xcode | 497799835 | Apple developer tools and simulator |

**Work profile adds:**

| App | MAS ID | Description |
|-----|--------|-------------|
| Okta Verify | 490179405 | Work SSO authenticator |

---

## Manual Installs (No Homebrew Cask Available)

These applications must be downloaded and installed manually:

| App | Where to Get It | Reason |
|-----|----------------|--------|
| **Enconvo** | [enconvo.com](https://www.enconvo.com) | No Homebrew cask exists |
| **AnkerSlicer** | [ankerstore.com](https://www.ankerstore.com) | No Homebrew cask exists |
| **Fusion 360** | [autodesk.com](https://www.autodesk.com/products/fusion-360) | No Homebrew cask (subscription required) |

---

## Totals by Profile

| Category | Base (All Profiles) | +Work | +Homelab |
|----------|--------------------:|------:|---------:|
| Taps | 3 | — | 2 |
| Formulae | 36 | 1 | 9 |
| Casks | 50 | 1 | — |
| MAS Apps | 14 | 1 | — |
| **Total packages** | **103** | **+3** | **+11** |

---

## Notes & Caveats

| Item | Note |
|------|------|
| `browserosaurus` | Deprecated by upstream — will be disabled in Homebrew August 2026. Remove or find replacement before then. |
| `lm-studio` | Correct cask token. The token `lmstudio` (no hyphen) does **not** exist. |
| `dockutil` | Installed as a **formula**, not a cask. |
| `mole` | Installed as a **formula**, not a cask. |
| `eufymake-studio` | Replaces the deprecated `ankermake` cask (discontinued upstream). |
| `thumbhost3mf` | Installed as a **cask** (not MAS). Confirmed via `brew info --cask thumbhost3mf`. |
| `tailscale` | Installed as a **cask** (not MAS). Cask preferred for auto-updates. |
| `homebrew/bundle` | Built into Homebrew core — no longer needs to be listed as a tap. |
| `homebrew/services` | Built into Homebrew core — no longer needs to be listed as a tap. |
| `homebrew/autoupdate` | Configured at runtime by `08-homebrew-autoupdate.sh` — not in Brewfile. |
| Audible | **Not** on the Mac App Store (iOS only). Not included. |
| MAS apps | Require being signed into the Mac App Store **before** running `brew bundle`. |
| LuLu / BlockBlock | Installed last to avoid security permission popups interrupting the rest of setup. |
| 1Password / CLI | Installed in the **first batch** of casks — required for Phase 2 secrets deployment. |
| VS Code extensions | Intentionally **not tracked** in Brewfile — VS Code Settings Sync handles this. |
