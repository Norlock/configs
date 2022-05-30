print("Installing dev environment")

function Execute(question, cmd)
    while true do
        print(question)

        local input = string.lower(io.read())
        if input == "y" or input == "" then
            cmd()
            break
        elseif input == "n" then
            break
        else
            print("unknown input")
        end
    end
end

local question1 = "1. Install packages? [Y/n]"
local cmd1 = function ()
    os.execute("sudo pacman -S --needed neovim fd htop fzf sway fish kitty waybar mako ripgrep yay git");
end

local question2 = "2. Install yay? [Y/n]"
local cmd2 = function ()
    os.execute("sudo pacman -S --needed git base-devel")
    os.execute("cd ~/bin && git clone https://aur.archlinux.org/yay.git")
    os.execute("cd ~/bin/yay && makepkg -si")
end

Execute(question1, cmd1)
Execute(question2, cmd2)
