RegisterCommand("jailmenu", function(source, args)

	if PlayerData.job.name == "police" then
		OpenJailMenu()
	else
		ESX.ShowNotification("Não és um policia!")
	end
end)

function LoadAnim(animDict)
	RequestAnimDict(animDict)

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end
end

function LoadModel(model)
	RequestModel(model)

	while not HasModelLoaded(model) do
		Citizen.Wait(10)
	end
end

function Cutscene()
	DoScreenFadeOut(100)

	Citizen.Wait(250)

	--local Male = GetHashKey("mp_m_freemode_01")

	TriggerEvent('skinchanger:getSkin', function(skin)
		if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
			local clothesSkin = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 5,   ['torso_2'] = 0,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 5,
				['pants_1'] = 64,   ['pants_2'] = 6,
				['shoes_1'] = 6,   ['shoes_2'] = 0,
				['helmet_1'] = -1,  ['helmet_2'] = 0,
				['mask_1'] = 0,     ['mask_2'] = 0,
				['chain_1'] = 0,    ['chain_2'] = 0,
				['ears_1'] = -1,     ['ears_2'] = 0,
				['glasses_1'] = -1,  ['glasses_2'] = 0,
				['bproof_1'] = 0,  ['bproof_2'] = 0
		    }
			TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)

		elseif	GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
			local clothesSkin = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 286,   ['torso_2'] = 0,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 14,
				['pants_1'] = 66,   ['pants_2'] = 6,
				['shoes_1'] = 4,   ['shoes_2'] = 1,
				['helmet_1'] = -1,  ['helmet_2'] = 0,
				['mask_1'] = 0,     ['mask_2'] = 0,
				['chain_1'] = 0,    ['chain_2'] = 0,
				['ears_1'] = -1,     ['ears_2'] = 0,
				['glasses_1'] = 0,  ['glasses_2'] = 0,
				['bproof_1'] = 0,  ['bproof_2'] = 0
			}
			TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
		end
	end)

	LoadModel(-1320879687)

	local PolicePosition = Config.Cutscene["PolicePosition"]
	local Police = CreatePed(5, -1320879687, PolicePosition["x"], PolicePosition["y"], PolicePosition["z"], PolicePosition["h"], false)
	TaskStartScenarioInPlace(Police, "WORLD_HUMAN_PAPARAZZI", 0, false)

	local PlayerPosition = Config.Cutscene["PhotoPosition"]
	local PlayerPed = PlayerPedId()
	SetEntityCoords(PlayerPed, PlayerPosition["x"], PlayerPosition["y"], PlayerPosition["z"] - 1)
	SetEntityHeading(PlayerPed, PlayerPosition["h"])
	FreezeEntityPosition(PlayerPed, true)

	Cam()

	Citizen.Wait(1500)

	DoScreenFadeIn(100)

	Citizen.Wait(10000)

	DoScreenFadeOut(250)

	local JailPosition = Config.JailPositions["Cell"]
	SetEntityCoords(PlayerPed, JailPosition["x"], JailPosition["y"], JailPosition["z"])
	DeleteEntity(Police)
	SetModelAsNoLongerNeeded(-1320879687)

	Citizen.Wait(1500)

	DoScreenFadeIn(250)

	TriggerServerEvent("InteractSound_SV:PlayOnSource", "cell", 0.3)

	RenderScriptCams(false,  false,  0,  true,  true)
	FreezeEntityPosition(PlayerPed, false)
	DestroyCam(Config.Cutscene["CameraPos"]["cameraId"])

	InJail()
end

function Cam()
	local CamOptions = Config.Cutscene["CameraPos"]

	CamOptions["cameraId"] = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(CamOptions["cameraId"], CamOptions["x"], CamOptions["y"], CamOptions["z"])
	SetCamRot(CamOptions["cameraId"], CamOptions["rotationX"], CamOptions["rotationY"], CamOptions["rotationZ"])

	RenderScriptCams(true, false, 0, true, true)
end
--[[
function TeleportPlayer(pos)

	local Values = pos

	if #Values["goal"] > 1 then

		local elements = {}

		for i, v in pairs(Values["goal"]) do
			table.insert(elements, { label = v, value = v })
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'teleport_jail',
			{
				title    = "Choose Position",
				align    = 'center',
				elements = elements
			},
		function(data, menu)

			local action = data.current.value
			local position = Config.Teleports[action]

			if action == "Boiling Broke" or action == "Security" then

				if PlayerData.job.name ~= "police" then
					ESX.ShowNotification("You don't have an key to go here!")
					return
				end
			end

			menu.close()

			DoScreenFadeOut(100)

			Citizen.Wait(250)

			SetEntityCoords(PlayerPedId(), position["x"], position["y"], position["z"])

			Citizen.Wait(250)

			DoScreenFadeIn(100)
			
		end,

		function(data, menu)
			menu.close()
		end)
	else
		local position = Config.Teleports[Values["goal"][1]]

--		DoScreenFadeOut(100)

--		Citizen.Wait(250)

--		SetEntityCoords(PlayerPedId(), position["x"], position["y"], position["z"])

--		Citizen.Wait(250)

	--	DoScreenFadeIn(100)
--	end
--end

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(1843.7734375,2586.8701171875,45.711929321289)

    SetBlipSprite (blip, 188)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.6)
    SetBlipColour (blip, 49)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Boilingbroke')
    EndTextCommandSetBlipName(blip)
end)