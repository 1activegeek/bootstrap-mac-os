#!/bin/sh

# This is a bootstrap script to get a macOS machine ready to sync with Ansible
#  Installs:
#    - homebrew (which install Xcode Command Line Tools)
#    - ansible (via brew) 
#    - kicks off ansible playbook to configure the sync

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

fancy_echo "Boostrapping ..."

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"# </dev/null # Removing this as it caused an error
  # Add Brew to PATH
	fancy_echo "Adding Homebrew 'brew' to your PATH"
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/"$(whoami)"/.zprofile
	eval "$(/opt/homebrew/bin/brew shellenv)"
	# Disable Gatekeeper checks on Brew apps
	export HOMEBREW_CASK_OPTS="--no-quarantine"
else
  fancy_echo "Homebrew already installed. Skipping."
fi

# [Install Ansible](http://docs.ansible.com/intro_installation.html).
if ! command -v ansible >/dev/null; then
  fancy_echo "Installing Ansible ..."
  brew install ansible 
else
  fancy_echo "Ansible already installed. Skipping."
fi

# # Clone the repository to your local drive.
# if [ -d "./laptop" ]; then
#   fancy_echo "Laptop repo dir exists. Removing ..."
#   rm -rf ./laptop/
# fi
# fancy_echo "Cloning laptop repo ..."
# git clone https://github.com/siyelo/laptop.git 

# fancy_echo "Changing to laptop repo dir ..."
# cd laptop

# Run this from the same directory as this README file. 
fancy_echo "Running ansible playbook ..."
ansible-pull -K -U https://git.thegeekybits.com/shawnmix/bootstrap-mac-os.git
# ansible-playbook -K local.yml