print("Installing dev environment")

local currentQuestion = 1;

function Execute(question, cmd)
    while true do
        print(currentQuestion .. ". " .. question)
        currentQuestion = currentQuestion + 1

        local input = string.lower(io.read())
        if input == "y" or input == "" then
            if cmd() then
              break
            else
              os.exit()
            end
        elseif input == "n" then
            break
        else
            print("unknown input")
        end
    end
end

local addUserQ = "Add user? [Y/n]"
local AddUserC = function ()
  print("Enter your username")

  local username = string.lower(io.read())
  local match = string.match(username, "[a-zA-Z]+")

  if match ~= username then
    print("Username can only contain letters")
    return
  end

  print("Enter your password")
  local password = io.read();
  local hasSpaces = string.find(password, " ")
  if hasSpaces ~= nil then
    print("Password may not contain spaces")
    return
  end

  os.execute("useradd -G wheel,audio,video -m " .. username .. " -p " .. password)
end


local installPackagesQ = "Install packages? [Y/n]"
local installPackagesC = function ()
    os.execute("sudo pacman -S --needed neovim fd htop fzf sway fish kitty waybar mako ripgrep yay git");
end

local question2 = "Install yay? [Y/n]"
local cmd2 = function ()
    os.execute("sudo pacman -S --needed git base-devel")
    os.execute("cd ~/bin && git clone https://aur.archlinux.org/yay.git")
    os.execute("cd ~/bin/yay && makepkg -si")
end

Execute(addUserQ, AddUserC)
Execute(installPackagesQ, installPackagesC)
Execute(question2, cmd2)
