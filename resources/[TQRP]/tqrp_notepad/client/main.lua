ESX = nil

local isUiOpen = false 
local object = 0
local TestLocalTable = {}
local editingNotpadId = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.225, 0.225)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end


RegisterNUICallback('escape', function(data, cb)
    local text = data.text
    TriggerEvent("lkrp_notepad:CloseNotepad")
end)

RegisterNUICallback('updating', function(data, cb)
    local text = data.text
    TriggerServerEvent("server:updateNote",editingNotpadId, text)
    editingNotpadId = nil
    TriggerEvent("lkrp_notepad:CloseNotepad")
end)

RegisterNUICallback('droppingEmpty', function(data, cb)
    print('Nop assim não dá')
end)

RegisterNUICallback('dropping', function(data, cb)
    local text = data.text
    local location = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("server:newNote",text,location["x"],location["y"],location["z"])
    TriggerEvent("lkrp_notepad:CloseNotepad")
end)

RegisterNetEvent("lkrp_notepad:OpenNotepadGui")
AddEventHandler("lkrp_notepad:OpenNotepadGui", function()
    if not isUiOpen then
        openGui()
    end
end)

RegisterNetEvent("lkrp_notepad:CloseNotepad")
AddEventHandler("lkrp_notepad:CloseNotepad", function()
    SendNUIMessage({
        action = 'closeNotepad'
    })
    SetPlayerControl(PlayerId(), 1, 0)
    isUiOpen = false
    SetNuiFocus(false, false);
    TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    Citizen.Wait(100)
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(prop, 1, 1)
    DeleteObject(prop)
    DetachEntity(secondaryprop, 1, 1)
    DeleteObject(secondaryprop)
end)

RegisterNetEvent('lkrp_notepad:note')
AddEventHandler('lkrp_notepad:note', function()
    local player = PlayerPedId()
    local ad = "missheistdockssetup1clipboard@base"
                
    local prop_name = prop_name or 'prop_notepad_01'
    local secondaryprop_name = secondaryprop_name or 'prop_pencil_01'
    
    if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
        loadAnimDict( ad )
        if ( IsEntityPlayingAnim( player, ad, "base", 3 ) ) then 
            TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
            Citizen.Wait(100)
            ClearPedSecondaryTask(PlayerPedId())
            DetachEntity(prop, 1, 1)
            DeleteObject(prop)
            DetachEntity(secondaryprop, 1, 1)
            DeleteObject(secondaryprop)
        else
            local x,y,z = table.unpack(GetEntityCoords(player))
            prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
            secondaryprop = CreateObject(GetHashKey(secondaryprop_name), x, y, z+0.2,  true,  true, true)
            AttachEntityToEntity(prop, player, GetPedBoneIndex(player, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true) -- lkrp_notepadpad
            AttachEntityToEntity(secondaryprop, player, GetPedBoneIndex(player, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true) -- pencil
            TaskPlayAnim( player, ad, "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        end     
    end
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

RegisterNetEvent('lkrp_notepad:updateNotes')
AddEventHandler('lkrp_notepad:updateNotes', function(serverNotesPassed)
    TestLocalTable = serverNotesPassed
end)

function openGui() 
    local veh = GetVehiclePedIsUsing(PlayerPedId())  
    if GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then
        SetPlayerControl(PlayerId(), 0, 0)
        SendNUIMessage({
            action = 'openNotepad',
        })
        isUiOpen = true
        SetNuiFocus(true, true);
    end
end

function openGuiRead(text)
  local veh = GetVehiclePedIsUsing(PlayerPedId())
  if GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then
        SetPlayerControl(PlayerId(), 0, 0)
        TriggerEvent("lkrp_notepad:note")
        isUiOpen = true
        Citizen.Trace("OPENING")
        SendNUIMessage({
            action = 'openNotepadRead',
            TextRead = text,
        })
        SetNuiFocus(true, true)
  end  
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if (#TestLocalTable > 0) then
            local closestNoteDistance = 100.0
            local closestNoteId = 0
            local plyLoc = GetEntityCoords(PlayerPedId())
            for i = 1, #TestLocalTable do
                local distance = GetDistanceBetweenCoords(plyLoc["x"], plyLoc["y"], plyLoc["z"], TestLocalTable[i]["x"],TestLocalTable[i]["y"],TestLocalTable[i]["z"], true)
                if distance < 10.0 and TestLocalTable[i]["created"] == false then
                    --DrawMarker(27, TestLocalTable[i]["x"],TestLocalTable[i]["y"],TestLocalTable[i]["z"]-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 2.0, 255, 255,150, 75, 0, 0, 2, 0, 0, 0, 0)
                    prop = CreateObject(GetHashKey("p_amanda_note_01_s"), TestLocalTable[i]["x"],TestLocalTable[i]["y"],TestLocalTable[i]["z"],  true,  true, true)
                    PlaceObjectOnGroundProperly(prop)
                    FreezeEntityPosition(prop, true)
                    TestLocalTable[i]["created"] = true
                end

                if distance < closestNoteDistance then
                  closestNoteDistance = distance
                  closestNoteId = i
                end
            end

            if closestNoteDistance > 100.0 then
                Citizen.Wait(math.ceil(closestNoteDistance*10))
            end

            if TestLocalTable[closestNoteId] ~= nil then
                local distance = GetDistanceBetweenCoords(plyLoc, TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"], true)
                if distance < 2.0 then
                    --DrawMarker(27, TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"]-0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 2.0, 255, 255, 155, 75, 0, 0, 2, 0, 0, 0, 0)
                    DrawText3Ds(TestLocalTable[closestNoteId]["x"],TestLocalTable[closestNoteId]["y"],TestLocalTable[closestNoteId]["z"]-0.6, "[~g~E~w~] Ler  [~g~G~w~] Destruir")

                    if IsControlJustReleased(0, 38) then
                        openGuiRead(TestLocalTable[closestNoteId]["text"])
                        editingNotpadId = closestNoteId
                    end
                    if IsControlJustReleased(0, 47) then
                        TriggerServerEvent("server:destroyNote",closestNoteId)
                        TestLocalTable[closestNoteId]["created"] = false
                        local obj = GetClosestObjectOfType(plyLoc.x, plyLoc.y, plyLoc.z, 1.0, GetHashKey("p_amanda_note_01_s"), false, false, false)
                        DeleteObject(obj)
                        table.remove(TestLocalTable,closestNoteId)
                    end
                end
            else
                if TestLocalTable[closestNoteId] ~= nil then
                    TestLocalTable[closestNoteId]["created"] = false
                    local obj = GetClosestObjectOfType(plyLoc.x, plyLoc.y, plyLoc.z, 1.0, GetHashKey("p_amanda_note_01_s"), false, false, false)
                    DeleteObject(obj)
                    table.remove(TestLocalTable,closestNoteId)
                end
            end 
        else
            Citizen.Wait(1500)
        end
    end 
end)