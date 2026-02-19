# Bootstrap macOS v2 — Complete Install List

> Generated from `Brewfile` + `profiles/Brewfile.*`  
> Verified: 2026-02-18 · macOS Sequoia 15.x · Apple Silicon  
> **ALL profiles** share the base list. Profile additions are called out separately.

---

## Homebrew Taps

| Tap | Purpose |
|-----|---------|
| `homebrew/bundle` | Brewfile support |
| `homebrew/services` | Service management |
| `hashicorp/tap` | Terraform (official HashiCorp tap) |
| `anomalyco/tap` | opencode CLI |

**Homelab profile adds:**

| Tap | Purpose |
|-----|---------|
| `fluxcd/tap` | Flux CD |
| `weaveworks/tap` | Weave GitOps |
| `go-task/tap` | go-task (Taskfile) |

---

## Homebrew Formulae (CLI Tools)

### Shell & Terminal

| Formula | Description |
|---------|-------------|
| `atuin` | Shell history with sync + fuzzy search (replaces Ctrl+R) |
| `eza` | Modern `ls` replacement with icons and git status |
| `fastfetch` | System info display (replaces deprecated neofetch) |
| `fzf` | Fuzzy finder for files, processes, git branches |
| `starship` | Cross-shell prompt (replaces Oh My Zsh themes) |
| `zellij` | Terminal multiplexer (replaces tmux) |
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
| `dockutil` | Dock management via CLI |
| `duti` | Set default applications for file types |
| `mas` | Mac App Store CLI installer |
| `mole` | SSH tunnel manager |
| `pinentry-mac` | GPG pinentry dialog via macOS Keychain |
| `pygments` | Python syntax highlighting library |
| `switchaudio-osx` | CLI audio device switcher |
| `watch` | Run commands on a repeating interval |

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
| `weaveworks/tap/gitops` | Weave GitOps CLI |
| `crane` | Interact with container image registries |
| `direnv` | Per-directory environment variable loading |
| `go-task/tap/go-task` | Taskfile runner (modern make alternative) |
| `ipcalc` | IP address and subnet calculator |
| `jq` | JSON processor and query tool |
| `kustomize` | Kubernetes configuration customization |
| `pre-commit` | Git hook framework |
| `sops` | Secrets OPerationS — config file encryption |
| `stern` | Multi-pod Kubernetes log tailing |
| `yamllint` | YAML linter |

---

## Homebrew Casks (GUI Applications)

### Security & Password Management

| Cask | App Name | Description |
|------|----------|-------------|
| `1password` | 1Password 8 | Password manager |
| `1password-cli` | 1Password CLI (`op`) | CLI for chezmoi secrets integration |

### Productivity

| Cask | App Name | Description |
|------|----------|-------------|
| `clickup` | ClickUp | Project and task management |
| `notion` | Notion | Notes, wikis, and documents |
| `notion-calendar` | Notion Calendar | Calendar linked to Notion |
| `notion-mail` | Notion Mail | Email client linked to Notion |
| `pronotes` | ProNotes | Quick notes |
| `raycast` | Raycast | Launcher, automation, and productivity hub |

### Browsers

| Cask | App Name | Description |
|------|----------|-------------|
| `firefox` | Firefox | Mozilla Firefox |
| `google-chrome` | Google Chrome | Chrome browser |
| `tor-browser` | Tor Browser | Privacy-focused Tor network browser |

### Communication

| Cask | App Name | Description |
|------|----------|-------------|
| `discord` | Discord | Gaming and community chat |
| `signal` | Signal | End-to-end encrypted messaging |
| `slack` | Slack | Team messaging and collaboration |
| `zoom` | Zoom | Video conferencing |

**Work profile adds:**

| Cask | App Name | Description |
|------|----------|-------------|
| `microsoft-teams` | Microsoft Teams | Microsoft corporate communication |

### Development

| Cask | App Name | Description |
|------|----------|-------------|
| `docker` | Docker Desktop | Container platform |
| `drawio` | draw.io | Diagramming tool |
| `ghostty` | Ghostty | GPU-accelerated terminal emulator |
| `orbstack` | OrbStack | Fast, lightweight Docker and Linux on Mac |
| `postman` | Postman | API design and testing platform |
| `powershell` | PowerShell | Cross-platform shell from Microsoft |
| `sequel-ace` | Sequel Ace | MySQL / MariaDB database client |
| `visual-studio-code` | Visual Studio Code | Code editor |

### Media & Content

| Cask | App Name | Description |
|------|----------|-------------|
| `handbrake` | HandBrake | Open-source video transcoder |
| `kap` | Kap | Screen recorder (also replaces Cmd+Shift+3) |
| `obs` | OBS Studio | Streaming and screen recording |
| `subler` | Subler | MP4/MKV metadata editor |
| `vlc` | VLC | Universal media player |

### Utilities

| Cask | App Name | Description |
|------|----------|-------------|
| `android-file-transfer` | Android File Transfer | Transfer files to/from Android devices |
| `appcleaner` | AppCleaner | Thorough app uninstaller |
| `balenaetcher` | balenaEtcher | Flash OS images to USB/SD cards |
| `browserosaurus` | Browserosaurus | Browser picker on link open ⚠️ Deprecated Aug 2026 |
| `cyberduck` | Cyberduck | FTP, S3, and cloud storage browser |
| `dash` | Dash | Offline API documentation browser |
| `disk-inventory-x` | Disk Inventory X | Disk usage treemap visualizer |
| `flux` | f.lux | Screen color temperature adjustment |
| `jordanbaird-ice` | Ice | Menu bar item manager (replaces Vanilla/Stats) |
| `keka` | Keka | Archive utility (zip, rar, 7z, etc.) |
| `keyboard-cowboy` | Keyboard Cowboy | Keyboard shortcut automation |
| `knockknock` | KnockKnock | Persistent process and startup item monitor |
| `latest` | Latest | App update checker |
| `leader-key` | Leader Key | Leader-key based keyboard shortcut launcher |
| `lunar` | Lunar | External monitor brightness and color control |
| `mactracker` | Mactracker | Apple hardware specifications database |
| `mullvadvpn` | Mullvad VPN | Privacy-focused VPN client |
| `raspberry-pi-imager` | Raspberry Pi Imager | Flash Raspberry Pi OS to SD cards |
| `session-manager-plugin` | AWS Session Manager Plugin | AWS SSM Session Manager CLI plugin |
| `shottr` | Shottr | Screenshot tool with annotation and OCR |
| `suspicious-package` | Suspicious Package | Inspect .pkg installers before running |
| `taskexplorer` | TaskExplorer | Process and network activity inspector |
| `teamviewer` | TeamViewer | Remote desktop and support |
| `the-unarchiver` | The Unarchiver | Archive extraction (many formats) |
| `utm` | UTM | Virtual machine manager for Apple Silicon |
| `wireshark` | Wireshark | Network protocol analyzer |

### AI Tools

| Cask | App Name | Description |
|------|----------|-------------|
| `anythingllm` | AnythingLLM | Local AI document assistant |
| `chatgpt` | ChatGPT | OpenAI ChatGPT desktop app |
| `lm-studio` | LM Studio | Run local LLMs with a GUI |
| `ollama` | Ollama | Run local LLMs via CLI |

### 3D Printing & Design

| Cask | App Name | Description |
|------|----------|-------------|
| `blender` | Blender | 3D creation suite |
| `eufymake-studio` | EufyMake Studio | Slicer for AnkerMake/EufyMake printers |
| `openscad` | OpenSCAD | Programmatic 3D CAD modeler |
| `orcaslicer` | OrcaSlicer | 3D printing slicer (Bambu, Prusa, etc.) |
| `shapr3d` | Shapr3D | Professional 3D CAD for Mac and iPad |

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
| PayPal Honey | 1472777122 | Automatic coupon finder |
| Raindrop.io | 1549370672 | Bookmark manager |
| Userscripts | 1463298887 | Run custom scripts in Safari |

### Productivity & Apps

| App | MAS ID | Description |
|-----|--------|-------------|
| Actions | 1586435171 | Additional actions for Apple Shortcuts |
| AudioBookBinder | 413969927 | Combine audio files into audiobooks |
| Data Jar | 1453273600 | Structured data store for Shortcuts |
| Disk Speed Test | 425264550 | Measure disk read/write performance |
| DuckDuckGo | 663592361 | DuckDuckGo privacy browser |
| Exporter | 1099120373 | Export iMessages to text/PDF |
| Just Focus | 1142151959 | Pomodoro focus timer |
| Microsoft Remote Desktop | 1295203466 | RDP client for Windows/Azure |
| Perplexity | 6714467650 | AI-powered search assistant |
| Presentify | 1507246666 | Screen annotation during presentations |
| Tailscale | 1475387142 | Mesh VPN network |
| Twitter | 1482454543 | Official Twitter/X client |
| WireGuard | 1451685025 | WireGuard VPN client |
| Xcode | 497799835 | Apple developer tools and simulator |

---

## Manual Installs (No Homebrew Cask Available)

These applications must be downloaded and installed manually:

| App | Where to Get It | Reason |
|-----|----------------|--------|
| **Enconvo** | [enconvo.com](https://www.enconvo.com) | No Homebrew cask exists |
| **AnkerSlicer** | [ankerstore.com](https://www.ankerstore.com) | No Homebrew cask exists |
| **Fusion 360** | [autodesk.com](https://www.autodesk.com/products/fusion-360) | No Homebrew cask (subscription required) |
| **Dia Browser** | App website | Not widely distributed |
| **AudiobookBinder** | App Store (MAS ID above) | MAS only, no cask |
| **Thumbhost 3MF** | App Store | MAS only |

---

## Totals by Profile

| Category | Base (All Profiles) | +Work | +Homelab |
|----------|--------------------:|------:|---------:|
| Taps | 4 | — | 3 |
| Formulae | 27 | 1 | 11 |
| Casks | 52 | 1 | — |
| MAS Apps | 20 | — | — |
| **Total packages** | **103** | **+2** | **+14** |

---

## Notes & Caveats

| Item | Note |
|------|------|
| `browserosaurus` | Deprecated by upstream — will be disabled in Homebrew August 2026. Remove or find replacement before then. |
| `lm-studio` | Correct cask token. The token `lmstudio` (no hyphen) does **not** exist. |
| `dockutil` | Installed as a **formula**, not a cask. |
| `mole` | Installed as a **formula**, not a cask. |
| `eufymake-studio` | Replaces the deprecated `ankermake` cask (discontinued upstream). |
| `anythingllm` | Token is `anythingllm` (not `anythinglm`). |
| Audible | **Not** on the Mac App Store (iOS only). Removed from list. |
| MAS apps | Require being signed into the Mac App Store **before** running `brew bundle`. |
| LuLu / BlockBlock | Installed last to avoid security permission popups interrupting the rest of setup. |
| 1Password / CLI | Installed in the **first batch** of casks — required for Phase 2 secrets deployment. |
