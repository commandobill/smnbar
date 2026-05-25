local util = require 'util';
local mgr = AshitaCore:GetResourceManager();
local numerals = { '', ' ii', ' iii', ' iv', ' v', 'vi' };

local function do_summon(thing)
  local target = '<me>';
  if (thing:lower() == 'atomos') then
    target = '<t>'
  end
  AshitaCore:GetChatManager():QueueCommand(-1, '/ma "' .. thing .. '" ' .. target);
end

local function summon(thing)
  local petEnt = util:PetEntity();
  if (petEnt ~= nil) then -- already has a pet, release first.
    if (petEnt.Name:lower() ~= thing:lower()) then
      AshitaCore:GetChatManager():QueueCommand(-1, '/pet release <me>');
      ashita.tasks.once(2, function()
        do_summon(thing);
      end);
    end
  else
    do_summon(thing);
  end;
end

local actions = {};

function actions:Get(thing)
  return function()
    summon(thing);
  end;
end

function actions:GetPetAction(action, ranks, target)
  if (action == nil) then print(ranks); return nil end
  local player = AshitaCore:GetMemoryManager():GetPlayer();
  local rank = 1;

  for rank = ranks, 1, -1 do
    local ability = mgr:GetAbilityByName(action .. numerals[rank], 2);
    if (ability ~= nil and player:HasAbility(ability.Id)) then
      return function()
        AshitaCore:GetChatManager():QueueCommand(-1, '/pet "' .. action .. numerals[rank] .. '" ' .. target);
      end, ability;
    end
  end
end

function actions:GetJaAction(command, target)
  local player = AshitaCore:GetMemoryManager():GetPlayer();
  local ability = mgr:GetAbilityByName(command, 2);
  if (ability ~= nil) then
    return function()
      AshitaCore:GetChatManager():QueueCommand(-1, '/ja "' .. command .. '" ' .. target);
    end, ability;
  end
end

return actions;
