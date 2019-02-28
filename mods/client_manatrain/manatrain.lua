local manaToBurn = 10000
local manaToDrink = 11000
local capacityToTrade = 2000
local capacityToRefill = 1500
local potionId = 237 -- strong mana potion 237 vs 23373

local spellList = {
  {"exevo gran mas frigo", cooldown=30, left=0},
  {"exura vita", cooldown=1, left=0},
  {"utana vid", cooldown=2, left=0},
  {"exevo tera hur", cooldown=4, left=0},
  {"exevo gran frigo hur", cooldown=8, left=0}
}


local manatrainButton = nil
local manatrainWindow = nil

local isOn = false

function init()
  manatrainButton = modules.client_topmenu.addRightToggleButton('manatrainButton', tr('client_manatrain module'), '/client_manatrain/img_client_manatrain/manatrain_icon', toggle)
  manatrainButton:setOn(false)

  manatrainWindow = g_ui.displayUI('manatrain.otui')
  manatrainWindow:setVisible(false)

  cycleEvent(mainLoop, 550)
end

function terminate()
  manatrainWindow:destroy()
  manatrainWindow = nil
  manatrainButton:destroy()
  manatrainButton = nil
end

function toggle()
  if isOn then
    isOn = false
    manatrainButton:setOn(false)
  else
    isOn = true
    manatrainButton:setOn(true)
  end
  print(isOn)
end


function mainLoop()
  if g_game.isOnline() and isOn then
    drink()
    burn()
    buy()

  end
end


function drink()
  player = g_game.getLocalPlayer()

  if player:getMana() < manaToDrink then
    g_game.useInventoryItemWith(potionId, player)
  end
end

function burn()
  player = g_game.getLocalPlayer()

  if player:getMana() > manaToBurn then
    for _, spellTable in pairs(spellList) do
      spell = spellTable[1]
      -- if spellTable.left>0 then
      --   spellTable.left = spellTable.left - 0.2
      -- else
      --   spellTable.left = spellTable.cooldown
      --   g_game.talk(spell)
      -- end
      g_game.talk(spell)
    end
  end
end

function buy()
  if math.random() > 0.2 then return end
  player = g_game.getLocalPlayer()
  -- if player:getMana() >= manaToDrink then return end

  if player:getFreeCapacity() > capacityToTrade then

    g_game.talk("hi")
    tab = modules.game_console.consoleTabBar:getCurrentTab()
    channel = tab.channelId
    g_game.talkChannel(MessageModes.NpcTo, channel, "trade")


    local currentTradeItems = modules.game_npctrade.tradeItems[modules.game_npctrade.getCurrentTradeType()]
    if currentTradeItems==nil then return end
    for key,item in pairs(currentTradeItems) do
      --print(item.ptr:getId())
      if potionId == item.ptr:getId() then
      g_game.buyItem(item.ptr, 100, false, false)
      end
    end

  end

end