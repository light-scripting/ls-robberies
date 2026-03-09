lib.locale()

local serverData = nil

--- @ return table|nil
local getServerData = function()
    if not serverData or type(serverData) ~= "table" or next(serverData) == nil then
        return nil
    end

    return serverData
end

--- @param newData table
--- @ return boolean
local setServerData = function(newData)
    if type(newData) ~= "table" then
        return false
    end

    serverData = newData

    return true
end

--- @param src number|nil
--- @param msg string
--- @param notifType string
--- @return boolean
local showNotification = function(src, msg, notifType)
    if not msg then
        return false
    end

    notifType = notifType or "inform"

    if src then
        TriggerClientEvent("esx:showNotification", src, msg, notifType)
        return true
    else
        ESX.ShowNotification(msg, notifType)
        return true
    end
end

return {
    getServerData = getServerData,
    setServerData = setServerData,
    showNotification = showNotification
}
