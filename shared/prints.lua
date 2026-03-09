local colors = {
    error = "^8",
    warn  = "^1",
    info  = "^4",
    debug = "^3"
}

local function Log(level, msg, src)
    if not level or not msg then
        return
    end

    if level == "debug" and not Config.Debug then
        return
    end

    local prefix = colors[level] or "^7"
    local sourceInfo = src and (" by [ID: %s]"):format(src) or ""

    print(("%s[%s]%s %s^7"):format(
        prefix,
        level,
        sourceInfo,
        msg
    ))
end

function errorPrint(msg, src)
    Log("error", msg, src)
end

function infoPrint(msg, src)
    Log("info", msg, src)
end

function debugPrint(msg, src)
    Log("debug", msg, src)
end

function warnPrint(msg, src)
    Log("warn", msg, src)
end
