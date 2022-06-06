print("Installing dev environment")
local handle = io.popen("echo $EUID")
local userId = handle:read("n")
handle:close()

if userId ~= 0 then
    print "you need to be root to run this script, exiting."
    os.exit()
end

local tasks = {}
local answers = " [Y]es [n]o [a]bort"

function AddTask(question, command)
    tasks[#tasks+1] = { question = question , command = command }
end

function PrintTasks()
    for i, task in ipairs(tasks) do
        print(i .. ". " .. task.question)
    end
end

function HandleMultipleTasks (input, inputAsNumber)
    local hasMultiple = string.find(input, ",")
    local hasRange = string.find(input, "..")

    if not hasMultiple and not hasRange then
        print("Invalid input")
        return
    elseif hasMultiple then
        local questions = {}
        for item in string.gmatch(input, "([^,]+)") do
            inputAsNumber = tonumber(item, 10)
            if inputAsNumber == nil then
                if not string.find(item, "..") then
                    print("Unknown characters")
                    break
                else
                    local fromTil = string.gmatch(input, "([^,]+)")
                    -- implement range
                end
            else
                questions[#questions+1] = inputAsNumber
            end
        end
    end
end

function HandleSingleTask (inputAsNumber)
    print("\n")
    local task = tasks[inputAsNumber]
    Execute(task, inputAsNumber)
    os.exit()
end

function TasksToExecute()

    while true do
        print "\nPlease enter the tasks you want to execute:"
        print "1 -> Runs task 1"
        print "1, 2 -> Runs tasks 1 and 2"
        print "1..4 -> Runs tasks 1, 2, 3, 4"
        print "3.. -> Runs tasks starting from 3"
        local input = string.lower(io.read())

        if input == "" then
            print("\n")
            for index, task in ipairs(tasks) do
                Execute(task, index)
            end
            os.exit()
        end

        local inputAsNumber = tonumber(input, 10)

        if inputAsNumber == nil then
            HandleMultipleTasks(input, inputAsNumber)
        else
            HandleSingleTask(inputAsNumber)
        end
    end
end

function Execute(task, index)
    while true do
        print(index .. ". " .. task.question .. answers)

        local input = string.lower(io.read())
        if input == "y" or input == "" then
            if task.command() then
              break
            else
              os.exit()
            end
        elseif input == "n" then
            break
        elseif input == "a" then
            os.exit()
        else
            print("unknown input")
        end
    end
end

-- As root
local addUserQ = "Add user?"
local addUserC = function ()
  print("Enter your username")

  local username = string.lower(io.read())
  local match = string.match(username, "[a-zA-Z]+")

  if match ~= username then
    print("Username can only contain letters")
    return
  end

  -- TODO hide password in future
  print("Enter your password")
  local password = io.read();
  local hasSpaces = string.find(password, " ")
  if hasSpaces ~= nil then
    print("Password may not contain spaces")
    return
  end

  os.execute("useradd -G wheel,audio,video -m " .. username .. " -p " .. password)
end


local installPackagesQ = "Install packages?"
local installPackagesC = function ()
    os.execute("pacman -S --needed neovim fd htop fzf sway fish kitty waybar mako ripgrep yay git");
end

AddTask(addUserQ, addUserC)
AddTask(installPackagesQ, installPackagesC)


-- Run tasks
PrintTasks()
TasksToExecute()

--Execute(addUserQ, AddUserC)
--Execute(installPackagesQ, installPackagesC)

---- As user
--print("Login as user for the rest of the script")
--print("Enter username: ")
--local username = string.lower(io.read())
---- Create user script with lua and try to run
--os.execute('su -c "lua test.lua" - ' .. username)

--local installYayQ = "Install yay?"
--local installYayA = function ()
    --os.execute("sudo pacman -S --needed git base-devel")
    --os.execute("cd ~/bin && git clone https://aur.archlinux.org/yay.git")
    --os.execute("cd ~/bin/yay && makepkg -si")
--end

--Execute(installYayQ, installYayA)


