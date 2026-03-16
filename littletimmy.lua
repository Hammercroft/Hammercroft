--shebang reserved here
-- littletimmy.lua ; Lua 5.1; by Hammercroft

-------------------------------------------------------------------------------
-- Stack Utilities
-------------------------------------------------------------------------------

-- Function to push an item onto the stack
local function push(t, item)
    table.insert(t, item)
end

-- Function to pop an item from the stack
local function pop(t)
    return table.remove(t)
end

-------------------------------------------------------------------------------
-- Module Definition
-------------------------------------------------------------------------------

littleTimmy = {}
littleTimmy.interpreterSwitch = {}

--- Does a step of interpreting from a Little Timmy page at the specified index.
function littleTimmy.interpretStep(arg_execution_context, arg_page, arg_index) 
    local instruction = arg_page[arg_index]
    local func = littleTimmy.interpreterSwitch[instruction]
    
    if not func then
        return arg_index, {error = "Unknown instruction: " .. tostring(instruction)}
    end

    local errorHandler = function(err)
        return "Runtime error at index " .. arg_index .. " [" .. tostring(instruction) .. "]: " .. err
    end

    -- xpcall returns: status (bool), followed by the function's return values OR the error message
    local status, next_index = xpcall(function() 
        return func(arg_execution_context, arg_page, arg_index) 
    end, errorHandler)

    if status then
        return next_index + 1, {success = true}
    else
        -- On error, we return the same index and the error info to let the host handle the break
        return arg_index, {error = next_index}
    end
end

-------------------------------------------------------------------------------
-- Instruction Set (Interpreter Switch)
-------------------------------------------------------------------------------

littleTimmy.interpreterSwitch["push"] = function(arg_execution_context, arg_page, arg_index)
    push(arg_execution_context.stack, arg_page[arg_index+1])
    return arg_index + 1 -- skip one page word
end

littleTimmy.interpreterSwitch["cout"] = function(arg_execution_context, arg_page, arg_index)
    local str = ""
    local stack = arg_execution_context.stack
    local boundary = arg_execution_context.stackBoundaryStack[#arg_execution_context.stackBoundaryStack] or 0

    -- Pop items until we hit the boundary or the stack is empty
    while #stack > boundary do
        local v = pop(stack)
        str = tostring(v) .. "\t" .. str -- Building string in reverse since we're popping
    end
    
    print(str)
    return arg_index
end

if table.freeze then
    table.freeze(littleTimmy)
end
-- return littleTimmy

------------------------------------------------------------------------------------------------------

local context = {
    ["stack"] = {},
    ["expectedCapabilities"] = {"cout","cin"}, -- used for checks, so that hosts with missing capabilities can refuse execution
    ["stackBoundaryStack"] = {0},
    ["stackBoundaryNameStack"] = {"<Entry Point>"}
}

local page = {
    --[[
        print("Hello World!, 1, "That was a number!")
    ]]
    "push", "Hello, World!",
    "push", 1,
    "push", "That was a number!",
    "cout",
    
    "push", 5, "skip",              --3
    "", "", "", "", "",             --5
    "push", "Skipped some stuff.",  --2
    "cout"                          --1
}

local currentIdx = 1
local pageSize = #page 

while currentIdx <= pageSize do
    local stepResult
    currentIdx, stepResult = littleTimmy.interpretStep(context, page, currentIdx)
    
    if stepResult.error then
        print("INTERPRETER HALTED: " .. stepResult.error)
        break
    end
end

print("ta-da")
