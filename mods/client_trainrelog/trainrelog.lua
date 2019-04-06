local trainrelogButton = nil
local trainrelogWindow = nil
local credentials = {}
local credentialsIndex = 0
local enterCredentials = false
local nextCharacter = false
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
local commentString = "-"

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
    credentialsIndex = 0
  else
    isOn = true
    trainrelogButton:setOn(true)

    if credentialsIndex==0 then
      credentialsIndex = 1
      enterCredentials = true
      readCredentials()    
      scheduleEvent(trainrelogWithCredentials, 1000)
    end
  end
end


function readCredentials()
  filecontents = g_resources.readFileContents(trainrelogDirName..trainrelogCredentialsFileName)
  delim = "\n"
  for singleCredentials in string.gmatch(filecontents, "[^".. delim.. "]*") do
    if string.find(singleCredentials, commentString, 1) == nil then
      delimPosition =  string.find(singleCredentials, " ")
      if delimPosition~=nil and delimPosition>0 then
        accountName = string.sub(singleCredentials, 1, delimPosition-1)
        password = string.sub(singleCredentials, delimPosition+2. -1)
        print("*"..accountName.."*"..password.."*")

        table.insert(credentials, {accountName=accountName, password=password})
      end
    else
      print("skipping "..singleCredentials)
    end
  end
end

function trainrelogWithCredentials()
  if not isOn then
    return
  elseif not g_game.isOnline() and not g_game.isLogging() then
    print("traintelog loop, offline")

    if nextCharacter then
      nextCharacter = false
      credentialsIndex = credentialsIndex + 1
      print("going next character")
    end

    if credentialsIndex > #credentials then
      toggle()
      print("all characters relog done!")
      return
    end

    if enterCredentials then
      accountName = credentials[credentialsIndex].accountName
      password = credentials[credentialsIndex].password
      print(accountName, password)

      accountName = g_crypt.encrypt(accountName)
      password = g_crypt.encrypt(password)

      EnterGame.setAccountName(accountName)
      EnterGame.setPassword(password)
      print("pass set")
      EnterGame.doLogin()
      print("EnterGame.doLogin() done")
      enterCredentials = false
      scheduleEvent(trainrelogWithCredentials, 2000)
    else
      CharacterList.doLogin()
      print("CharacterList.doLogin() done")
      enterCredentials = true
      scheduleEvent(trainrelogWithCredentials, 1000)
    end
  else
    print("traintelog loop, online")

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

    nextCharacter = true
    scheduleEvent(trainrelogWithCredentials, 1000)


  end
end