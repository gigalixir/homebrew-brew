#!/usr/bin/env bash


function info() {
  echo -e "\nINFO $@"
}

if which pip3 > /dev/null; then
  thepip=pip3
elif which pip > /dev/null; then
  thepip=pip
fi

if [ -z "$thepip" ]; then
  info "Pip not installed"
else
  info "Found pip installed as: $thepip"

  if $thepip list | grep -q "gigalixir"; then
    info "Gigalixir pip installed"
    info "Uninstalling gigalixir pip"
    $thepip uninstall -y gigalixir
  else
    info "Gigalixir pip not installed"
  fi
fi

if which brew > /dev/null; then
  info "Brew installed!"
else
  info "Brew not installed"
  info "Installing brew"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  if [ "$?" -eq "0" ]; then
    info "Brew installed!"
  else
    info "Brew failed to install"
    exit 1
  fi
fi

if brew list | grep -q gigalixir; then
  info "Gigalixir brew already installed"
  info "Uninstalling gigalixir brew"
  if brew uninstall -f gigalixir; then
    info "Gigalixir brew uninstalled"
  else
    info "Gigalixir brew failed to uninstall"
    exit 1
  fi
fi

if which gigalixir > /dev/null; then
  info "Gigalixir is still in the path"
  which gigalixir
  exit 1
else
  info "Gigalixir is not in the path"
fi

info "Adding new tap"

if brew tap gigatim/cli; then
  info "Tap added"
else
  info "Tap failed to add"
  exit 1
fi

info "Updating brew"
brew update

info "Installing gigalixir brew"
if brew install gigatim/cli/gigalixir; then
  info "Gigalixir brew installed"
else
  info "Gigalixir brew failed to install"
  exit 1
fi

if which gigalixir > /dev/null; then
  info "Gigalixir is in the path"
  which gigalixir
else
  info "Gigalixir is not in the path"
  exit 1
fi

gigalixir --help

gigalixir version

info "Testing completed!"
