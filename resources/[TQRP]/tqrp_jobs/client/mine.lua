----------------------------------
-------------FUNCIONES------------
----------------------------------

X.Click = function(v)
  if v then
    if v.health > 0 then
       if X.Clicks >= Config.ClicksToPickNeeded then 
        exports['mythic_progbar']:Progress({
          name = "housrob",
          duration = 15000,
          label = "A recolher minério",
          useWhileDead = false,
          canCancel = true,
          controlDisables = {},
          animation = {},
          prop = {},
        }, function(status)
          if not status then
            X.Clicks = 0
          v.health = v.health - 5
          TriggerServerEvent('tm1_stores:giveMineral',v.data)
          TriggerServerEvent('tm1_stores:getData',Config.Rocks)
          end
        end)
        else
          X.Clicks = X.Clicks + 1 
        end
    end
  end
end

X.Craft = function(item)
  X.IsFunding = true
  Citizen.CreateThread(function()
    X.startAnim("mini@repair", "fixing_a_ped")
    Wait(10000)
    ClearPedTasks(PlayerPedId())
    X.IsFunding = false
    TriggerServerEvent('tm1_stores:craft',item)
  end)
end

X.CanPick = function(coords)
  for i,v in pairs(Config.Rocks) do
    if GetDistanceBetweenCoords(coords.x,coords.y,coords.z,v.x,v.y,v.z) < 5 then
      if v.health >= v.max / 2 then
        X.DrawText3D({x = v.x, y = v.y, z = v.z}, Local.rockOf.."~b~"..Local[v.data].."~w~ : ~g~"..v.health.."/"..v.max)
      elseif v.health >= v.max / 4 then
        X.DrawText3D({x = v.x, y = v.y, z = v.z}, Local.rockOf.."~b~"..Local[v.data].."~w~ : ~b~"..v.health.."/"..v.max)
      elseif v.health < v.max / 4 and v.health ~= 0 then
        X.DrawText3D({x = v.x, y = v.y, z = v.z}, Local.rockOf.."~b~"..Local[v.data].."~w~ : ~y~"..v.health.."/"..v.max)
      elseif v.health <= 0 then
        X.DrawText3D({x = v.x, y = v.y, z = v.z}, Local.rockOf.."~b~"..Local[v.data].."~w~ : ~r~ "..v.health.."/"..v.max)  
      end
    end
    if GetCurrentPedWeapon(PlayerPedId(),"WEAPON_BATTLEAXE",true) then
      if IsControlJustReleased(1,  24) then
        if GetDistanceBetweenCoords(coords.x,coords.y,coords.z,v.x,v.y,v.z) < 2.5 and v.health > 0 then
          if v then
            X.Click(v)
          end
        end
      end
    end
  end
end

X.OpenFundition = function()

  local elements = {
    {label = Local.melt..Local.carbon, value = "carbon"},
    {label = Local.melt..Local.iron, value = "iron"},
    {label = Local.melt..Local.silver, value = "silver"},
    {label = Local.melt..Local.gold, value = "gold"},
  }

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'fundir',
    {
      title  = Local.fundition,
      align    = 'bottom-right',
      elements = elements
    },
    function(data, menu)  
      if data.current.value and X.IsFunding == false then
        X.Craft(data.current.value)
      end
      menu.close()
    end,
    function(data, menu)
      menu.close()
    end
  )
end

--X.IsPossible = function(typed)
--  if Config.isExperienceSystemActive == true then 
--    if X.Level == 0 then
--        return false
--    elseif X.Level == 1 then
--        if typed == "iron" or typed == "silver" or typed == "gold" then
--            return false
--        end
--    elseif X.Level == 2 then
--        if typed == "silver" or typed == "gold" then
--            return false
--        end
--    elseif X.Level == 3 then
--        if typed == "gold" then
--            return false
--        end
--    end
--    return true
--  else
--    return true
--  end
--end
