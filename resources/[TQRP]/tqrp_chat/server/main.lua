function getIdentity(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			dateofbirth = identity['dateofbirth'],
			sex = identity['sex'],
			height = identity['height']
			
		}
	else
		return nil
	end
end



AddEventHandler('chatMessage', function(source, n, message)
    local mPlayer = GetPlayerPed(-1)
    
    if mPlayer ~= nil then

        if(starts_with(message, '/'))then
            local command_args = stringsplit(message, " ")

            command_args[1] = string.gsub(command_args[1], '/', "")

            local commandName = command_args[1]

            if commands[commandName] ~= nil then
                local command = commands[commandName]

                if(command)then
                    local Source = source
                    CancelEvent()
                    table.remove(command_args, 1)
                    if (not (command.arguments <= (#command_args - 1)) and command.arguments > -1) then
                        TriggerEvent('fu_chat:server:Server', source, "Invalid Number Of Arguments")
                    end
                else
                    TriggerEvent('fu_chat:server:Server', source, "Invalid Command Handler")
                end
            end
        end
    end
    CancelEvent()
end)

RegisterServerEvent('fu_chat:server:Server')
AddEventHandler('fu_chat:server:Server', function(source, message)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message server"> [SERVER] {0}</div>',
        args = { message }
    })
    CancelEvent()
end)


RegisterServerEvent('fu_chat:server:ooc')
AddEventHandler('fu_chat:server:ooc', function(id, name, message, coords)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message ooc"> [<b>{0}</b>]  {1} | {2}</div>',
        args = {id, name, message, coords }
    })
    CancelEvent()
end)

RegisterServerEvent('fu_chat:server:sem')
AddEventHandler('fu_chat:server:sem', function(id, name, message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message sem"> [<b>{0}</b>]  {1} | {2}</div>',
        args = {id, name, message }
    })
    CancelEvent()
end)


RegisterServerEvent('fu_chat:server:ServerToAll')
AddEventHandler('fu_chat:server:ServerToAll', function(message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message server"> [SERVER] {0}</div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('fu_chat:server:System')
AddEventHandler('fu_chat:server:System', function(source, message)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message system"> [SYSTEM] {0} </div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('fu_chat:server:SystemToAll')
AddEventHandler('fu_chat:server:SystemToAll', function(message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message system"> [SYSTEM] {0} </div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('fu_chat:server:Advert')
AddEventHandler('fu_chat:server:Advert', function(name, message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message advert"><i class="fas fa-ad"></i> Advertisement: {0} | {1}</div>',
        args = { name, message }
    })
    CancelEvent()
end)


RegisterServerEvent('fu_chat:server:Tweet')
AddEventHandler('fu_chat:server:Tweet', function(name, message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message twitter"><i class="fab fa-twitter"></i> Tweet: @{0} | {1}</div>',
        args = { name, message }
    })
    CancelEvent()
end)

RegisterServerEvent('fu_chat:server:Help')
AddEventHandler('fu_chat:server:Help', function(source, message)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message help">[INFO] {0}</div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('fu_chat:server:SendMeToNear')
AddEventHandler('fu_chat:server:SendMeToNear', function(source, message)
    local src = source
    TriggerClientEvent('fu_chat:client:ReceiveMe', -1, src, message)
end)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end