export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.bun/bin:$PATH"

ZSH_THEME=""

plugins=(git docker python)

source $ZSH/oh-my-zsh.sh

alias ohmyzsh="nvim ~/.oh-my-zsh"
alias zconfig="nvim ~/.zshrc"

export EDITOR='nvim'
export VISUAL='nvim'

eval "$(starship init zsh)"


alias tmux="tmux new-session -A -s main"
