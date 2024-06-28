term.clear()
term.setCursorPos(1,1)
term.write("BIOS loading")

do
    local h = fs.open("/rom/modules/main/cc/expect.lua", "r")
    local f, err = (_VERSION == "Lua 5.1" and loadstring or load)(h.readAll(), "/rom/modules/main/cc/expect.lua")
    h.close()

    if not f then error(err) end
    expect = f()
    field = expect.field
end


local function writeANSI(nativewrite)
    return function(str)
        local seq = nil
        local bold = false
        local lines = 0
        local function getnum(d)
            if seq == "[" then
                return d or 1
            elseif string.find(seq, ";") then
                return
                    tonumber(string.sub(seq, 2, string.find(seq, ";") - 1)),
                    tonumber(string.sub(seq, string.find(seq, ";") + 1))
            else
                return tonumber(string.sub(seq, 2))
            end
        end
        for c in string.gmatch(str, ".") do
            if seq == "\27" then
                if c == "c" then
                    term.setBackgroundColor(colors.black)
                    term.setTextColor(colors.white)
                    term.setCursorBlink(true)
                elseif c == "[" then
                    seq = "["
                else
                    seq = nil
                end
            elseif seq ~= nil and string.sub(seq, 1, 1) == "[" then
                if tonumber(c) ~= nil or c == ';' then
                    seq = seq .. c
                else
                    if c == "A" then
                        term.setCursorPos(term.getCursorPos(), select(2, term.getCursorPos()) - getnum())
                    elseif c == "B" then
                        term.setCursorPos(term.getCursorPos(), select(2, term.getCursorPos()) + getnum())
                    elseif c == "C" then
                        term.setCursorPos(term.getCursorPos() + getnum(), select(2, term.getCursorPos()))
                    elseif c == "D" then
                        term.setCursorPos(term.getCursorPos() - getnum(), select(2, term.getCursorPos()))
                    elseif c == "E" then
                        term.setCursorPos(1, select(2, term.getCursorPos()) + getnum())
                    elseif c == "F" then
                        term.setCursorPos(1, select(2, term.getCursorPos()) - getnum())
                    elseif c == "G" then
                        term.setCursorPos(getnum(), select(2, term.getCursorPos()))
                    elseif c == "H" then
                        term.setCursorPos(getnum())
                    elseif c == "J" then
                        term.clear()                      -- ?
                    elseif c == "K" then
                        term.clearLine()                  -- ?
                    elseif c == "T" then
                        term.scroll(getnum())
                    elseif c == "f" then
                        term.setCursorPos(getnum())
                    elseif c == "m" then
                        local n, m = getnum(0)
                        if n == 0 then
                            term.setBackgroundColor(colors.black)
                            term.setTextColor(colors.white)
                        elseif n == 1 then
                            bold = true
                        elseif n == 7 or n == 27 then
                            local bg = term.getBackgroundColor()
                            term.setBackgroundColor(term.getTextColor())
                            term.setTextColor(bg)
                        elseif n == 22 then
                            bold = false
                        elseif n >= 30 and n <= 37 then
                            term.setTextColor(2 ^ (15 - (n - 30) - (bold and 8 or 0)))
                        elseif n == 39 then
                            term.setTextColor(colors.white)
                        elseif n >= 40 and n <= 47 then
                            term.setBackgroundColor(2 ^ (15 - (n - 40) - (bold and 8 or 0)))
                        elseif n == 49 then
                            term.setBackgroundColor(colors.black)
                        elseif n >= 90 and n <= 97 then
                            term.setTextColor(2 ^ (15 - (n - 90) - 8))
                        elseif n >= 100 and n <= 107 then
                            term.setBackgroundColor(2 ^ (15 - (n - 100) - 8))
                        end
                        if m ~= nil then
                            if m == 0 then
                                term.setBackgroundColor(colors.black)
                                term.setTextColor(colors.white)
                            elseif m == 1 then
                                bold = true
                            elseif m == 7 or m == 27 then
                                local bg = term.getBackgroundColor()
                                term.setBackgroundColor(term.getTextColor())
                                term.setTextColor(bg)
                            elseif m == 22 then
                                bold = false
                            elseif m >= 30 and m <= 37 then
                                term.setTextColor(2 ^ (15 - (m - 30) - (bold and 8 or 0)))
                            elseif m == 39 then
                                term.setTextColor(colors.white)
                            elseif m >= 40 and m <= 47 then
                                term.setBackgroundColor(2 ^ (15 - (m - 40) - (bold and 8 or 0)))
                            elseif m == 49 then
                                term.setBackgroundColor(colors.black)
                            elseif n >= 90 and n <= 97 then
                                term.setTextColor(2 ^ (15 - (n - 90) - 8))
                            elseif n >= 100 and n <= 107 then
                                term.setBackgroundColor(2 ^ (15 - (n - 100) - 8))
                            end
                        end
                    elseif c == "z" then
                        local n, m = getnum(0)
                        if n == 0 then
                            term.setBackgroundColor(colors.black)
                            term.setTextColor(colors.white)
                        elseif n == 7 or n == 27 then
                            local bg = term.getBackgroundColor()
                            term.setBackgroundColor(term.getTextColor())
                            term.setTextColor(bg)
                        elseif n >= 25 and n <= 39 then
                            term.setTextColor(n - 25)
                        elseif n >= 40 and n <= 56 then
                            term.setBackgroundColor(n - 40)
                        end
                        if m ~= nil then
                            if m == 0 then
                                term.setBackgroundColor(colors.black)
                                term.setTextColor(colors.white)
                            elseif m == 7 or m == 27 then
                                local bg = term.getBackgroundColor()
                                term.setBackgroundColor(term.getTextColor())
                                term.setTextColor(bg)
                            elseif m >= 25 and m <= 39 then
                                term.setTextColor(m - 25)
                            elseif m >= 40 and m <= 56 then
                                term.setBackgroundColor(m - 40)
                            end
                        end
                    end
                    seq = nil
                end
            elseif c == string.char(0x1b) then
                seq = "\27"
            else
                lines = lines + (nativewrite(c) or 0)
            end
        end
        return lines
    end
end

local function intrnl_write(sText)
    expect.expect(1, sText, "string", "number")

    local w, h = term.getSize()
    local x, y = term.getCursorPos()

    local nLinesPrinted = 0
    local function newLine()
        if y + 1 <= h then
            term.setCursorPos(1, y + 1)
        else
            term.setCursorPos(1, h)
            term.scroll(1)
        end
        x, y = term.getCursorPos()
        nLinesPrinted = nLinesPrinted + 1
    end

    -- Print the line with proper word wrapping
    sText = tostring(sText)
    while #sText > 0 do
        local whitespace = string.match(sText, "^[ \t]+")
        if whitespace then
            -- Print whitespace
            term.write(whitespace)
            x, y = term.getCursorPos()
            sText = string.sub(sText, #whitespace + 1)
        end

        local newline = string.match(sText, "^\n")
        if newline then
            -- Print newlines
            newLine()
            sText = string.sub(sText, 2)
        end

        local text = string.match(sText, "^[^ \t\n]+")
        if text then
            sText = string.sub(sText, #text + 1)
            if #text > w then
                -- Print a multiline word
                while #text > 0 do
                    if x > w then
                        newLine()
                    end
                    term.write(text)
                    text = string.sub(text, w - x + 2)
                    x, y = term.getCursorPos()
                end
            else
                -- Print a word normally
                if x + #text - 1 > w then
                    newLine()
                end
                term.write(text)
                x, y = term.getCursorPos()
            end
        end
    end

    return nLinesPrinted
end

write = writeANSI(intrnl_write)



function print(...)
    local nLinesPrinted = 0
    local nLimit = select("#", ...)
    for n = 1, nLimit do
        local s = tostring(select(n, ...))
        if n < nLimit then
            s = s .. "\t"
        end
        nLinesPrinted = nLinesPrinted + write(s)
    end
    nLinesPrinted = nLinesPrinted + write("\n")
    return nLinesPrinted
end

function printError(...)
    local oldColour
    if term.isColour() then
        oldColour = term.getTextColour()
        term.setTextColour(colors.red)
    end
    print(...)
    if term.isColour() then
        term.setTextColour(oldColour)
    end
end

function printWarning(...)
    local oldColour
    if term.isColour() then
        oldColour = term.getTextColour()
        term.setTextColour(colors.yellow)
    end
    print(...)
    if term.isColour() then
        term.setTextColour(oldColour)
    end
end

function read(_sReplaceChar, _tHistory, _fnComplete, _sDefault)
    expect.expect(1, _sReplaceChar, "string", "nil")
    expect.expect(2, _tHistory, "table", "nil")
    expect.expect(3, _fnComplete, "function", "nil")
    expect.expect(4, _sDefault, "string", "nil")

    term.setCursorBlink(true)

    local sLine
    if type(_sDefault) == "string" then
        sLine = _sDefault
    else
        sLine = ""
    end
    local nHistoryPos
    local nPos, nScroll = #sLine, 0
    if _sReplaceChar then
        _sReplaceChar = string.sub(_sReplaceChar, 1, 1)
    end

    local tCompletions
    local nCompletion
    local function recomplete()
        if _fnComplete and nPos == #sLine then
            tCompletions = _fnComplete(sLine)
            if tCompletions and #tCompletions > 0 then
                nCompletion = 1
            else
                nCompletion = nil
            end
        else
            tCompletions = nil
            nCompletion = nil
        end
    end

    local function uncomplete()
        tCompletions = nil
        nCompletion = nil
    end

    local w = term.getSize()
    local sx = term.getCursorPos()

    local function redraw(_bClear)
        local cursor_pos = nPos - nScroll
        if sx + cursor_pos >= w then
            -- We've moved beyond the RHS, ensure we're on the edge.
            nScroll = sx + nPos - w
        elseif cursor_pos < 0 then
            -- We've moved beyond the LHS, ensure we're on the edge.
            nScroll = nPos
        end

        local _, cy = term.getCursorPos()
        term.setCursorPos(sx, cy)
        local sReplace = _bClear and " " or _sReplaceChar
        if sReplace then
            term.write(string.rep(sReplace, math.max(#sLine - nScroll, 0)))
        else
            term.write(string.sub(sLine, nScroll + 1))
        end

        if nCompletion then
            local sCompletion = tCompletions[nCompletion]
            local oldText, oldBg
            if not _bClear then
                oldText = term.getTextColor()
                oldBg = term.getBackgroundColor()
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.gray)
            end
            if sReplace then
                term.write(string.rep(sReplace, #sCompletion))
            else
                term.write(sCompletion)
            end
            if not _bClear then
                term.setTextColor(oldText)
                term.setBackgroundColor(oldBg)
            end
        end

        term.setCursorPos(sx + nPos - nScroll, cy)
    end

    local function clear()
        redraw(true)
    end

    recomplete()
    redraw()

    local function acceptCompletion()
        if nCompletion then
            -- Clear
            clear()

            -- Find the common prefix of all the other suggestions which start with the same letter as the current one
            local sCompletion = tCompletions[nCompletion]
            sLine = sLine .. sCompletion
            nPos = #sLine

            -- Redraw
            recomplete()
            redraw()
        end
    end
    while true do
        local sEvent, param, param1, param2 = os.pullEvent()
        if sEvent == "char" then
            -- Typed key
            clear()
            sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
            nPos = nPos + 1
            recomplete()
            redraw()
        elseif sEvent == "paste" then
            -- Pasted text
            clear()
            sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
            nPos = nPos + #param
            recomplete()
            redraw()
        elseif sEvent == "key" then
            if param == keys.enter or param == keys.numPadEnter then
                -- Enter/Numpad Enter
                if nCompletion then
                    clear()
                    uncomplete()
                    redraw()
                end
                break
            elseif param == keys.left then
                -- Left
                if nPos > 0 then
                    clear()
                    nPos = nPos - 1
                    recomplete()
                    redraw()
                end
            elseif param == keys.right then
                -- Right
                if nPos < #sLine then
                    -- Move right
                    clear()
                    nPos = nPos + 1
                    recomplete()
                    redraw()
                else
                    -- Accept autocomplete
                    acceptCompletion()
                end
            elseif param == keys.up or param == keys.down then
                -- Up or down
                if nCompletion then
                    -- Cycle completions
                    clear()
                    if param == keys.up then
                        nCompletion = nCompletion - 1
                        if nCompletion < 1 then
                            nCompletion = #tCompletions
                        end
                    elseif param == keys.down then
                        nCompletion = nCompletion + 1
                        if nCompletion > #tCompletions then
                            nCompletion = 1
                        end
                    end
                    redraw()
                elseif _tHistory then
                    -- Cycle history
                    clear()
                    if param == keys.up then
                        -- Up
                        if nHistoryPos == nil then
                            if #_tHistory > 0 then
                                nHistoryPos = #_tHistory
                            end
                        elseif nHistoryPos > 1 then
                            nHistoryPos = nHistoryPos - 1
                        end
                    else
                        -- Down
                        if nHistoryPos == #_tHistory then
                            nHistoryPos = nil
                        elseif nHistoryPos ~= nil then
                            nHistoryPos = nHistoryPos + 1
                        end
                    end
                    if nHistoryPos then
                        sLine = _tHistory[nHistoryPos]
                        nPos, nScroll = #sLine, 0
                    else
                        sLine = ""
                        nPos, nScroll = 0, 0
                    end
                    uncomplete()
                    redraw()
                end
            elseif param == keys.backspace then
                -- Backspace
                if nPos > 0 then
                    clear()
                    sLine = string.sub(sLine, 1, nPos - 1) .. string.sub(sLine, nPos + 1)
                    nPos = nPos - 1
                    if nScroll > 0 then nScroll = nScroll - 1 end
                    recomplete()
                    redraw()
                end
            elseif param == keys.home then
                -- Home
                if nPos > 0 then
                    clear()
                    nPos = 0
                    recomplete()
                    redraw()
                end
            elseif param == keys.delete then
                -- Delete
                if nPos < #sLine then
                    clear()
                    sLine = string.sub(sLine, 1, nPos) .. string.sub(sLine, nPos + 2)
                    recomplete()
                    redraw()
                end
            elseif param == keys["end"] then
                -- End
                if nPos < #sLine then
                    clear()
                    nPos = #sLine
                    recomplete()
                    redraw()
                end
            elseif param == keys.tab then
                -- Tab (accept autocomplete)
                acceptCompletion()
            end
        elseif sEvent == "mouse_click" or sEvent == "mouse_drag" and param == 1 then
            local _, cy = term.getCursorPos()
            if param1 >= sx and param1 <= w and param2 == cy then
                -- Ensure we don't scroll beyond the current line
                nPos = math.min(math.max(nScroll + param1 - sx, 0), #sLine)
                redraw()
            end
        elseif sEvent == "term_resize" then
            -- Terminal resized
            w = term.getSize()
            redraw()
        end
    end

    local _, cy = term.getCursorPos()
    term.setCursorBlink(false)
    term.setCursorPos(w + 1, cy)
    print()

    return sLine
end

function panic(ae)
    term.setBackgroundColor(32768)
    term.setTextColor(16384)
    term.setCursorBlink(false)
    local p, q = term.getCursorPos()
    p = 1
    local af, ag = term.getSize()
    ae = "panic: " .. (ae or "unknown")
    for ah in ae:gmatch "%S+" do
        if p + #ah >= af then
            p, q = 1, q + 1
            if q > ag then
                term.scroll(1)
                q = q - 1
            end
        end
        term.setCursorPos(p, q)
        if p == 1 then term.clearLine() end
        term.write(ah .. " ")
        p = p + #ah + 1
    end
    p, q = 1, q + 1
    if q > ag then
        term.scroll(1)
        q = q - 1
    end
    if debug then
        local ai = debug.traceback(nil, 2)
        for aj in ai:gmatch "[^\n]+" do
            term.setCursorPos(1, q)
            term.write(aj)
            q = q + 1
            if q > ag then
                term.scroll(1)
                q = q - 1
            end
        end
    end
    term.setCursorPos(1, q)
    term.setTextColor(2)
    term.write("panic: We are hanging here...")
    mainThread = nil
    while true do coroutine.yield() end
end

print("")

function loadfile(filename, mode, env)
    -- Support the previous `loadfile(filename, env)` form instead.
    if type(mode) == "table" and env == nil then
        mode, env = nil, mode
    end


    local file = fs.open(filename, "r")
    if not file then return nil, "File not found" end

    local func, err = load(file.readAll(), "@/" .. fs.combine(filename), mode, env)
    file.close()
    return func, err
end

function dofile(_sFile)

    local fnFile, e = loadfile(_sFile, nil, _G)
    if fnFile then
        return fnFile()
    else
        error(e, 2)
    end
end
local tAPIsLoading = {}
---pulls event
---@param sFilter any
---@return any
function os.pullEventRaw(sFilter)
    return coroutine.yield(sFilter)
end

---pulls events, terminates on terminate event
---@param sFilter any
---@return unknown
function os.pullEvent(sFilter)
    local eventData = table.pack(os.pullEventRaw(sFilter))
    if eventData[1] == "terminate" then
        error("Terminated", 0)
    end
    return table.unpack(eventData, 1, eventData.n)
end

---os.pullEvent but no terminate
---@param sFilter any
---@return unknown
function os.pullEventFilter(sFilter)
    local eventData = table.pack(os.pullEventRaw(sFilter))
    if eventData[1] == "terminate" then
        return
    end
    return table.unpack(eventData, 1, eventData.n)
end

---Loads an api into _G
---@deprecated
---@param _sPath string
---@return boolean
local function loadAPI(_sPath)
    expect(1, _sPath, "string")
    local sName = fs.getName(_sPath)
    if sName:sub(-4) == ".lua" then
        sName = sName:sub(1, -5)
    end
    if tAPIsLoading[sName] == true then
        printError("API " .. sName .. " is already being loaded")
        return false
    end
    tAPIsLoading[sName] = true

    local tEnv = {}
    setmetatable(tEnv, { __index = _G })
    local fnAPI, err = loadfile(_sPath, nil, tEnv)
    if fnAPI then
        local ok, err = pcall(fnAPI)
        if not ok then
            tAPIsLoading[sName] = nil
            return error("Failed to load API " .. sName .. " due to " .. err, 1)
        end
    else
        tAPIsLoading[sName] = nil
        return error("Failed to load API " .. sName .. " due to " .. err, 1)
    end

    local tAPI = {}
    for k, v in pairs(tEnv) do
        if k ~= "_ENV" then
            tAPI[k] =  v
        end
    end

    _G[sName] = tAPI
    tAPIsLoading[sName] = nil
    return true
end

local function unloadAPI(_sName)
    expect(1, _sName, "string")
    if _sName ~= "_G" and type(_G[_sName]) == "table" then
        _G[_sName] = nil
    end
end

loadAPI("/rom/apis/colors.lua")
loadAPI("/rom/apis/term.lua")
loadAPI("/rom/apis/keys.lua")
loadAPI("/rom/apis/fs.lua")

dofile("sys/boot/load/bootstrap.lua")
xpcall(function()
    dofile("sys/boot/kern/bin/kernel.lua")
end,panic)


term.setCursorBlink(true)
print("")
while true do coroutine.yield() end