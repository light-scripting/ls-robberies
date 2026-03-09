--- @param src number
--- @param victimNetId number
local AlertPolice = function (src, victimNetId)
    return shared.showNotification(src, locale("npc-calling-police"), "warning")
end

--- @param src number
--- @ return vector3|boolean
local getPlayerCoords = function(src)
    local plyPed = GetPlayerPed(src)

    if not plyPed or plyPed <= 0 then
        return false
    end

    local coords = GetEntityCoords(plyPed)
    return vec3(coords.x, coords.y, coords.z)
end

--- @param src number
--- @param msg string
--- @return boolean
local sendDiscordLog = function(src, msg)
    if type(src) ~= "number" or src <= 0 then
        return false
    end

    if not msg or type(msg) ~= "string" then
        return false
    end

    local webhook = Server.DiscordWebhook

    if not webhook or webhook == "" then
        return false
    end

    local payload = {
        username = "Robberies Logs",
        embeds = { {
            title = "Player Log",
            description = msg,
            color = 16711680,
            fields = {
                { name = "Player ID", value = tostring(src), inline = true }
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        } }
    }

    PerformHttpRequest(webhook, function(err, text, headers)
        if err ~= 204 then
            errorPrint(("discord log error: %s"):format(err))
        end
    end, "POST", json.encode(payload), { ["Content-Type"] = "application/json" })

    return true
end

return {
    sendDiscordLog = sendDiscordLog,
    getPlayerCoords = getPlayerCoords,
    AlertPolice = AlertPolice
}
