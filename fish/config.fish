set -gx npm_config_prefix ~/.nodemodules
set -gx MOZ_ENABLE_WAYLAND 1
set -g fish_prompt_pwd_dir_length 0

set -gx EDITOR nvim
set -gx BROWSER brave-browser
set -gx DENO_INSTALL /home/norlock/.deno

set -gx GEM_HOME ~/.ruby 
set -x PATH $PATH ~/.cargo/bin
set -x PATH $PATH ~/.local/bin
set -x PATH $PATH /usr/sbin
set -x PATH $PATH ~/.nodemodules/bin
set -x PATH $PATH $DENO_INSTALL/bin

# Setting fd as the default source for fzf
set -gx FZF_DEFAULT_COMMAND "fd --type f"

# To apply the command to CTRL-T as well
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

alias fishConfig="nvim ~/.config/fish/config.fish"
alias fishReload="source ~/.config/fish/config.fish"

# Because I'm lazy
alias r="ranger"
alias n="nvim"
alias nvimConfig="nvim ~/.config/nvim/init.vim"
alias swayConfig="nvim ~/.config/sway/config"
alias alacrittyConfig="nvim ~/.config/alacritty/alacritty.yml"
alias kittyConfig="nvim ~/.config/kitty/kitty.conf"
alias ...="cd ../.."
alias ....="cd ../../.."

# Git aliases
alias g="git"
alias gst="git status"
alias gaa="git add -A"
alias gac="git add -A; and git commit"
alias gc="git commit"
alias gcm="git commit -m"
alias gco="git checkout"
alias gl="git log"
alias glo="git log --oneline"
alias gb="git branch"
alias gba="git branch -a"
alias gbr="git branch -r"
alias gd='git diff'
alias grhh='git reset HEAD --hard'
