-- Force to include randomkit once only, relying on the global state
-- NB: it is ugly to rely on the fact that we pollute the global
-- namespace, yet I do not see a better way to avoid 
-- including ourselves twice -- which would cause seed problems.
--
-- This will need deeper consideration once we will return only
-- a local table, and once we will want proper multi-thread
-- support. In particular, we will have to modify the interfacing
-- with torch.[gs]etRNGState in wrapC.lua.
--
-- But for now (November 2013), this is good enough.
if rawget(_G, "randomkit") then
    return randomkit
end

randomkit = {}

function randomkit._isTensor(v)
    if torch.typename(v) then
        return string.sub(torch.typename(v), -6, -1) == "Tensor"
    end
end

--[[! Argument checking for vectorized calls

Process the optional return storage, the sizes of the parameter functions, etc

@param K number of actual parameters for the sampler
@param defaultResultType Tensor class corresponding to the expected result type (e.g. torch.DoubleTensor, torch.IntegerTensor, etc)
@param ... List of all parameters passed to the original caller

@return T vector or 1-d tensor to store the result into, N rows (or nil, if we should return a single value)
@return p1 ... pk Tensor of parameters, all N rows
--]]
function randomkit._check1DParams(K, defaultResultType, ...)
    local argCount = select("#", ...)
    for index = 1,argCount do
        if select(index, ...) == nil then
            error("Bad randomkit call - argument " .. index .. " is nil when calling function bytes()!")
        end
    end
    local params = { ... }
    if #params ~= K and #params ~= K+1 then
        error('CHKPARAMS: need ' .. K .. ' arguments and optionally, one result tensor, instead got ' .. #params .. ' arguments')
    end

    local result
    local Nresult = nil -- Default: unknown result size
    if #params == K then
        local numberOnly = true
        for paramIndex, param in ipairs(params) do
            numberOnly = numberOnly and not randomkit._isTensor(param)
        end
        if numberOnly then
            return nil, params
        else
            result = defaultResultType.new(1)
        end
    else
        if randomkit._isTensor(params[1]) then
            -- The tensor dictates the size of the result
            result = params[1]
            Nresult = result:nElement()
        else
            error("Invalid type " .. type(params[1]) .. " for result")
        end
        table.remove(params, 1)
    end

    -- Ensure that all parameters agree in size
    local Nparams = 1
    for paramIndex, param in ipairs(params) do
        local size
        if randomkit._isTensor(param) then
            size = param:nElement()
        elseif type(param) == 'number' or type(param) == 'cdata' then
            size = 1
            -- Use torch's default Tensor for parameters
            params[paramIndex] = torch.Tensor{ param }
        else
            error("Invalid type " .. type(param) .. " for parameter " .. paramIndex .. ".")
        end

        if not (size == 1 or Nparams == 1 or Nparams == size) then
            error("Incoherent sizes for parameters")
        elseif size > 1 and Nparams == 1 then
            Nparams = size
        end
    end

    if Nresult then
        -- If the result size was fixed by the caller (either via tensor or integer)
        if Nparams == 1 then
            -- If only size-1 parameters, Nresult dictates the output size
            Nparams = Nresult
        else
            -- However, if the parameters dictate one size and the result another, error
            assert(Nparams == Nresult,  "Parameter size (" .. Nparams ..") does not match result size (" .. Nresult ..")" )
        end
    else
        -- If the result size was not fixed by the caller, parameters dictate it
        Nresult = Nparams
        result:resize(Nresult)
    end

    for paramIndex, param in ipairs(params) do
        if param:size(1) == 1 then
            local sizes = param:size()
            sizes[1] = Nparams
            params[paramIndex] = params[paramIndex]:expand(sizes)
        end
    end

    return result, params
end

torch.include("randomkit", "nonC.lua")
torch.include("randomkit", "wrapC.lua")

local aliases = {
    random_sample = 'double',
    standard_normal = 'gauss'
}

for k, v in pairs(aliases) do
    rawset(randomkit, k, randomkit[v])
end

return randomkit

