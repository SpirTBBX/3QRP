ESX               = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('bandage', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bandage', 1)
	TriggerClientEvent('mythic_hospital:items:bandage', source)
end)

ESX.RegisterUsableItem('vicodin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vicodin', 1)
	TriggerClientEvent('mythic_hospital:items:vicodin', source)
end)

ESX.RegisterUsableItem('hydrocodone', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('hydrocodone', 1)
	TriggerClientEvent('mythic_hospital:items:hydrocodone', source)
end)

ESX.RegisterUsableItem('morphine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('morphine', 1)
	TriggerClientEvent('mythic_hospital:items:morphine', source)
end)