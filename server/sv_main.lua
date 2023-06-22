-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface(GetCurrentResourceName(), cRP)

vCLIENT = Tunnel.getInterface(GetCurrentResourceName())
-----------------------------------------------------------------------------------------------------------------------------------------
local calls = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pegar Dados PlayerData
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.getPlayerInformationBd()
	local src = source
	local userPlayerId = vRP.getUserId(src)
	local PlayerData = vRP.query("vRP/get_vrp_users",{ id = userPlayerId })
	if PlayerData[1] ~= nil then
        if vRP.hasPermission(userPlayerId, "Police") then
            PlayerData[1].job = { ["name"] = "police" }
            return PlayerData[1]
        else
            PlayerData[1].job = { ["name"] = "user" }
            return PlayerData[1]
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pegar Dados Inventario PlayerPedId
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.getInventoryItemPlayer()
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        if vRP.tryGetInventoryItem(user_id,"cellphone",1) then
            return true
        end
    else
        TriggerClientEvent("Notify", "aviso", "Voce nao tem telefone/phone")
    end
end

function _U(entry)
	return Locales[Config.Locale][entry] 
end

local function IsPoliceJob(job)
    for k, v in pairs(Config.PoliceJob) do
        if job == v then
            return true
        end
    end
    return false
end

local function IsDispatchJob(job)
    for k, v in pairs(Config.PoliceAndAmbulance) do
        if job == v then
            return true
        end
    end
    return false
end

RegisterServerEvent("dispatch:server:notify", function(data)
	local newId = #calls + 1
	calls[newId] = data
    calls[newId]['source'] = source
    calls[newId]['callId'] = newId
    calls[newId]['units'] = {}
    calls[newId]['responses'] = {}
    calls[newId]['time'] = os.time() * 1000

	TriggerClientEvent('dispatch:clNotify', -1, data, newId, source)
    if not data.alert then 
        TriggerClientEvent("nc-dispatch:client:AddCallBlip", -1, data.origin, dispatchCodes[data.dispatchcodename], newId)
    else
        TriggerClientEvent("nc-dispatch:client:AddCallBlip", -1, data.origin, data.alert, newId)
    end
end)

function GetDispatchCalls() return calls end
exports('GetDispatchCalls', GetDispatchCalls) -- 

-- this is mdt call
AddEventHandler("dispatch:addUnit", function(callid, player, cb)
    if calls[callid] then
        if #calls[callid]['units'] > 0 then
            for i=1, #calls[callid]['units'] do
                if calls[callid]['units'][i]['cid'] == player.cid then
                    cb(#calls[callid]['units'])
                    return
                end
            end
        end

        if IsPoliceJob(player.job.name) then
            calls[callid]['units'][#calls[callid]['units']+1] = { cid = player.cid, fullname = player.fullname, job = 'Police', callsign = player.callsign }
        elseif player.job.name == 'ambulance' then
            calls[callid]['units'][#calls[callid]['units']+1] = { cid = player.cid, fullname = player.fullname, job = 'EMS', callsign = player.callsign }
        end
        cb(#calls[callid]['units'])
    end
end)

AddEventHandler("dispatch:sendCallResponse", function(player, callid, message, time, cb)
    local userPlayerId = vRP.getUserId(player)
	local PlayerData = vRP.query("vRP/get_vrp_users",{ id = userPlayerId })
    local name = PlayerData[1].name.. " " ..PlayerData[1].name2
    if calls[callid] then
        calls[callid]['responses'][#calls[callid]['responses']+1] = {
            name = name,
            message = message,
            time = time
        }
        local player = calls[callid]['source']
        if GetPlayerPing(userPlayerId) > 0 then
            TriggerClientEvent('dispatch:getCallResponse', userPlayerId, message)
        end
        cb(true)
    else
        cb(false)
    end
end)

-- this is mdt call
AddEventHandler("dispatch:removeUnit", function(callid, player, cb)
    if calls[callid] then
        if #calls[callid]['units'] > 0 then
            for i=1, #calls[callid]['units'] do
                if calls[callid]['units'][i]['cid'] == player.cid then
                    calls[callid]['units'][i] = nil
                end
            end
        end
        cb(#calls[callid]['units'])
    end    
end)


RegisterCommand('togglealerts', function(source, args, user)
	local source = source
    local userPlayerId = vRP.getUserId(source)
	local PlayerData = vRP.query("vRP/get_vrp_users",{ id = userPlayerId })
	local job = "police"
	if IsPoliceJob(job) or job == 'ambulance' then
		TriggerClientEvent('dispatch:manageNotifs', source, args[1])
	end
end)

-- Explosion Handler
local ExplosionCooldown = false
AddEventHandler('explosionEvent', function(source, info)
    if ExplosionCooldown then return end

    for i = 1, (#Config.ExplosionTypes) do
        if info.explosionType == Config.ExplosionTypes[i] then
            TriggerClientEvent("nc-dispatch:client:Explosion", source)
            ExplosionCooldown = true
            SetTimeout(1500, function()
                ExplosionCooldown = false
            end)
        end
    end
end)

-- QBCore.Commands.Add("cleardispatchblips", "Clear all dispatch blips", {}, false, function(source, args)
--     local src = source
--     local userPlayerId = vRP.getUserId(source)
-- 	local PlayerData = vRP.query("vRP/get_vrp_users",{ id = userPlayerId })
-- 	local job = "police"
--     if IsDispatchJob(job) then
--         TriggerClientEvent('nc-dispatch:client:clearAllBlips', src)
--     end
-- end)
