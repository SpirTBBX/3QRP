ESX = nil
local lab = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('es:addCommand', 'mdt', function(source, args, user)
	local usource = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == 'police' then
    	MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_reports` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(reports)
    		for r = 1, #reports do
    			reports[r].charges = json.decode(reports[r].charges)
    		end
    		MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_warrants` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(warrants)
    			for w = 1, #warrants do
    				warrants[w].charges = json.decode(warrants[w].charges)
    			end


    			local officer = GetCharacterName(usource)
    			TriggerClientEvent('tqrp_mdt:toggleVisibilty', usource, reports, warrants, officer)
    		end)
    	end)
    end
end)

RegisterServerEvent("tqrp_mdt:hotKeyOpen")
AddEventHandler("tqrp_mdt:hotKeyOpen", function()
	local usource = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == 'police' then
    	MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_reports` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(reports)
    		for r = 1, #reports do
    			reports[r].charges = json.decode(reports[r].charges)
    		end
    		MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_warrants` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(warrants)
    			for w = 1, #warrants do
    				warrants[w].charges = json.decode(warrants[w].charges)
    			end


    			local officer = GetCharacterName(usource)
    			TriggerClientEvent('tqrp_mdt:toggleVisibilty', usource, reports, warrants, officer)
    		end)
    	end)
    end
end)

RegisterServerEvent("tqrp_mdt:getOffensesAndOfficer")
AddEventHandler("tqrp_mdt:getOffensesAndOfficer", function()
	local usource = source
	local charges = {}
	MySQL.Async.fetchAll('SELECT * FROM fine_types', {
	}, function(fines)
		for j = 1, #fines do
			if fines[j].category == 0 or fines[j].category == 1 or fines[j].category == 2 or fines[j].category == 3 or fines[j].category == 4 or fines[j].category == 5 or fines[j].category == 6 or fines[j].category == 7 or fines[j].category == 8 or fines[j].category == 9 then
				table.insert(charges, fines[j])
			end
		end

		local officer = GetCharacterName(usource)

		TriggerClientEvent("tqrp_mdt:returnOffensesAndOfficer", usource, charges, officer)
	end)
end)

RegisterServerEvent("tqrp_mdt:performOffenderSearch")
AddEventHandler("tqrp_mdt:performOffenderSearch", function(query)
	local usource = source
	local matches = {}
	MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE LOWER(`firstname`) LIKE @query OR LOWER(`lastname`) LIKE @query OR CONCAT(LOWER(`firstname`), ' ', LOWER(`lastname`)) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			table.insert(matches, data)
		end

		TriggerClientEvent("tqrp_mdt:returnOffenderSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("tqrp_mdt:getOffenderDetails")
AddEventHandler("tqrp_mdt:getOffenderDetails", function(offender)
	local usource = source
	GetLicenses(offender.identifier, function(licenses) offender.licenses = licenses end)
	while offender.licenses == nil do Citizen.Wait(0) end
	MySQL.Async.fetchAll('SELECT * FROM `user_mdt` WHERE `char_id` = @id', {
		['@id'] = offender.id
	}, function(result)
		offender.notes = ""
		offender.mugshot_url = ""
		if result[1] then
			offender.notes = result[1].notes
			offender.mugshot_url = result[1].mugshot_url
		end
		MySQL.Async.fetchAll('SELECT * FROM `user_convictions` WHERE `char_id` = @id', {
			['@id'] = offender.id
		}, function(convictions)
			if convictions[1] then
				offender.convictions = {}
				for i = 1, #convictions do
					local conviction = convictions[i]
					offender.convictions[conviction.offense] = conviction.count
				end
			end

			MySQL.Async.fetchAll('SELECT * FROM `mdt_warrants` WHERE `char_id` = @id', {
				['@id'] = offender.id
			}, function(warrants)
				if warrants[1] then
					offender.haswarrant = true
				end

				TriggerClientEvent("tqrp_mdt:returnOffenderDetails", usource, offender)
			end)
		end)
	end)
end)

RegisterServerEvent("tqrp_mdt:getOffenderDetailsById")
AddEventHandler("tqrp_mdt:getOffenderDetailsById", function(char_id)
	local usource = source
	MySQL.Async.fetchAll('SELECT * FROM `characters` WHERE `id` = @id', {
		['@id'] = char_id
	}, function(result)
		local offender = result[1]
		GetLicenses(offender.identifier, function(licenses) offender.licenses = licenses end)
		while offender.licenses == nil do Citizen.Wait(0) end
		MySQL.Async.fetchAll('SELECT * FROM `user_mdt` WHERE `char_id` = @id', {
			['@id'] = offender.id
		}, function(result)
			offender.notes = ""
			offender.mugshot_url = ""
			if result[1] then
				offender.notes = result[1].notes
				offender.mugshot_url = result[1].mugshot_url
			end
			MySQL.Async.fetchAll('SELECT * FROM `user_convictions` WHERE `char_id` = @id', {
				['@id'] = offender.id
			}, function(convictions)
				if convictions[1] then
					offender.convictions = {}
					for i = 1, #convictions do
						local conviction = convictions[i]
						offender.convictions[conviction.offense] = conviction.count
					end
				end

				TriggerClientEvent("tqrp_mdt:returnOffenderDetails", usource, offender)
			end)
		end)

	end)
end)

RegisterServerEvent("tqrp_mdt:saveOffenderChanges")
AddEventHandler("tqrp_mdt:saveOffenderChanges", function(id, changes, identifier)
	MySQL.Async.fetchAll('SELECT * FROM `user_mdt` WHERE `char_id` = @id', {
		['@id']  = id
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE `user_mdt` SET `notes` = @notes, `mugshot_url` = @mugshot_url WHERE `char_id` = @id', {
				['@id'] = id,
				['@notes'] = changes.notes,
				['@mugshot_url'] = changes.mugshot_url
			})
		else
			MySQL.Async.insert('INSERT INTO `user_mdt` (`char_id`, `notes`, `mugshot_url`) VALUES (@id, @notes, @mugshot_url)', {
				['@id'] = id,
				['@notes'] = changes.notes,
				['@mugshot_url'] = changes.mugshot_url
			})
		end
		for i = 1, #changes.licenses_removed do
			local license = changes.licenses_removed[i]
			MySQL.Async.execute('DELETE FROM `user_licenses` WHERE `type` = @type AND `owner` = @identifier', {
				['@type'] = license.type,
				['@identifier'] = identifier
			})
		end
		if changes.convictions ~= nil then
			for conviction, amount in pairs(changes.convictions) do	
				MySQL.Async.execute('UPDATE `user_convictions` SET `count` = @count WHERE `char_id` = @id AND `offense` = @offense', {
					['@id'] = id,
					['@count'] = amount,
					['@offense'] = conviction
				})
			end
		end

		for i = 1, #changes.convictions_removed do
			MySQL.Async.execute('DELETE FROM `user_convictions` WHERE `char_id` = @id AND `offense` = @offense', {
				['@id'] = id,
				['offense'] = changes.convictions_removed[i]
			})
		end
	end)
end)

RegisterServerEvent("tqrp_mdt:saveReportChanges")
AddEventHandler("tqrp_mdt:saveReportChanges", function(data)
	MySQL.Async.execute('UPDATE `mdt_reports` SET `title` = @title, `incident` = @incident WHERE `id` = @id', {
		['@id'] = data.id,
		['@title'] = data.title,
		['@incident'] = data.incident
	})
end)

RegisterServerEvent("tqrp_mdt:deleteReport")
AddEventHandler("tqrp_mdt:deleteReport", function(id)
	MySQL.Async.execute('DELETE FROM `mdt_reports` WHERE `id` = @id', {
		['@id']  = id
	})
end)

RegisterServerEvent("tqrp_mdt:submitNewReport")
AddEventHandler("tqrp_mdt:submitNewReport", function(data)
	local usource = source
	local author = GetCharacterName(source)
	if tonumber(data.sentence) and tonumber(data.sentence) > 0 then
		data.sentence = tonumber(data.sentence)
	else 
		data.sentence = nil 
	end
	charges = json.encode(data.charges)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	MySQL.Async.insert('INSERT INTO `mdt_reports` (`char_id`, `title`, `incident`, `charges`, `author`, `name`, `date`, `jailtime`) VALUES (@id, @title, @incident, @charges, @author, @name, @date, @sentence)', {
		['@id']  = data.char_id,
		['@title'] = data.title,
		['@incident'] = data.incident,
		['@charges'] = charges,
		['@author'] = author,
		['@name'] = data.name,
		['@date'] = data.date,
		['@sentence'] = data.sentence
	}, function(id)
		TriggerEvent("tqrp_mdt:getReportDetailsById", id, usource)
	end)

	for offense, count in pairs(data.charges) do
		MySQL.Async.fetchAll('SELECT * FROM `user_convictions` WHERE `offense` = @offense AND `char_id` = @id', {
			['@offense'] = offense,
			['@id'] = data.char_id
		}, function(result)
			if result[1] then
				MySQL.Async.execute('UPDATE `user_convictions` SET `count` = @count WHERE `offense` = @offense AND `char_id` = @id', {
					['@id']  = data.char_id,
					['@offense'] = offense,
					['@count'] = count + 1
				})
			else
				MySQL.Async.insert('INSERT INTO `user_convictions` (`char_id`, `offense`, `count`) VALUES (@id, @offense, @count)', {
					['@id']  = data.char_id,
					['@offense'] = offense,
					['@count'] = count
				})
			end
		end)
	end
end)

RegisterServerEvent("tqrp_mdt:sentencePlayer")
AddEventHandler("tqrp_mdt:sentencePlayer", function(jailtime, charges, char_id, fine, players)
	local usource = source
	local jailmsg = ""
	for offense, amount in pairs(charges) do
		jailmsg = jailmsg .. " "..offense.." x"..amount.." |"
	end
	for _, src in pairs(players) do
		if src ~= 0 and GetPlayerName(src) then
			MySQL.Async.fetchAll('SELECT * FROM `characters` WHERE `identifier` = @identifier', {
				['@identifier'] = GetPlayerIdentifiers(src)[1]
			}, function(result)
				if result[1].identifier == char_id then
					if jailtime and jailtime > 0 then
						jailtime = math.ceil(jailtime)
						TriggerEvent("esx-qalle-jail:jailPlayer", src, jailtime, jailmsg)
					end
					if fine > 0 then
						TriggerClientEvent("tqrp_mdt:billPlayer", usource, src, 'society_police', 'Fine: '..jailmsg, fine)
					end
					return
				end
			end)
		end
	end
end)

RegisterServerEvent("tqrp_mdt:performReportSearch")
AddEventHandler("tqrp_mdt:performReportSearch", function(query)
	local usource = source
	local matches = {}
	MySQL.Async.fetchAll("SELECT * FROM `mdt_reports` WHERE `id` LIKE @query OR LOWER(`title`) LIKE @query OR LOWER(`name`) LIKE @query OR LOWER(`author`) LIKE @query or LOWER(`charges`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			data.charges = json.decode(data.charges)
			table.insert(matches, data)
		end

		TriggerClientEvent("tqrp_mdt:returnReportSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("tqrp_mdt:performVehicleSearch")
AddEventHandler("tqrp_mdt:performVehicleSearch", function(query)
	local usource = source
	local matches = {}
	MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE LOWER(`plate`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			local data_decoded = json.decode(data.vehicle)
			data.model = data_decoded.model
			if data_decoded.color1 then
				data.color = colors[tostring(data_decoded.color1)]
				if colors[tostring(data_decoded.color2)] then
					data.color = colors[tostring(data_decoded.color2)] .. " com " .. colors[tostring(data_decoded.color1)]
				end
			end
			table.insert(matches, data)
		end

		TriggerClientEvent("tqrp_mdt:returnVehicleSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("tqrp_mdt:performVehicleSearchInFront")
AddEventHandler("tqrp_mdt:performVehicleSearchInFront", function(query)
	local usource = source
	local xPlayer = ESX.GetPlayerFromId(usource)
    if xPlayer.job.name == 'police' then
		MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `plate` = @query", {
			['@query'] = query
		}, function(result)
			TriggerClientEvent("tqrp_mdt:toggleVisibilty", usource)
			TriggerClientEvent("tqrp_mdt:returnVehicleSearchInFront", usource, result, query)
		end)
	end
end)

RegisterServerEvent("tqrp_mdt:getVehicle")
AddEventHandler("tqrp_mdt:getVehicle", function(vehicle)
	local usource = source
	MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `identifier` = @query", {
		['@query'] = vehicle.owner
	}, function(result)
		if result[1] then
			vehicle.owner = result[1].firstname .. ' ' .. result[1].lastname
			vehicle.owner_id = result[1].id
		end

		vehicle.type = types[vehicle.type]
		TriggerClientEvent("tqrp_mdt:returnVehicleDetails", usource, vehicle)
	end)
end)

RegisterServerEvent("tqrp_mdt:getWarrants")
AddEventHandler("tqrp_mdt:getWarrants", function()
	local usource = source
	MySQL.Async.fetchAll("SELECT * FROM `mdt_warrants`", {}, function(warrants)
		for i = 1, #warrants do
			warrants[i].expire_time = ""
			warrants[i].charges = json.decode(warrants[i].charges)
		end
		TriggerClientEvent("tqrp_mdt:returnWarrants", usource, warrants)
	end)
end)

RegisterServerEvent("tqrp_mdt:submitNewWarrant")
AddEventHandler("tqrp_mdt:submitNewWarrant", function(data)
	local usource = source
	data.charges = json.encode(data.charges)
	data.author = GetCharacterName(source)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	MySQL.Async.insert('INSERT INTO `mdt_warrants` (`name`, `char_id`, `report_id`, `report_title`, `charges`, `date`, `expire`, `notes`, `author`) VALUES (@name, @char_id, @report_id, @report_title, @charges, @date, @expire, @notes, @author)', {
		['@name']  = data.name,
		['@char_id'] = data.char_id,
		['@report_id'] = data.report_id,
		['@report_title'] = data.report_title,
		['@charges'] = data.charges,
		['@date'] = data.date,
		['@expire'] = data.expire,
		['@notes'] = data.notes,
		['@author'] = data.author
	}, function()
		TriggerClientEvent("tqrp_mdt:completedWarrantAction", usource)
	end)
end)

RegisterServerEvent("tqrp_mdt:deleteWarrant")
AddEventHandler("tqrp_mdt:deleteWarrant", function(id)
	local usource = source
	MySQL.Async.execute('DELETE FROM `mdt_warrants` WHERE `id` = @id', {
		['@id']  = id
	}, function()
		TriggerClientEvent("tqrp_mdt:completedWarrantAction", usource)
	end)
end)

RegisterServerEvent("tqrp_mdt:getReportDetailsById")
AddEventHandler("tqrp_mdt:getReportDetailsById", function(query, _source)
	if _source then source = _source end
	local usource = source
	MySQL.Async.fetchAll("SELECT * FROM `mdt_reports` WHERE `id` = @query", {
		['@query'] = query
	}, function(result)
		if result and result[1] then
			result[1].charges = json.decode(result[1].charges)
			TriggerClientEvent("tqrp_mdt:returnReportDetails", usource, result[1])
		end
	end)
end)

function GetLicenses(identifier, cb)

	MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner', {
		['@owner'] = identifier
	}, function(result)
		local licenses   = {}
		local asyncTasks = {}

		for i=1, #result, 1 do

			local scope = function(type)
				table.insert(asyncTasks, function(cb)
					MySQL.Async.fetchAll('SELECT * FROM licenses WHERE type = @type', {
						['@type'] = type
					}, function(result2)
						if result2[1].label == nil then
							lab = "Desconhecida"
						else
							lab = result2[1].label
						end
						table.insert(licenses, {
							type  = type,
							label = lab
						})

						cb()
					end)
				end)
			end

			scope(result[i].type)

		end

		Async.parallel(asyncTasks, function(results)
			if #licenses == 0 then licenses = false end
			cb(licenses)
		end)

	end)
end

function GetCharacterName(source)
	local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
		['@identifier'] = GetPlayerIdentifiers(source)[1]
	})

	if result[1] and result[1].firstname and result[1].lastname then
		return ('%s %s'):format(result[1].firstname, result[1].lastname)
	end
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end