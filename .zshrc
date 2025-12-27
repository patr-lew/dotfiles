
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="refined" # set by `omz`
HYPHEN_INSENSITIVE="true"

plugins=(git colorize colored-man-pages 1password command-not-found emoji-clock aliases npm qrcode)

source $ZSH/oh-my-zsh.sh

# Disable terminal title setting in tmux to let tmux handle window naming
if [[ -n "$TMUX" ]]; then
  DISABLE_AUTO_TITLE="true"
fi

# User configuration

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

# Lazy-load NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && . "/opt/homebrew/opt/nvm/nvm.sh"

# Add this to your ~/.zshrc
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# update the git-managed Brewfile
brew() {
  command brew "$@"
  if [[ "$1" == "install" || "$1" == "uninstall" || "$1" == "upgrade" ]]; then
    echo "Updating Brewfile..."
    brew bundle dump --file="$HOME/.config/homebrew/Brewfile" --force --describe
  fi
}

npm() {
  if [[ "$1" = "install" || "$1" = "i" || "$1" = "ci" || "$1" = "outdated" || "$1" == "view" ]]; then
    if [[ "$*" == *"-g"* ]]; then
      command npm "$@"
      echo "Updating global npm packages list..."
      npm ls -g --depth=0 --parseable=true | grep -v node_modules/npm | awk -F/ '{print $NF}' > "$HOME/.config/Npmfile"
    else
      command op run -- npm "$@"
    fi
  else
    command npm "$@"
  fi
}

pnpm() {
  command op run -- pnpm "$@"
}

## Aliases
# alias for 'op run --env-file=some-file'
# usage: openv some-file -- further-commands
function openv() {
  op run --env-file="$1" -- "${@:3}"
}

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# local and private env variables:
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# k9s
export K9S_CONFIG_DIR="$HOME/.config/k9s"

export PATH="/opt/homebrew/opt/bc/bin:$PATH"
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

export PATH="$PATH:/$HOME/.local/bin"

export GOBIN=$HOME/go/bin
export PATH="$GOBIN:$PATH"

export GOPATH="$HOME/go"
export PATH=$PATH:$(go env GOPATH)/bin

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# Accept autosuggestions with Ctrl-Y.
bindkey '^Y' autosuggest-accept
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
