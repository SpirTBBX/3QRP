ESX                     = nil
local CurrentAction     = nil
local CurrentActionMsg  = nil
local CurrentActionData = nil
local Licenses          = {}
local CurrentTest       = nil
local CurrentTestType   = nil
local CurrentVehicle    = nil
local CurrentCheckPoint = 0
local LastCheckPoint    = -1
local CurrentBlip       = nil
local CurrentZoneType   = nil
local DriveErrors       = 0
local IsAboveSpeedLimit = false
local LastVehicleHealth = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

function DrawMissionText(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end

function starttheory()
	while CurrentTest == 'theory' do
		local playerPed = PlayerPedId()
		DisableControlAction(0, 1, true) -- LookLeftRight
		DisableControlAction(0, 2, true) -- LookUpDown
		DisablePlayerFiring(playerPed, true) -- Disable weapon firing
		DisableControlAction(0, 142, true) -- MeleeAttackAlternate
		DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		Citizen.Wait(10)
	end
end

function StartTheoryTest()
	CurrentTest = 'theory'

	SendNUIMessage({
		openQuestion = true
	})

	ESX.SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)
	starttheory()
	TriggerServerEvent('tqrp_billing:sendBill', GetPlayerServerId(PlayerId()), 'society_police', 'Teste Teórico de Condução', Config.Prices['dmv'])
end

function StopTheoryTest(success)
	CurrentTest = nil

	SendNUIMessage({
		openQuestion = false
	})

	SetNuiFocus(false)

	if success then
		TriggerServerEvent('tqrp_dmvschool:addLicense', 'dmv')
		exports['mythic_notify']:SendAlert('true', "Aprovado")
	else
		exports['mythic_notify']:SendAlert('false', "Reprovado")
	end
end

function StartDriveTest(type)
	ESX.Game.SpawnVehicle(Config.VehicleModels[type], Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Pos.h, function(vehicle)
		CurrentTest       = 'drive'
		CurrentTestType   = type
		CurrentCheckPoint = 0
		LastCheckPoint    = -1
		CurrentZoneType   = 'residence'
		DriveErrors       = 0
		IsAboveSpeedLimit = false
		CurrentVehicle    = vehicle
		LastVehicleHealth = GetEntityHealth(vehicle)
		local playerPed   = PlayerPedId()
		TriggerEvent("onyx:updatePlates", GetVehicleNumberPlateText(vehicle))
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		exports["tqrp_base"]:SetFuel(vehicle, 100)
		startdrive()
		TriggerServerEvent('tqrp_billing:sendBill', GetPlayerServerId(PlayerId()), 'society_police', 'Teste de Condução', Config.Prices[CurrentTest])
	end)
end

function StopDriveTest(success)
	if success then
		TriggerServerEvent('tqrp_dmvschool:addLicense', CurrentTestType)
		exports['mythic_notify']:SendAlert('true', "Aprovado")
	else
		exports['mythic_notify']:SendAlert('false', "Reprovado")
	end
	CurrentTest     = nil
	CurrentTestType = nil
end

function SetCurrentZoneType(type)
	CurrentZoneType = type
end

function OpenDMVSchoolMenu()
	ESX.TriggerServerCallback('tqrp_dmvschool:loadLicense', function(cb)
		Licenses = cb
		local ownedLicenses = {}
		for i=1, #Licenses, 1 do
			ownedLicenses[Licenses[i].type] = true
		end

		local elements = {}

		if not ownedLicenses['dmv'] then
			table.insert(elements, {
				label = (('%s: <span style="color:green;">%s</span>'):format(_U('theory_test'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['dmv'])))),
				value = 'theory_test'
			})
		end

		if ownedLicenses['dmv'] then
			if not ownedLicenses['drive'] then
				table.insert(elements, {
					label = (('%s: <span style="color:green;">%s</span>'):format(_U('road_test_car'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive'])))),
					value = 'drive_test',
					type = 'drive'
				})
			end

			if not ownedLicenses['drive_bike'] then
				table.insert(elements, {
					label = (('%s: <span style="color:green;">%s</span>'):format(_U('road_test_bike'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive_bike'])))),
					value = 'drive_test',
					type = 'drive_bike'
				})
			end

			if not ownedLicenses['drive_truck'] then
				table.insert(elements, {
					label = (('%s: <span style="color:green;">%s</span>'):format(_U('drive_truck'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive_truck'])))),
					value = 'drive_test',
					type = 'drive_truck'
				})
			end
		end

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dmvschool_actions', {
			title    = _U('driving_school'),
			elements = elements,
			align    = 'top-left'
		}, function(data, menu)
			if data.current.value == 'theory_test' then
				menu.close()
				StartTheoryTest()
			elseif data.current.value == 'drive_test' then
				menu.close()
				StartDriveTest(data.current.type)
			end
		end, function(data, menu)
			menu.close()
			CurrentAction     = 'dmvschool_menu'
			CurrentActionMsg  = _U('press_open_menu')
			CurrentActionData = {}
		end)
	end)
end

RegisterNUICallback('question', function(data, cb)
	SendNUIMessage({
		openSection = 'question'
	})

	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

AddEventHandler('tqrp_dmvschool:hasEnteredMarker', function(zone)
	if zone == 'DMVSchool' then
		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = _U('press_open_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('tqrp_dmvschool:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)

	SetBlipSprite (blip, 408)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.6)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('driving_school_blip'))
	EndTextCommandSetBlipName(blip)
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1500)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('tqrp_dmvschool:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('tqrp_dmvschool:hasExitedMarker', LastZone)
		end
	end
end)

-- Block UI
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(7)
		local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z, true)
		if (distance < 5) and IsPedOnFoot(PlayerPedId()) then
			DrawMarker(27, Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 1, 157, 0, 155, false, false, 2, false, false, false, false)
			if distance < 1.5 then
				DrawText3Ds(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, (Config.Zones.DMVSchool.Pos.z + 1.0),"Clica [~g~E~w~] para falar com o instrutor")
				if IsControlJustReleased(0, 38) then
					OpenDMVSchoolMenu()
				end
			end
		else
			Citizen.Wait(1500)
		end
	end
end)

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)

	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(6)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

function startdrive()
	while CurrentTest == 'drive' do
		if CurrentVehicle == GetVehiclePedIsIn(PlayerPedId(), false) then
			local playerPed      = PlayerPedId()
			local coords         = GetEntityCoords(playerPed)
			local nextCheckPoint = CurrentCheckPoint + 1

			if Config.CheckPoints[nextCheckPoint] == nil then
				if DoesBlipExist(CurrentBlip) then
					RemoveBlip(CurrentBlip)
				end
				CurrentTest = nil
				if DriveErrors < Config.MaxErrors then
					StopDriveTest(true)
					ESX.Game.DeleteVehicle(CurrentVehicle)
				else
					StopDriveTest(false)
					ESX.Game.DeleteVehicle(CurrentVehicle)
				end
			else

				if CurrentCheckPoint ~= LastCheckPoint then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end

					CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
					SetBlipRoute(CurrentBlip, 1)

					LastCheckPoint = CurrentCheckPoint
				end

				local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)

				if distance <= 100.0 then
					DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 3.0 then
					Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
					CurrentCheckPoint = CurrentCheckPoint + 1
				end
			end
		end
		Citizen.Wait(10)
	end
end

-- Speed / Damage control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if CurrentTest == 'drive' then

			local playerPed = PlayerPedId()

			if IsPedInAnyVehicle(playerPed, false) then

				local vehicle      = GetVehiclePedIsIn(playerPed, false)
				local speed        = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
				local tooMuchSpeed = false

				for k,v in pairs(Config.SpeedLimits) do
					if CurrentZoneType == k and speed > v then
						tooMuchSpeed = true

						if not IsAboveSpeedLimit then
							DriveErrors       = DriveErrors + 1
							IsAboveSpeedLimit = true
							TriggerEvent("pNotify:SendNotification", {text = "<span style='font-weight: 300'> " ..  _U('driving_too_fast', v) .." </span>",
								layout = "topRight",
								timeout = 2000,
								progressBar = false,
								type = "error",
								animation = {
									open = "gta_effects_fade_in",
									close = "gta_effects_fade_out"
							}})
							TriggerEvent("pNotify:SendNotification", {text = "<span style='font-weight: 300'> " ..  _U('errors', DriveErrors, Config.MaxErrors) .." </span>",
								layout = "topRight",
								timeout = 2000,
								progressBar = false,
								type = "error",
								animation = {
									open = "gta_effects_fade_in",
									close = "gta_effects_fade_out"
							}})
						end
					end
				end

				if not tooMuchSpeed then
					IsAboveSpeedLimit = false
				end

				local health = GetEntityHealth(vehicle)
				if health < LastVehicleHealth then

					DriveErrors = DriveErrors + 1
					TriggerEvent("pNotify:SendNotification", {text = "<span style='font-weight: 300'> " ..  _U('you_damaged_veh') .." </span>",
						layout = "topRight",
						timeout = 2000,
						progressBar = false,
						type = "error",
						animation = {
							open = "gta_effects_fade_in",
							close = "gta_effects_fade_out"
					}})
					TriggerEvent("pNotify:SendNotification", {text = "<span style='font-weight: 300'> " ..  _U('errors', DriveErrors, Config.MaxErrors) .." </span>",
						layout = "topRight",
						timeout = 2000,
						progressBar = false,
						type = "error",
						animation = {
							open = "gta_effects_fade_in",
							close = "gta_effects_fade_out"
					}})
					-- avoid stacking faults
					LastVehicleHealth = health
					Citizen.Wait(1500)
				end
			end
		else
			-- not currently taking driver test
			Citizen.Wait(1500)
		end
	end
end)