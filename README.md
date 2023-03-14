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
- Finder
  - Configure sidebar of Finder (favorites, network, etc) dekstop, documents, downloads, home, icloud drive, machine, hard disks, external disks, bojour, connected servers
  - view options - always open in list, browse in list, use as defaults
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
- Messages
  - Enable iMessages in cloud / keep convo after close
  - Start new conversations from shawnmix@gmail.com - iMessage / Facetime
- Set appcleaner to automatic mode - handled by mackup?
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

#### To find new defaults, 'defaults read > a, make change, defaults read > b, diff a b'
alias - da, db, ddif - create file a, file b, then dif
#### Use this for launch on login apps
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
