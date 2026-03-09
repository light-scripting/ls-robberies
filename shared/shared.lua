lib.locale()

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
    showNotification = showNotification
}
