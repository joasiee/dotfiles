export ZSH="/home/joasiee/.oh-my-zsh"
export PATH="/home/joasiee/.local/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export ZSHZ_UNCOMMON=1

ZSH_THEME="arrow"

plugins=(git zsh-z zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(pyenv init --path)"
