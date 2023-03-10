#!/bin/sh

# This is a bootstrap script to get a macOS machine ready to sync with Ansible
#  Installs:
#    - homebrew (which install Xcode Command Line Tools)
#    - ansible (via brew) 
#    - kicks off ansible playbook to configure the sync

echo "Boostrapping ..."

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

if ! command -v brew >/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # </dev/null # Removing this as it caused an error
  # Add Brew to PATH
	echo "Adding Homebrew 'brew' to your PATH"
  eval "$(/opt/homebrew/bin/brew shellenv)"
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/"$(whoami)"/.zprofile
	# Disable Gatekeeper checks on Brew apps
	export HOMEBREW_CASK_OPTS="--no-quarantine"
else
  echo "Homebrew already installed. Skipping."
fi

# [Install Ansible](http://docs.ansible.com/intro_installation.html).
if ! command -v ansible >/dev/null; then
  echo "Installing Ansible ..."
  brew install ansible 
else
  echo "Ansible already installed. Skipping."
fi

# Clone the repository to your home folder 
echo "Checking for bootstrap dir ..."
if [ -d ~/.bootstrap ]; then
  echo "Bootstrap repo dir exists. Removing ..."
  rm -rf ~/.bootstrap/
fi
echo "Cloning bootstrap repo ..."
git clone https://git.thegeekybits.com/shawnmix/bootstrap-mac-os.git ~/.bootstrap

echo "Changing to bootstrap repo dir ..."
cd ~/.bootstrap

# Run this from the same directory as this README file. 
echo "Running ansible playbook ..."
# ansible-pull -U https://git.thegeekybits.com/shawnmix/bootstrap-mac-os.git
ansible-playbook local.yml