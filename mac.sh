#!/usr/bin/env bash

set -e

# This is a simple basic starter setup for a mac dev machine.

DOTFILES_REPO="https://github.com/habu-kagumba/dotfiles"
DOTFILES_DEST="$HOME/dotfiles"

# Pretty utils
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
POWDER_BLUE=$(tput setaf 153)
NORMAL=$(tput sgr0)

print_out() {
  printf "\n\n${POWDER_BLUE}----------------------------------------${NORMAL}"
  printf "\n\t ${POWDER_BLUE}$1${NORMAL}\n"
  printf "${POWDER_BLUE}----------------------------------------${NORMAL}\n\n"
}

homebrew_setup() {
  if ! command -v brew > /dev/null; then
    print_out "Homebrew installing"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  print_out "Homebrew updating"
  brew update
}

dotfiles_setup() {
  print_out "Setup dotfiles"

  # Install git
  if ! brew list | grep git > /dev/null; then
    printf "\n${CYAN}Installing git${NORMAL}"

    if brew install git > /dev/null; then
      printf " ${GREEN}✔︎${NORMAL}\n"
    fi
  fi

  # Install GNU stow
  if ! brew list | grep stow > /dev/null; then
    printf "\n${CYAN}Installing stow${NORMAL}"

    if brew install stow > /dev/null; then
      printf " ${GREEN}✔︎${NORMAL}\n"
    fi
  fi

  # clone dotfiles
  if ! [ -d "$DOTFILES_DEST" ]; then
    printf "\n${CYAN}Cloning dotfiles${NORMAL}"

    if git clone -q $DOTFILES_REPO $HOME/dotfiles; then
      printf " ${GREEN}✔︎${NORMAL}\n"
    fi
  fi

  cd $DOTFILES_DEST

  declare -a farms=("homebrew" "ag" "bash" "excuberant_tags" "git" "neovim" "rubygems" "scripts" "tmux" "zsh")

  for i in "${farms[@]}"
  do
    stow "$i"
  done
}

set_shell() {
  # set zsh as the default shell
  chsh -s "$(which zsh)"

  # setup oh-my-zsh
  printf "\n${CYAN}Installing oh-my-zsh${NORMAL}\n"
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"; then
    printf " ${GREEN}✔︎${NORMAL}\n"
  fi
}

setup_languages() {
  # --------------------------------------
  # ASDF
  # --------------------------------------
  print_out "Setting up ASDF"

  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.4.1

  # --------------------------------------
  # Node
  # --------------------------------------
  print_out "Setting up Node"

  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

  # --------------------------------------
  # Ruby
  # --------------------------------------
  print_out "Setting up ruby"

  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git

  # --------------------------------------
  # Python
  # --------------------------------------
  print_out "Setting up python"

  asdf plugin-add python https://github.com/tuvistavie/asdf-python.git

  # --------------------------------------
  # Go
  # --------------------------------------
  print_out "Setting up Go"

  asdf plugin-add golang https://github.com/kennyp/asdf-golang.git

  # --------------------------------------
  # Rust
  # --------------------------------------
  print_out "Setting up Rust"

  asdf plugin-add rust https://github.com/code-lever/asdf-rust.git
}

setup_neovim() {
  print_out "Setting up Neovim"

  pyenv virtualenv 2.7.13 neovim2

  pyenv activate neovim2
  pip install websocket-client sexpdata neovim
  source deactivate

  pip install neovim flake8

  gem install neovim
}

homebrew_setup
dotfiles_setup

cd $HOME

print_out "Installing packages"

# Install all packages from brew.
brew bundle

# Uncomment this if you haven't setup zsh or oh-my-zsh yet.
# set_shell

# Setup Node, Ruby, Python, Scala and Go
# setup_languages

# Setup Neovim
# setup_neovim

cd -
