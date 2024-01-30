Dice = {}

-- Very haphazardly put together because I couldn't find reference and this feature is simple anyways
function Dice.GetCharacterPerception(character)
  local charEntity = Ext.Entity.Get(character)
  return charEntity.Stats.Skills[17]
end

function Dice.RollPerception(character, DC)
  local perception = Dice.GetCharacterPerception(character)

  local roll = math.random(1, 20)
  Utils.DebugPrint(3, "Roll: " .. roll .. " Perception: " .. perception .. " DC: " .. DC)
  if roll == 20 then
    return true
  elseif roll == 1 then
    return false
  else
    return perception + roll >= DC
  end
end

return Dice
