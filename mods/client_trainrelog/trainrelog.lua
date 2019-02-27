local trainrelogButton = nil
local trainrelogWindow = nil
local credentials = {}
local credentialsIndex = nil
local trainers = {
  sword=16198,
  axe=16199,
  club=16200,
  dist=16201
}

local isOn = false

local trainrelogDirName = "/trainrelog"
local trainrelogDir = g_resources.getWriteDir()..trainrelogDirName
local trainrelogCredentialsFileName = "/trainrelogcredentials.txt"
local trainrelogCredentialsFile = trainrelogDir..trainrelogCredentialsFileName

function init()
  trainrelogButton = modules.client_topmenu.addRightToggleButton('trainrelogButton', tr('client_trainrelog module'), '/client_trainrelog/img_client_trainrelog/trainrelog_icon', toggle)
  trainrelogButton:setOn(false)

  trainrelogWindow = g_ui.displayUI('trainrelog.otui')
  trainrelogWindow:setVisible(false)

  if not g_resources.directoryExists(trainrelogDir) then
    g_resources.makeDir(trainrelogDirName)
  end
end

function terminate()
  trainrelogWindow:destroy()
  trainrelogWindow = nil
  trainrelogButton:destroy()
  trainrelogButton = nil
end



function toggle()
  if isOn then
    isOn = false
    trainrelogButton:setOn(false)
  else
    isOn = true
    trainrelogButton:setOn(true)

    readCredentials()


    cycleEvent(trainrelogWithCredentials, 3000)
  end
end


function readCredentials()
  filecontents = g_resources.readFileContents(trainrelogDirName..trainrelogCredentialsFileName)
  delim = "\n"
  for singleCredentials in string.gmatch(filecontents, "[^".. delim.. "]*") do
    delimPosition =  string.find(singleCredentials, " ")
    if delimPosition~=nil and delimPosition>0 then
      accountName = string.sub(singleCredentials, 1, delimPosition-1)
      password = string.sub(singleCredentials, delimPosition+2. -1)
      print("*"..accountName.."*")
      print("*"..password.."*")

      credentials[accountName] = password
    end

  end
end

function trainrelogWithCredentials()
  if not g_game.isOnline() then
    credentialsIndex, credentialsValue = next(credentials, credentialsIndex) 
    print(credentialsIndex)
    print(credentialsValue)

    account = g_crypt.encrypt(credentialsIndex)
    password = g_crypt.encrypt(credentialsValue)

    os.execute("sleep " .. tonumber(1))

    EnterGame.setAccountName(account)
    EnterGame.setPassword(password)

    os.execute("sleep " .. tonumber(1))

    EnterGame.doLogin()
    CharacterList.doLogin()
  else

    skillChoice = "none"
    skillValue = 0
    itemId = 0

    player = g_game.getLocalPlayer()
    if(player:getSkillLevel(Skill.Sword)>skillValue) then
      skillChoice = "sword"
      skillValue = player:getSkillLevel(Skill.Sword)
      itemId = trainers.sword
    end
    if(player:getSkillLevel(Skill.Axe)>skillValue) then
      skillChoice = "axe"
      skillValue = player:getSkillLevel(Skill.Axe)
      itemId = trainers.axe
    end
    if(player:getSkillLevel(Skill.Club)>skillValue) then
      skillChoice = "club"
      skillValue = player:getSkillLevel(Skill.Club)
      itemId = trainers.club
    end
    if(player:getSkillLevel(Skill.Dist)>skillValue) then
      skillChoice = "dist"
      skillValue = player:getSkillLevel(Skill.Dist)
      itemId = trainers.dist
    end

    print("choice of trainer: "..itemId)
    tiles = player:getTileArray()
    for _, tile in pairs(tiles) do
      for _, thing in pairs(tile:getThings()) do
        if thing:getId() == itemId then
          g_game.use(thing)
        end
      end
    end

  end
end