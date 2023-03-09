# bootstrap-mac-os

# New Mac bootstrap repo
This repo is intended to be used to bootstrap a brand new macOS installation. Unfortunately it will still require some manual steps which we'll outline below to handle first. Once these steps are done the rest of the process should be automatic. 
## Steps to get started:
- [ ] Boot your macOS device, and complete the welcome wizard screens, including creating your User account and linking your AppleID
- [ ] Sign into your user, and open the App Store app and validate that you are successfully signed in to your account. If not, sign in now so that Mas apps can be installed properly
- [ ] Setup/Signin to your syncing app of choice which may host your configs. I use iCloud, and so need to be sure my AppleID is signed in, and that my documents have successfully downloaded on the device before running this script. Alternatively if your app of choice allows optimizing or syncinc specific files first - invoke this method to make this process quicker so that your dependent files will be available. 
- [ ] Optional (but Recommended) - Fork this repository and customize the config.yml file so that you can customize it to your specific needs. Additionally, if you would like to set different OSX Defaults, see the directions below on how to quickly identify some of these configs
- [ ] Run the following bootstrap command - **this will pull down a copy and run the script on your device**  
`/bin/bash -c "$(curl -fsSL https://git.thegeekybits.com/shawnmix/bootstrap-mac-os/raw/branch/master/bootstrap.sh)"`






<!--

## Mackup handle?
- Set appcleaner to automatic mode

#### Set hostname at command line
sudo scutil --set HostName daedalus
involve a prompt to ask for a hostname to set

#### Low level stuff - likely copy across
- move over .ssh configs
- setup git identity

#### Finder defaults
  - sidebar: dekstop, documents, downloads, home, icloud drive, machine, hard disks, external disks, bojour, connected servers
  - view options - always open in list, browse in list, use as defaults
 - Enable iMessages in cloud / keep convo after close
 - Start new conversations from shawnmix@gmail.com - iMessage / Facetime
 - safari
  - open last tabs
  - dont open safe files after downloading
  - show website icon in tabs
 - show volume in menu bar
 - Set app bar to correct order
 - Keep folders on top - in windows when sorting by name / desktop
 - Dont write ds_store files on network shares 'defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true'
 - Mail Prefs
   - most recent at top
   - load remote content false
   - setup signature
- Network
   - Setup new location (bypass / tunnel)
   - configure DNS appropriately for locations
   - turn on network sharing
   - turn on screen sharing
   - turn on file sharing

#### Extras that need manual intervention, or find way to script:

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


#### Use this for launch on login apps
defaults write com.knollsoft.Rectangle launchOnLogin -bool true

#### To find new defaults, 'defaults read > a, make change, defaults read > b, diff a b'
alias - da, db, ddif - create file a, file b, then dif
-->