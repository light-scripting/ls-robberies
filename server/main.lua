local shared = require("shared.shared")
local utils = require("utils.server.server")

local ox_inventory = exports.ox_inventory

local robbedNPCs = {}

GlobalState.RobbedNPCs = {}

--- @ return table|nil lootTable
local getRandomLoot = function ()
    local loot = Server.Loot

    if not loot or #loot == 0 then
        errorPrint("getRandomLoot: Server.Loot is empty or nil")
        return nil
    end

    local randomIndex = math.random(#loot)
    local selectedLoot = loot[randomIndex]

    if selectedLoot.chance then
        local roll = math.random(100)

        if roll > selectedLoot.chance then
            return nil
        end
    end

    local amount = math.random(selectedLoot.min, selectedLoot.max)

    return {
        item = selectedLoot.item,
        amount = amount
    }
end

--- @param netId number
local robNPC = function (netId)
    local src = source

    if not src or src <= 0 then
        return
    end

    if not netId or netId <= 0 then
        return
    end

    if robbedNPCs[netId] then
        shared.showNotification(src, locale("npc-already-robbed"), "error")
        return
    end

    local victimPed = NetworkGetEntityFromNetworkId(netId)

    if not victimPed then
        errorPrint(("robNPC: victimPed is nil for netId %s"):format(netId), src)
        return
    end

    if DoesEntityExist(victimPed) then
        local health = GetEntityHealth(victimPed)

        if health <= 0 then
            errorPrint(("robNPC: victimPed is dead for netId %s"):format(netId), src)
            return
        end
    end

    local plyCoords = utils.getPlayerCoords(src)

    if not plyCoords then
        errorPrint("robNPC: failed to get player coords", src)
        return
    end

    local pedCoords = GetEntityCoords(victimPed)

    if not pedCoords then
        errorPrint(("robNPC: failed to get entity coords for victimPed netId %s"):format(netId), src)
        return
    end

    local dist = #(plyCoords - pedCoords)

    if dist > 6.0 then
        errorPrint(("robNPC: player too far from victimPed (dist: %.2f)"):format(dist), src)
        return
    end

    math.randomseed(os.nanotime())

    local roll = math.random(1, 100)

    if roll <= Server.CallPoliceChance then
        utils.AlertPolice(src, netId)
        return
    end

    local loot = getRandomLoot()

    if not loot then
        shared.showNotification(src, locale("empty-pockets"), "warning")
        return false
    end

    local canCarry = ox_inventory:CanCarryItem(src, loot.item, loot.amount)

    if not canCarry then
        shared.showNotification(src, locale("cant-carry-item"), "warning")
        return
    end

    local added =  ox_inventory:AddItem(src, loot.item, loot.amount)

    if not added then
        errorPrint(("robNPC: failed to add item %s x%d to player"):format(loot.item, loot.amount), src)
        return
    end

    robbedNPCs[netId] = true

    GlobalState.RobbedNPCs = robbedNPCs

    debugPrint(("robNPC: successfully gave %s x%d to player"):format(loot.item, loot.amount), src)
end

RegisterNetEvent("lnd-robberies/server/rob-npc", robNPC)