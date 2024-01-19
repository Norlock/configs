set -gx npm_config_prefix ~/.nodemodules
set -g fish_prompt_pwd_dir_length 0

set -gx MOZ_ENABLE_WAYLAND
set -gx QT_QPA_PLATFORM wayland

set -gx EDITOR nvim
#set -gx BROWSER brave
#set -gx XDG_RUNTIME_DIR ~/.config

set -gx GEM_HOME ~/.ruby 
set -x PATH $PATH ~/.cargo/bin
set -x PATH $PATH ~/.local/bin
set -x PATH $PATH /usr/sbin
set -x PATH $PATH ~/.nodemodules/bin
set -x PATH $PATH ~/.pulumi/bin

# Setting fd as the default source for fzf
set -gx FZF_DEFAULT_COMMAND "fd --type f"

# To apply the command to CTRL-T as well
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

alias fishConfig="nvim ~/.config/fish/config.fish"
alias fishReload="source ~/.config/fish/config.fish"

# Because I'm lazy
alias n="nvim"
alias nvimConfig="nvim ~/.config/nvim/init.lua"
alias swayConfig="nvim ~/.config/sway/config"
alias footConfig="nvim ~/.config/foot/foot.ini"
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

if not pgrep --full ssh-agent | string collect > /dev/null
  eval (ssh-agent -c)
  set -Ux SSH_AGENT_PID $SSH_AGENT_PID
  set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/norlock/bin/google-cloud-sdk/path.fish.inc' ]; . '/home/norlock/bin/google-cloud-sdk/path.fish.inc'; end
