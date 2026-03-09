local shared = require("shared.shared")

local ox_target = exports.ox_target

--- @param victimPed number
--- @param netId number
local startRobbing = function (victimPed, netId)
    local plyPed = cache.ped

    if not plyPed then
        errorPrint("startRobbing: Player ped not found")
        return
    end

    local isRobbing = true

    Citizen.CreateThread(function()
        while isRobbing do
            local victimCoords = GetEntityCoords(victimPed)

            TaskFollowNavMeshToCoord(
                plyPed,
                victimCoords.x, victimCoords.y, victimCoords.z,
                2.0,
                -1,
                1.0,
                1024,
                0.0
            )

            Wait(100)
        end

        ClearPedTasks(plyPed)
    end)

    if lib.skillCheckActive() then
        lib.cancelSkillCheck()
    end

    local success = lib.skillCheck(Config.SkillChecks.sequence, Config.SkillChecks.inputs)

    isRobbing = false

    if not success then
        shared.showNotification(nil, locale("robbery-failed"), "error")
        return
    end

    TriggerServerEvent("lnd-robberies/server/rob-npc", netId)
end

--- @param entity number
--- @ return boolean canBeRobbed
local canRobPed = function (entity)
    local plyPed = cache.ped

    if not plyPed then
        errorPrint("canRobPed: Player ped not found")
        return false
    end

    local netId = NetworkGetNetworkIdFromEntity(entity)

    if not netId then
        errorPrint("canRobPed: netId is nil for entity")
        return false
    end

    if GetPedType(entity) == 28 or IsPedFleeing(entity) or IsPedAPlayer(entity) or IsPedInAnyVehicle(entity, false) or IsPedDeadOrDying(entity, true) then
        return false
    end

    if IsPedInCombat(entity, plyPed) or IsEntityAMissionEntity(entity) or IsPedRunningRagdollTask(entity) then
        return false
    end

    if GlobalState.RobbedNPCs[netId] then
        return false
    end

    return true
end

--- @ return boolean created
local createRobTarget = function ()
    if not ox_target then
        errorPrint("createRobTarget: ox_target is not available")
        return false
    end

    ox_target:addGlobalPed({
        name = "rob-npc",
        icon = "people-robbery",
        label = locale("rob-npc"),
        distance = 3.0,
        canInteract = function (entity)
            return canRobPed(entity)
        end,
        onSelect = function (data)
            local victimPed = data?.entity

            if not victimPed then
                errorPrint("onSelect: robbedPed is nil")
                return
            end

            local netId = NetworkGetNetworkIdFromEntity(victimPed)

            if not netId then
                errorPrint("onSelect: netId is nil for victimPed")
                return
            end

            startRobbing(victimPed, netId)
       end
    })

    debugPrint("createRobTarget: ox_target global ped created")

    return true
end

CreateThread(createRobTarget)