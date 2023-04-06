# bootstrap-mac-os

# New Mac bootstrap repo
This repo is intended to be used to bootstrap a brand new macOS installation. Unfortunately it will still require some manual steps which we'll outline below to handle first. Once these steps are done the rest of the process should be automatic. 
## Steps to get started:
1. Boot your macOS device, and complete the welcome wizard screens, including creating your User account and linking your AppleID
2. Sign into your user, and open the App Store app and validate that you are successfully signed in to your account. If not, sign in now so that Mas apps can be installed properly
3. Setup/Signin to your syncing app of choice which may host your configs. I use iCloud, and so need to be sure my AppleID is signed in, and that my documents have successfully downloaded on the device before running this script. Alternatively if your app of choice allows optimizing or syncinc specific files first - invoke this method to make this process quicker so that your dependent files will be available. 
4. Optional (but Recommended) - Fork this repository and customize the config.yml file so that you can customize it to your specific needs. Additionally, if you would like to set different OSX Defaults, see the directions below on how to quickly identify some of these configs
5. Run the following bootstrap command - **this will pull down a copy and run the script on your device**  
`/bin/bash -c "$(curl -fsSL https://git.thegeekybits.com/shawnmix/bootstrap-mac-os/raw/branch/master/bootstrap.sh)"`
6. Password prompt will appear to install XCode Command Line tools
7. Once this completes and Homebrew completes installation, the Ansible playbook will kickoff
8. You will need to enter your root password 3 times - once for sudo permissions to be enabled, and 2 extra times to provide the Sudo permissions for later iterations in the playbook
9. One of the first playbooks to run will be the Homebrew playbook - it's not unusual for the first run of this to take quite some time for the Homebrew update command to complete


## TODO:
- Move hostname and sudo permission prompts to an include only if running the selected playbooks that need it
- Fix ansible and brew commands not recognized after bootstrap
- Configure hostname at CLI - 'sudo scutil --set HostName daedalus'
- Accounts
  - Must add accounts from other devices now
- General
  - Language & Region
    - First Day of week - Monday
- Calendar
  - Settings
    - Advanced
      - Turn on Time Zone Support
      - show week numbers
  - View
    - Show declined events
- Finder
  - Set list view default for folders
  - Configure sidebar of Finder (favorites, network, etc) dekstop, documents, downloads, home, icloud drive, machine, hard disks, external disks, bojour, connected servers
  - view options - always open in list, browse in list, use as defaults
  - Favorites
    - AirDrop
    - Recents
    - shawnmix (homedir)
    - Downloads
  - iCloud
    - iCloud Drive
    - Downloads
    - Documents
    - Docs - Traceable
    - 3DPrint
    - House Documents
    - 15 Murray St
    - Shared
    - Desktop
- Safari
  - open last tabs
  - dont open safe files after downloading
  - show website icon in tabs
- Network
  - Setup new location (bypass / tunnel)
  - configure DNS appropriately for locations
  - turn on network sharing
  - turn on screen sharing
  - turn on file sharing
  - Dont write ds_store files on network shares 'defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true'
- Mail Prefs
  - most recent at top
  - load remote content false
  - setup signature
  - Favorites:
    - All Inboxes
    - Smart Mailbox - Inbox only, no work (may get rid of)
    - Flagged
    - Send Later
    - Meeting Invites
    - Account Work
    - Team East
    - Team SA
    - Sales
    - Product
    - All Sent
  - Settings
    - Viewing
      - Marks all messages as read when opening
      - Show most recent messages at the top
    - Composing
      - Mark messages not ending with (@traceable.ai)
      - Undo send delay - 20 secs
    - Signatures
      - Set to each account
      - Choose default signatures for each account
- Messages
  - Enable iMessages in cloud / keep convo after close
  - Start new conversations from shawnmix@gmail.com - iMessage / Facetime
- Set appcleaner to automatic mode - need appcleaner preference backup to work properly, not working currently
- Move over .ssh configs - whats covered in mackup?
- Launch apps after completion (for syncing purposes)
  - Contacts
  - Mail
  - Calendar
  - Reminders
  - Messages
  - Safari
  - Notes
  - Obsidian
  - 1Password
  - Moom
  - Raycast
  - Shortcuts
  - Discord
  - BlockBlock
- Settings
  - Hide block block from menu bar
  - launch auth and config
   - amphetamine
   - docker
   - music - authorize computer for Music 
  - turn off iCloud calendar
  - turn off iCloud mail
  - turn on firewall
  - turn on unlock with apple watch
  - add in gmail account for contacts/cal/mail
  - open up mail, calendar, contacts for sync to happen
  - discord login / launch at startup
  - enable 3rd party apps in 1Password
  - enable 1Password in raycast
  - enable nightshift for display
  - Wireguard profiles
- Siri & Spotlight
  - allow Hey Siri
- Keyboard
  - Keyboard Navigation - allow navigate with keyboard using tab and shift+tab
  - Keyboard shortcuts - Spotlight - Option + Space
- Trackpad
  - Point and click
    - tap to click 
    - tracking speed one notch below fast
  - More Gestures
    - App Expose - swipe down with three fingers
  - get setup for trackpad or touchpad devices
- Raycast - import settings from iCloud backup
  - option to script? Add to mackup? 
  - fix screenshots folder pointer
  - Script Commands directories not loading
  - Also need to sync .raycast directory
- Visual Studio
  - Enable settings sync
  - overwrite local changes to resolve conflicting settings
- Shottr
  - General
    - Window Screenshot - Trim Shadow
    - Screenshot folder
  - Advanced 
    - Allow diagnostics collection
- BlockBlock - hide icon mode
- LuLu - hide icon mode
- Slack
  - Signin
  - Theme
- JustFocus - autostart on login
- Time Machine
- Notifications - turn off email
- Siri Suggestions
  - Disable Calendar
- Office Installer - find way to script using the cracked installer
- Zoom
  - Set defaults for meeting to map to system audio output/input
  - Setup keyboard shortcuts
  - Setup video wiht blur, touch up, HD, low light, participant names on video at all times
- find a prusaslicer backup mechanism

# Set computer name (as done via System Preferences → Sharing)
COMPUTER_NAME="0x6D746873"
#sudo scutil --set ComputerName "${COMPUTER_NAME}"
#sudo scutil --set HostName "${COMPUTER_NAME}"
#sudo scutil --set LocalHostName "${COMPUTER_NAME}"
#sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"

#### To find new defaults, 'defaults read > a, make change, defaults read > b, diff a b'
alias - da, db, ddif - create file a, file b, then dif
#### Use this for launch on login apps
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
