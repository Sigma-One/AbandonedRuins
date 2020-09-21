local base_util = require("__core__/lualib/util")

local util = {}
util.SMALL_RUIN_HALF_SIZE = 8 / 2
util.MEDIUM_RUIN_HALF_SIZE = 16 / 2
util.LARGE_RUIN_HALF_SIZE = 32 / 2
util.debugprint = __DebugAdapter and __DebugAdapter.print or function() end

util.get_center_of_chunk = function(chunk_position)
  return {x = chunk_position.x * 32 + 16, y = chunk_position.y * 32 + 16}
end

util.area_from_center_and_half_size = function(half_size, center)
  return {{center.x - half_size, center.y - half_size}, {center.x + half_size, center.y + half_size}}
end

-- haystack is a string, needles is a table with key/values pairs of string = true. The value is ignored.
util.str_contains_any_from_table = function(haystack, needles)
  for needle in pairs(needles) do
    if haystack:find(needle, 1, true) then -- plain find, no pattern
      return true
    end
  end
  return false
end

-- extend table 1 with table 2
-- no safety checks, very naive
util.extend = function(table1, table2)
  for k,v in pairs(table2) do
    table1[k] = v
  end
end

util.safe_insert = base_util.insert_safe -- (entity, item_dict: {name = count})

util.safe_damage = function(entity, damage)
  if not entity then return end
  entity.damage(damage.dmg, damage.force or "neutral", damage.type or "physical")
end

util.set_enemy_force_cease_fire = function(enemy, cease_fire)
  for _, force in pairs(game.forces) do
    if force ~= enemy then
      force.set_cease_fire(enemy, cease_fire)
      enemy.set_cease_fire(force, cease_fire)
    end
  end
end

local function setup_enemy_force()
  local enemy = game.forces["AbandonedRuins:enemy"] or game.create_force("AbandonedRuins:enemy")

  for _, force in pairs(game.forces) do
    if force.ai_controllable then
      force.set_friend(enemy, true)
      enemy.set_friend(force, true)
    end
  end
  util.set_enemy_force_cease_fire(enemy, false)

  global.enemy_force = enemy
  return enemy
end

util.get_enemy_force = function()
  if (global.enemy_force and global.enemy_force.valid) then
    return global.enemy_force
  end
  return setup_enemy_force()
end

return util
