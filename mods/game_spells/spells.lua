Spells = {}

spellWindow = nil
selectedSpell = nil
spells = {}
local spellButton = nil
local spellWindow = nil

function init()
  connect(g_game, { onOpenSpellWindow = Spells.create,
                    onGameEnd = Spells.destroy })
  spellButton = modules.client_topmenu.addRightToggleButton('spellButton', tr('game_spells module'), '/game_spells/img_game_spells/spells_icon', toggle)
  spellButton:setOn(false)

  spellWindow = g_ui.displayUI('spells')
  spellWindow:setVisible(false)
end

function terminate()
  disconnect(g_game, { onOpenSpellWindow = Spells.create,
                       onGameEnd = Spells.destroy })
  Spells.destroy()
  
  Spells = nil
end

function Spells.create(spellList)
  spells = spellList
  Spells.destroy()

  spellWindow = g_ui.displayUI('spells.otui')
end

function Spells.destroy()
  if spellWindow then
    spellWindow:destroy()
    spellWindow = nil
    selectedSpell = nil
    spells = {}
  end
end

function Spells.selectSpell()
  if table.empty(spells) then
    return
  end
  -- TODO
end




function toggle()
  if spellWindow:isOn() then
    spellWindow:setOn(false)
    spellWindow:setVisible(false)
    spellButton:setOn(false)
  else
    spellWindow:setOn(true)
    spellWindow:setVisible(true)
    spellButton:setOn(true)
  end
end