# Brewfile Diff Report — Current Machine vs. v2 Bootstrap

> Generated: 2026-02-21 (updated after user review)
> Current machine dump: `brew bundle dump` (live, captured 2026-02-19)  
> New Brewfile: `Brewfile` + `profiles/Brewfile.work` + `profiles/Brewfile.homelab`

---

## Summary

| Category | In v2 | Not in v2 (dropped) |
|----------|------:|--------------------:|
| Taps | 3 base + 2 homelab | `homebrew/autoupdate` (runtime), `hpedrorodrigues/tools` (obsolete), `weaveworks/tap` (dropped) |
| Formulae | 36 base + 9 homelab + 1 work | ~20 formulae intentionally dropped |
| Casks | 50 base + 1 work | ~15 casks intentionally dropped |
| MAS Apps | 20 base + 1 work | ~8 MAS apps intentionally dropped |
| VS Code Extensions | not tracked | 76 — handled by VS Code Settings Sync |

---

## Taps

### In v2
| Tap | Scope | Note |
|-----|-------|------|
| `hashicorp/tap` | base | Terraform official tap |
| `anomalyco/tap` | base | opencode CLI |
| `oven-sh/bun` | base | Bun JavaScript runtime |
| `fluxcd/tap` | homelab | Flux CD |
| `go-task/tap` | homelab | go-task (Taskfile) |

### Dropped / Not in v2
| Tap | Why |
|-----|-----|
| `homebrew/bundle` | Built into Homebrew core — no longer needs explicit tap |
| `homebrew/services` | Built into Homebrew core — no longer needs explicit tap |
| `homebrew/autoupdate` | Configured at runtime by `08-homebrew-autoupdate.sh` — not in Brewfile |
| `hpedrorodrigues/tools` | Was old `dockutil` tap — `dockutil` is now in homebrew-core |
| `weaveworks/tap` | Weave GitOps CLI dropped per user decision |

---

## Formulae (CLI Tools)

### In v2 — New (not currently installed on machine)
| Formula | Description |
|---------|-------------|
| `bat` | Better `cat` with syntax highlighting |
| `bat-extras` | bat integrations (batgrep, batman, etc.) |
| `carapace` | Multi-shell argument completer |
| `fabric-ai` | AI augmentation framework |
| `fastfetch` | System info display (replaces neofetch) |
| `fd` | Fast `find` replacement |
| `ffmpeg` | Audio/video conversion |
| `gemini-cli` | Google Gemini CLI |
| `gh` | GitHub CLI |
| `hashicorp/tap/terraform` | Terraform via official tap (replaces bare `terraform`) |
| `kustomize` | Kubernetes config customization (homelab) |
| `oven-sh/bun/bun` | Bun JavaScript runtime |
| `tmux` | Terminal multiplexer (re-added; kept alongside zellij) |
| `yamllint` | YAML linter (homelab) |
| `yt-dlp` | Audio/video downloader |

### Dropped from v2 (currently installed but removed)
| Formula | Why Removed |
|---------|-------------|
| `ansible` | Replaced by pure shell scripts — core reason for v2 |
| `crane` | Container registry tool — dropped per user decision |
| `docker` | Formula replaced by `docker` **cask** (Docker Desktop) |
| `docker-compose` | Bundled with Docker Desktop cask |
| `docutils` | Python doc tool — not in scope |
| `gnu-sed` | Not in scope |
| `minicom` | Serial terminal — not in scope |
| `mise` | Runtime manager — install manually; not universal enough for base |
| `mysql-client` | Install manually per-project |
| `nmap` | Network scanner — install manually if needed |
| `ollama` | Moved to **cask** (Ollama has a proper GUI cask) |
| `openjdk` | Install via mise/manually per-project |
| `openssl@1.1` | Legacy OpenSSL — not needed in base bootstrap |
| `picocom` | Serial terminal — not in scope |
| `pinentry-mac` | GPG pinentry — dropped per user decision |
| `pipx` | Install manually |
| `pulumi` | Install manually if needed |
| `pyenv` | Replaced by mise |
| `ruby@3.2` | Install via mise/manually per-project |
| `stern` | Multi-pod K8s log tailing — dropped per user decision |
| `terraform` | Replaced by `hashicorp/tap/terraform` (official tap) |
| `tweakcc` | Install manually if needed |
| `uv` | Install manually |
| `virtualenv` | Install manually |
| `weaveworks/tap/gitops` | Weave GitOps CLI — dropped per user decision |

### Kept (present on machine and in v2)
`age` · `anomalyco/tap/opencode` · `atuin` · `awscli` · `azure-cli` · `chezmoi` · `chroma` · `direnv` · `dockutil` · `duti` · `eza` · `fluxcd/tap/flux` · `fzf` · `go-task/tap/go-task` · `helm` · `ipcalc` · `jq` · `k9s` · `kube-ps1` · `kubectx` · `kubernetes-cli` · `mas` · `mole` · `pre-commit` · `pygments` · `sops` · `starship` · `switchaudio-osx` · `watch` · `zellij` · `zoxide` · `zsh-autosuggestions` · `zsh-syntax-highlighting`

---

## Casks (GUI Applications)

### In v2 — New (not currently installed on machine)
| Cask | App | Description |
|------|-----|-------------|
| `antigravity` | Antigravity | AI coding IDE |
| `bambu-studio` | Bambu Studio | Bambu Lab slicer |
| `brave-browser` | Brave Browser | Privacy-focused browser |
| `claude` | Claude | Anthropic Claude desktop app |
| `claude-code` | Claude Code | Claude Code CLI |
| `codex` | Codex | OpenAI Codex agent |
| `eufymake-studio` | EufyMake Studio | AnkerMake/EufyMake slicer (replaces deprecated `ankermake` cask) |
| `flux` | f.lux | Screen color temp (correct token; replaces old `flux-app`) |
| `gcloud-cli` | Google Cloud CLI | Google Cloud SDK |
| `handy` | Handy | Speech-to-text with LLM reformatting |
| `handbrake` | HandBrake | Video transcoder (correct token; replaces old `handbrake-app`) |
| `home-assistant` | Home Assistant | Home Assistant companion app |
| `lm-studio` | LM Studio | Local LLM GUI runner (correct token; replaces old `lmstudio`) |
| `obsidian` | Obsidian | Knowledge base and note-taking |
| `opencode-desktop` | opencode Desktop | opencode desktop client |
| `prusaslicer` | PrusaSlicer | PrusaSlicer for 3D printing |
| `superwhisper` | SuperWhisper | Dictation tool with LLM reformatting |
| `tailscale` | Tailscale | Mesh VPN (cask; replaces old `tailscale-app` and MAS entry) |
| `thumbhost3mf` | Thumbhost 3MF | Finder thumbnails for .3mf files (cask, not MAS) |
| `yaak` | Yaak | REST, GraphQL and gRPC API client |

### Dropped from v2 (currently installed but removed)
| Cask | App | Why Removed |
|------|-----|-------------|
| `android-file-transfer` | Android File Transfer | Dropped per user decision |
| `anythingllm` | AnythingLLM | Dropped per user decision |
| `blender` | Blender | Dropped per user decision |
| `clickup` | ClickUp | Dropped per user decision |
| `cyberduck` | Cyberduck | Dropped per user decision |
| `dash` | Dash | Dropped per user decision |
| `drawio` | draw.io | Dropped per user decision |
| `firefox` | Firefox | Dropped per user decision |
| `jordanbaird-ice` | Ice | Dropped per user decision |
| `latest` | Latest | Dropped per user decision |
| `microsoft-auto-update` | Microsoft AutoUpdate | Installed automatically by Microsoft apps |
| `mullvadvpn` | Mullvad VPN | Dropped per user decision |
| `notion` | Notion | Dropped per user decision |
| `notion-calendar` | Notion Calendar | Dropped per user decision |
| `notion-mail` | Notion Mail | Dropped per user decision |
| `openscad` | OpenSCAD (stable) | Outdated 2021.01 — replaced by `openscad@snapshot` |
| `postman` | Postman | Dropped per user decision (replaced by `yaak`) |
| `powershell` | PowerShell | Dropped per user decision |
| `pronotes` | ProNotes | Dropped per user decision |
| `raspberry-pi-imager` | Raspberry Pi Imager | Dropped per user decision |
| `sequel-ace` | Sequel Ace | Dropped per user decision |
| `session-manager-plugin` | AWS Session Manager Plugin | Dropped per user decision |
| `signal` | Signal | Dropped per user decision |
| `subler` | Subler | Dropped per user decision |
| `suspicious-package` | Suspicious Package | Dropped per user decision |
| `teamviewer` | TeamViewer | Dropped per user decision |
| `utm` | UTM | Dropped per user decision |
| `wireshark` | Wireshark | Dropped per user decision |

### Kept (present on machine and in v2)
`1password` · `1password-cli` · `appcleaner` · `balenaetcher` · `blockblock` · `browserosaurus` · `chatgpt` · `discord` · `disk-inventory-x` · `docker` · `font-jetbrains-mono-nerd-font` · `ghostty` · `google-chrome` · `kap` · `keka` · `keyboard-cowboy` · `knockknock` · `leader-key` · `lulu` · `lunar` · `mactracker` · `microsoft-teams` (work) · `obs` · `ollama` · `openscad@snapshot` · `orbstack` · `raycast` · `shapr3d` · `shottr` · `slack` · `taskexplorer` · `the-unarchiver` · `tor-browser` · `visual-studio-code` · `vlc` · `zoom`

---

## Mac App Store Apps

### In v2 — New (not currently installed on machine)
| App | MAS ID | Note |
|-----|--------|------|
| Hush | 1544743900 | Cookie/notification banner blocker |
| Microsoft Remote Desktop | 1295203466 | |
| Obsidian Web Clipper | 6720708363 | |
| Okta Verify | 490179405 | Work profile only |
| Raycast Companion | 6738274497 | |
| The Camelizer | 1532579087 | Amazon price tracker |
| uBlock Origin Lite | 6745342698 | Safari ad blocker |

### Dropped from v2 (currently installed but removed)
| App | MAS ID | Why Removed |
|-----|--------|-------------|
| Actions For Obsidian | 1659667937 | Dropped per user decision |
| AudioBookBinder | 413969927 | Dropped per user decision |
| Disk Speed Test | 425264550 | Dropped per user decision |
| Exporter | 1099120373 | Dropped per user decision |
| Just Focus | 1142151959 | Dropped per user decision |
| Presentify | 1507246666 | Dropped per user decision |
| Raindrop.io | 1549370672 | Dropped per user decision |
| Tailscale | 1475387142 | Moved to cask (`tailscale`) |
| Twitter | 1482454543 | Dropped per user decision |
| WireGuard | 1451685025 | Dropped per user decision |

### Kept (present on machine and in v2)
`1Password for Safari` · `Actions` · `Auto HD FPS for YouTube` · `Data Jar` · `DuckDuckGo` · `DuckDuckGo Privacy Essentials` · `PayPal Honey` · `Perplexity` · `Userscripts` · `Xcode`

---

## VS Code Extensions

76 extensions are currently installed and tracked by `brew bundle dump`.  
**The v2 Brewfile does not manage VS Code extensions** — this is intentional, as VS Code's Settings Sync (backed by GitHub or Microsoft account) handles extension sync automatically.

**Action:** Sign into VS Code Settings Sync on a new machine and extensions restore automatically.

---

## Token / Category Corrections Applied

| Old (wrong) | New (correct) | Note |
|-------------|---------------|------|
| `flux-app` | `flux` | Correct cask token |
| `handbrake-app` | `handbrake` | Correct cask token |
| `lmstudio` | `lm-studio` | Correct cask token |
| `mullvad-vpn` | `mullvadvpn` | Correct cask token |
| `openscad@snapshot` was removed → | `openscad@snapshot` restored | Stable `openscad` is outdated 2021.01; snapshot is 2026.x |
| `wireshark-app` | `wireshark` | Correct cask token |
| `dockutil` (cask) | `dockutil` (formula) | Correct install type |
| `mole` (cask) | `mole` (formula) | Correct install type |
| `ollama` (formula) | `ollama` (cask) | GUI cask preferred |
| `tailscale-app` or MAS | `tailscale` (cask) | Cask preferred for auto-updates |
| `thumbhost3mf` (MAS) | `thumbhost3mf` (cask) | Confirmed cask via `brew info --cask thumbhost3mf` |
| `homebrew/bundle` tap | removed | Built into Homebrew core |
| `homebrew/services` tap | removed | Built into Homebrew core |
