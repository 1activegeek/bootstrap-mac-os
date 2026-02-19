# Brewfile Diff Report — Current Machine vs. v2 Bootstrap

> Generated: 2026-02-19  
> Current machine dump: `brew bundle dump` (live)  
> New Brewfile: `Brewfile` + `profiles/Brewfile.work` + `profiles/Brewfile.homelab`

---

## Summary

| Category | New | Removed | Kept | Total in v2 |
|----------|----:|--------:|-----:|------------:|
| Taps | +2 | -3 | 5 | 7 |
| Formulae | +8 | -32 | 33 | 41 |
| Casks | +32 | -23 | 35 | 67 |
| MAS Apps | +10 | -7 | 9 | 19 |
| VS Code Extensions | — | — | 76 | not tracked |

---

## Taps

### ++ New (2)
These taps are in the v2 Brewfile but not currently installed:

| Tap | Note |
|-----|------|
| `homebrew/bundle` | Required for Brewfile support |
| `homebrew/services` | Required for service management |

### -- Removed (3)
Currently tapped but not in v2 Brewfile:

| Tap | Note |
|-----|------|
| `homebrew/autoupdate` | Configured by `08-homebrew-autoupdate.sh` at runtime — not needed in Brewfile |
| `hpedrorodrigues/tools` | Was old `dockutil` tap — dockutil no longer needs it |
| `oven-sh/bun` | Bun dropped from bootstrap (installed via mise/other means if needed) |

### == Kept (5)
`anomalyco/tap` · `fluxcd/tap` · `go-task/tap` · `hashicorp/tap` · `weaveworks/tap`

---

## Formulae (CLI Tools)

### ++ New (8)
In the v2 Brewfile but not currently installed:

| Formula | Description |
|---------|-------------|
| `crane` | Container image registry tool (homelab) |
| `fastfetch` | System info display (replaces neofetch) |
| `fluxcd/tap/flux` | Flux CD GitOps operator (homelab) |
| `hashicorp/tap/terraform` | Terraform via official tap (replaces bare `terraform`) |
| `kustomize` | Kubernetes config customization (homelab) |
| `pinentry-mac` | GPG pinentry via macOS Keychain |
| `stern` | Multi-pod Kubernetes log tailing (homelab) |
| `yamllint` | YAML linter (homelab) |

### -- Removed (32)
Currently installed but intentionally dropped from v2:

| Formula | Why Removed |
|---------|-------------|
| `ansible` | Replaced by pure shell scripts — core reason for v2 |
| `bat` | Nice tool but not in base bootstrap scope; install manually if needed |
| `bat-extras` | Same as above |
| `carapace` | Shell completion tool — not in bootstrap scope |
| `docker` | Docker formula replaced by `docker` **cask** (Docker Desktop) |
| `docker-compose` | Bundled with Docker Desktop cask |
| `docutils` | Python doc tool — not in scope |
| `fabric-ai` | AI framework — install manually if needed |
| `fd` | Fast find replacement — not in base scope (used by fzf optionally) |
| `ffmpeg` | Video tool — install manually if needed |
| `gemini-cli` | Google Gemini CLI — not in scope |
| `gh` | GitHub CLI — install manually if needed |
| `gnu-sed` | GNU sed — not in scope |
| `minicom` | Serial terminal — not in scope |
| `mise` | Runtime manager — install manually; not universal enough for base |
| `mysql-client` | DB client — install manually per-project |
| `nmap` | Network scanner — install manually if needed |
| `ollama` | Moved to **cask** (Ollama has a proper GUI cask now) |
| `openjdk` | Java — install via mise/manually per-project |
| `openssl@1.1` | Legacy OpenSSL — not needed in base bootstrap |
| `oven-sh/bun/bun` | Bun dropped; install via mise if needed |
| `picocom` | Serial terminal — not in scope |
| `pipx` | Python tool installer — install manually |
| `pulumi` | IaC tool — install manually if needed |
| `pyenv` | Python version mgr — replaced by mise |
| `ruby@3.2` | Ruby — install via mise/manually per-project |
| `terraform` | Replaced by `hashicorp/tap/terraform` (official tap) |
| `tmux` | Replaced by `zellij` |
| `tweakcc` | Claude Code tweaks — install manually if needed |
| `uv` | Python package manager — install manually |
| `virtualenv` | Python venv — install manually |
| `yt-dlp` | YouTube downloader — install manually if needed |

### == Kept (33)
`age` · `anomalyco/tap/opencode` · `atuin` · `awscli` · `azure-cli` · `chezmoi` · `chroma` · `direnv` · `dockutil` · `duti` · `eza` · `fzf` · `go-task/tap/go-task` · `helm` · `ipcalc` · `jq` · `k9s` · `kube-ps1` · `kubectx` · `kubernetes-cli` · `mas` · `mole` · `pre-commit` · `pygments` · `sops` · `starship` · `switchaudio-osx` · `watch` · `weaveworks/tap/gitops` · `zellij` · `zoxide` · `zsh-autosuggestions` · `zsh-syntax-highlighting`

---

## Casks (GUI Applications)

### ++ New (32)
In the v2 Brewfile but not currently installed:

| Cask | App | Description |
|------|-----|-------------|
| `android-file-transfer` | Android File Transfer | Android device file access |
| `anythingllm` | AnythingLLM | Local AI document assistant |
| `blender` | Blender | 3D creation suite |
| `clickup` | ClickUp | Project management |
| `cyberduck` | Cyberduck | FTP/S3/cloud file browser |
| `dash` | Dash | Offline API documentation |
| `docker` | Docker Desktop | Container platform (GUI) |
| `drawio` | draw.io | Diagramming |
| `eufymake-studio` | EufyMake Studio | AnkerMake/EufyMake slicer (replaces deprecated `ankermake` cask) |
| `firefox` | Firefox | Mozilla Firefox browser |
| `flux` | f.lux | Screen color temp (replaces `flux-app` which had wrong token) |
| `handbrake` | HandBrake | Video transcoder (replaces `handbrake-app`) |
| `latest` | Latest | App update checker |
| `lm-studio` | LM Studio | Local LLM GUI runner |
| `mullvadvpn` | Mullvad VPN | VPN client (replaces `mullvad-vpn`) |
| `notion` | Notion | Notes and wikis |
| `notion-calendar` | Notion Calendar | Calendar |
| `notion-mail` | Notion Mail | Email client |
| `ollama` | Ollama | Local LLM runner (moved from formula to cask) |
| `openscad` | OpenSCAD | Programmatic 3D CAD (replaces `openscad@snapshot`) |
| `orcaslicer` | OrcaSlicer | 3D printing slicer |
| `postman` | Postman | API testing |
| `powershell` | PowerShell | Microsoft cross-platform shell |
| `pronotes` | ProNotes | Quick notes |
| `sequel-ace` | Sequel Ace | MySQL/MariaDB database client |
| `session-manager-plugin` | AWS Session Manager Plugin | AWS SSM CLI plugin |
| `signal` | Signal | Encrypted messaging |
| `subler` | Subler | MP4/MKV metadata editor |
| `suspicious-package` | Suspicious Package | Inspect .pkg installers |
| `teamviewer` | TeamViewer | Remote desktop |
| `utm` | UTM | Virtual machines on Apple Silicon |
| `wireshark` | Wireshark | Network analyzer (replaces `wireshark-app`) |

### -- Removed (23)
Currently installed but intentionally dropped from v2:

| Cask | App | Why Removed |
|------|-----|-------------|
| `antigravity` | Antigravity | AI IDE — not in bootstrap scope; install manually |
| `bambu-studio` | Bambu Studio | Slicer — replaced by OrcaSlicer (works with Bambu too) |
| `brave-browser` | Brave | Browser — not in base scope; install manually |
| `claude` | Claude | Desktop AI app — not needed with opencode/ChatGPT |
| `claude-code` | Claude Code | CLI — install manually post-bootstrap |
| `codex` | Codex | OpenAI CLI agent — not in scope |
| `dockutil` | dockutil | Was wrong (cask); now correctly a **formula** |
| `flux-app` | f.lux | Wrong cask token — replaced by correct `flux` |
| `gcloud-cli` | Google Cloud CLI | Not in base scope; install manually if needed |
| `handbrake-app` | HandBrake | Wrong cask token — replaced by correct `handbrake` |
| `handy` | Handy | Speech-to-text — not in scope; install manually |
| `home-assistant` | Home Assistant | Smart home — not in bootstrap scope |
| `microsoft-auto-update` | Microsoft AutoUpdate | Installed by Microsoft apps automatically |
| `mullvad-vpn` | Mullvad VPN | Wrong cask token — replaced by correct `mullvadvpn` |
| `obsidian` | Obsidian | Notes app — configured via dotfiles, not bootstrap |
| `opencode-desktop` | opencode Desktop | CLI via formula preferred |
| `openscad@snapshot` | OpenSCAD Snapshot | Replaced by stable `openscad` |
| `prusaslicer` | PrusaSlicer | Slicer — replaced by OrcaSlicer |
| `superwhisper` | SuperWhisper | Dictation — not in scope; install manually |
| `tailscale-app` | Tailscale | Wrong token — Tailscale is in MAS (id: 1475387142) |
| `thumbhost3mf` | Thumbhost 3MF | MAS-only app — moved to manual install list |
| `wireshark-app` | Wireshark | Wrong cask token — replaced by correct `wireshark` |
| `yaak` | Yaak | API client — replaced by Postman in base |

### == Kept (35)
`1password` · `1password-cli` · `appcleaner` · `balenaetcher` · `blockblock` · `browserosaurus` · `chatgpt` · `discord` · `disk-inventory-x` · `font-jetbrains-mono-nerd-font` · `ghostty` · `google-chrome` · `jordanbaird-ice` · `kap` · `keka` · `keyboard-cowboy` · `knockknock` · `leader-key` · `lulu` · `lunar` · `mactracker` · `microsoft-teams` · `obs` · `orbstack` · `raspberry-pi-imager` · `raycast` · `shapr3d` · `shottr` · `slack` · `taskexplorer` · `the-unarchiver` · `tor-browser` · `visual-studio-code` · `vlc` · `zoom`

---

## Mac App Store Apps

### ++ New (10)
In v2 but not currently installed:

| App | MAS ID |
|-----|--------|
| AudioBookBinder | 413969927 |
| Disk Speed Test | 425264550 |
| Exporter | 1099120373 |
| Just Focus | 1142151959 |
| Microsoft Remote Desktop | 1295203466 |
| Presentify | 1507246666 |
| Raindrop.io | 1549370672 |
| Tailscale | 1475387142 |
| Twitter | 1482454543 |
| WireGuard | 1451685025 |

### -- Removed (7)
Currently installed via MAS but dropped from v2:

| App | MAS ID | Why Removed |
|-----|--------|-------------|
| Actions For Obsidian | 1659667937 | Obsidian-specific — install manually if using Obsidian |
| Hush | 1544743900 | Safari extension — not in base scope |
| Obsidian Web Clipper | 6720708363 | Obsidian-specific — install manually |
| Okta Verify | 490179405 | Work SSO — add to `profiles/Brewfile.work` if needed |
| Raycast Companion | 6738274497 | Installed automatically by Raycast |
| The Camelizer | 1532579087 | Amazon price tracker — install manually if needed |
| uBlock Origin Lite | 6745342698 | Ad blocker — install manually via Safari Extension Gallery |

### == Kept (9)
`1Password for Safari` · `Actions` · `Auto HD FPS for YouTube` · `Data Jar` · `DuckDuckGo` · `PayPal Honey` · `Perplexity` · `Userscripts` · `Xcode`

---

## VS Code Extensions

76 extensions are currently installed and tracked by `brew bundle dump`.  
**The v2 Brewfile does not manage VS Code extensions** — this is intentional, as VS Code's Settings Sync (backed by GitHub or Microsoft account) handles extension sync automatically.

**Action:** Sign into VS Code Settings Sync on a new machine and extensions restore automatically. No manual Brewfile management needed.

<details>
<summary>Full list of 76 currently installed extensions</summary>

`1password.op-vscode` · `alexdauenhauer.catppuccin-noctis` · `anthropic.claude-code` · `bierner.color-info` · `bierner.emojisense` · `bierner.markdown-checkbox` · `blueglassblock.better-json5` · `catppuccin.catppuccin-vsc` · `christian-kohler.npm-intellisense` · `christian-kohler.path-intellisense` · `codespaces-contrib.codeswing` · `davraamides.todotxt-mode` · `dbaeumer.vscode-eslint` · `docker.docker` · `eamodio.gitlens` · `editorconfig.editorconfig` · `esbenp.prettier-vscode` · `formulahendry.auto-close-tag` · `formulahendry.code-runner` · `github.copilot-chat` · `github.vscode-github-actions` · `github.vscode-pull-request-github` · `golang.go` · `google.geminicodeassist` · `googlecloudtools.cloudcode` · `growthjack.claude-code-usage` · `haihxiao.oaslinter` · `hashicorp.terraform` · `hediet.vscode-drawio` · `humao.rest-client` · `hverlin.mise-vscode` · `ibm.output-colorizer` · `irongeek.vscode-env` · `kamikillerto.vscode-colorize` · `keesschollaart.vscode-home-assistant` · `kelvin.vscode-sshfs` · `mhutchie.git-graph` · `mikestead.dotenv` · `mitchdenny.ecdc` · `ms-azuretools.vscode-containers` · `ms-azuretools.vscode-docker` · `ms-kubernetes-tools.vscode-kubernetes-tools` · `ms-python.debugpy` · `ms-python.isort` · `ms-python.python` · `ms-python.vscode-pylance` · `ms-python.vscode-python-envs` · `ms-toolsai.jupyter` · `ms-toolsai.jupyter-keymap` · `ms-toolsai.jupyter-renderers` · `ms-toolsai.vscode-jupyter-cell-tags` · `ms-toolsai.vscode-jupyter-slideshow` · `ms-vscode-remote.remote-containers` · `ms-vscode-remote.remote-ssh` · `ms-vscode-remote.remote-ssh-edit` · `ms-vscode.cpptools` · `ms-vscode.powershell` · `ms-vscode.remote-explorer` · `openai.chatgpt` · `pkief.material-icon-theme` · `rarnoldmobile.todo-txt` · `redhat.ansible` · `redhat.java` · `redhat.vscode-commons` · `redhat.vscode-yaml` · `samuelcolvin.jinjahtml` · `signageos.signageos-vscode-sops` · `sst-dev.opencode` · `streetsidesoftware.code-spell-checker` · `takumii.markdowntable` · `tamasfe.even-better-toml` · `tomoki1207.pdf` · `vsls-contrib.codetour` · `vsls-contrib.gistfs` · `william-voyek.vscode-nginx` · `yzhang.markdown-all-in-one`

</details>

---

## Action Items from This Diff

### Things to consider adding back to the Brewfile

| Item | Category | Reason to Consider |
|------|----------|--------------------|
| `gh` (GitHub CLI) | formula | Widely used; integrates with VS Code, copilot, etc. |
| `fd` | formula | Fast file finder; used by fzf's `FZF_DEFAULT_COMMAND` in `14-fzf.zsh` |
| `bat` | formula | Better `cat`; pairs well with fzf preview panes |
| `obsidian` | cask | You use it heavily — consider adding back |
| `thumbhost3mf` | MAS | You have it installed; useful for 3MF files |
| `Okta Verify` | MAS | Add to `profiles/Brewfile.work` |
| `uBlock Origin Lite` | MAS | Useful Safari adblocker |
| `Hush` | MAS | Safari cookie notice blocker |
| `Actions For Obsidian` | MAS | If keeping Obsidian in the list |
| `superwhisper` | cask | You currently use it; worth keeping in personal profile |
| `brave-browser` | cask | You have it; add to personal profile if preferred |
| `home-assistant` | cask | You have it; add if Home Assistant is part of your setup |
| `gcloud-cli` | cask | You have it; add to homelab profile |

### Token corrections already applied (no action needed)
- `flux-app` → `flux` ✅
- `handbrake-app` → `handbrake` ✅
- `mullvad-vpn` → `mullvadvpn` ✅
- `wireshark-app` → `wireshark` ✅
- `openscad@snapshot` → `openscad` ✅
- `dockutil` cask → formula ✅
- `ollama` formula → cask ✅
- `tailscale-app` cask → MAS ✅
