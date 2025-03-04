-- <-- Raz's CLVM [Custom Lua Virtual Machine] -->

--[[
  File: luaLSource.lua
  Description: The source of the CLVM
  Author: RazAPI [razonili]

  You are not allowed to fork, or redistrubute this without permission from the owner of this repository,
  You are allowed to use this project only if you credit the original author.
--]]

local luaL = {}
local CLVM = {}
CLVM.__index = CLVM -- <-- Load __index table for :: parameters.
luaL.__index = luaL

function luaL.getglobal<R>(LF, t: any): R
    if not LF == LS then
        error("Failed to get global: First argument must be LuaState (LS)")
    end
    
    return t
end

function luaL.findglobal<G>(global: any): G
    return luaL[global]
end

function luaL.getclvmglobal<C>(G: any): C
    return CLVM[G]
end

function CLVM.GetScriptSource(src: Instance)
    if src:IsA("LocalScript") and src:IsA("ModuleScript") and src:IsA("LuaScriptContainer") then
        return src.Source
    else
        warn("[CLVM]: Failed to get script bytecode of Instance: "..src.ClassName)
  end
end

function CLVM.new(customEnv)
    local self = setmetatable({}, CLVM)
    
  self.env = {
        math = {
            abs = math.abs,
            acos = math.acos,
            asin = math.asin,
            atan = math.atan,
            atan2 = math.atan2,
            ceil = math.ceil,
            cos = math.cos,
            deg = math.deg,
            exp = math.exp,
            floor = math.floor,
            fmod = math.fmod,
            log = math.log,
            max = math.max,
            min = math.min,
            pi = math.pi,
            rad = math.rad,
            random = math.random,
            randomseed = math.randomseed,
            sin = math.sin,
            sqrt = math.sqrt,
            tan = math.tan,
            huge = math.huge
        },

        string = {
            byte = string.byte,
            char = string.char,
            find = string.find,
            format = string.format,
            gmatch = string.gmatch,
            gsub = string.gsub,
            len = string.len,
            lower = string.lower,
            match = string.match,
            rep = string.rep,
            reverse = string.reverse,
            sub = string.sub,
            upper = string.upper
        },
        
        table = {
            concat = table.concat,
            insert = table.insert,
            remove = table.remove,
            sort = table.sort,
            create = table.create,
            clear = table.clear,
            find = table.find,
            keys = table.keys,
            move = table.move,
            clone = table.clone
        },
        
        tonumber = tonumber,
        tostring = tostring,
        pcall = pcall,
        xpcall = xpcall,
        typeof = typeof,
        getmetatable = getmetatable,
        setmetatable = setmetatable,
        getfenv = getfenv,
        setfenv = setfenv,
        type = type,
        select = select,
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        print = print,
        warn = warn,
        error = error,
        
        _G = {},
        _VERSION = "CLVM v1.0",
    }
    
    if customEnv then
        for k, v in pairs(customEnv) do
            if type(self.env[k]) == "table" and type(v) == "table" then -- ??
                for k2, v2 in pairs(v) do 
                    self.env[k][k2] = v2 -- 21656
                end
            else
                self.env[k] = v -- 65333
            end
        end
    end
    
    self.output = {}
    self.error = nil
    
    return self
end



function CLVM:execute<C>(code: string): C
    local CLVM_PCALL, CLVM_LOAD = pcall(function() loadstring(code, "CLVM")(); end)
    if not debug.getmemorycategory() == "CLVM" then
        debug.setmemorycategory("CLVM")
    end

    if not CLVM_PCALL then
        return
    end

    return CLVM_LOAD
end

function CLVM:RunOnThread<T>(code: string): T
    return task.spawn(function()
        loadstring(code, "CLVM_Thread")()
    end)
end



function CLVM:GetOutput()
    return table.concat(self.output, "\n")
end

function CLVM:EmptyCharacter() -- no one's using this
    return "\0" -- 4080 [1]
end

function CLVM:GetError()
    -- in special cases:
    return tostring(self.error) and tonumber(self.error)
end

function CLVM:AddFunction(name, value)
    self.env[name] = value
    return self
end

function CLVM:RemoveFromEnvironment(name)
    self.env[name] = nil
    return self
end

function CLVM:IsInEnvironment(name)
    return self.env[name] ~= nil
end

function CLVM:CreateBuffer(size)
    local buffer = {}
    buffer.size = size
    buffer.data = {}
    
    function buffer:write(position, value)
        if position < 1 or position > self.size then
            error("Position out of bounds")
        end
        
        self.data[position] = value
        return self.data[position]
    end
    
    function buffer:read(position)
        if position < 1 or position > self.size then
            error("Position out of bounds")
        end
        
        return self.data[position]
    end
    
    return buffer
end





function CLVM:SaveInstances(typeofinstance)
    warn("[CLVM]: Attempting to save instances...")
    task.wait(3)
    local count = 0
    local localscriptcount = 0
    local modulescriptcount = 0
    local instances = {}
    for _, v in pairs(game:GetDescendants()) do
        count = count + 1
        table.insert(instances, v)
    end
    local logcontent = ""
    local parentSections = {}
    if typeofinstance == "LocalScript" then
        for _, instance in ipairs(instances) do
            local parentname = tostring(instance.Parent)
            if parentname == "Ugc" then
                parentname = "game"
            end
            if instance:IsA("LocalScripts") then
                localscriptcount = localscriptcount + 1
                if not parentSections[parentname] then
                    parentSections[parentname] = {}
                end
                table.insert(parentSections[parentname], instance)
            end
        end
        logcontent = "<-- Instance Saver by RazAPI -->\n\nInstances saved in "..task.wait().."s\n\nAmount of LocalScripts saved: " .. localscriptcount .. "\n\n"
        for parentName, scripts in pairs(parentSections) do
            logcontent = logcontent .. "\n<--- " .. parentName .. " --->\n"
            for _, script in ipairs(scripts) do
                logcontent = logcontent .. script.ClassName .. " | " .. script.Name .. "\n" .. script.Source .. "\n"
            end
        end
    elseif typeofinstance == "ModuleScripts" then
        for _, instance in ipairs(instances) do
            local parentname = tostring(instance.Parent)
            if parentname == "Ugc" then
                parentname = "game"
            end
            if instance:IsA("ModuleScript") then
                modulescriptcount = modulescriptcount + 1
                if not parentSections[parentname] then
                    parentSections[parentname] = {}
                end
                table.insert(parentSections[parentname], instance)
            end
        end
        logcontent = "<-- Instance Saver by RazAPI -->\n\nInstances saved in "..task.wait().."s\n\nAmount of ModuleScripts saved: " .. modulescriptcount .. "\n\n"
        for parentName, scripts in pairs(parentSections) do
            logcontent = logcontent .. "\n<--- " .. parentName .. " --->\n"
            for _, script in ipairs(scripts) do
                logcontent = logcontent .. script.ClassName .. " | " .. script.Name .. "\n" .. script.Source .. "\n"
            end
        end
    else
        for _, instance in ipairs(instances) do
            local parentname = tostring(instance.Parent)
            if parentname == "Ugc" then
                parentname = "game"
            end
            logcontent = logcontent .. parentname .. " : " .. instance.Name .. "\n"
        end
        logcontent = "<-- Instance Saver by RazAPI -->\n\nInstances saved in "..task.wait().."s\nAmount of instances saved: " .. count .. "\n\n" .. logcontent
    end
    writefile("Saved Instances [CLVM].txt", logcontent)
    warn("[RazAPI's Instance Saver]: Successfully saved " ..count.. " instances.")
end

function CLVM:ClearOutput()
    self.output = {}
    return self
end
