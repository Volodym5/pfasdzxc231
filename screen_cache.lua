-- Phantom Forces - Shared Screen-Space Cache
-- One WorldToViewportPoint call per model per frame, shared across systems

local Camera = workspace.CurrentCamera

local ScreenCache = {}
local cache = {}

function ScreenCache.Rebuild(activeModels, headPositions)
    table.clear(cache)
    for model, headPos in pairs(headPositions) do
        if activeModels[model] then
            local sp, onScreen = Camera:WorldToViewportPoint(headPos)
            cache[model] = {
                x = sp.X,
                y = sp.Y,
                z = sp.Z,
                onScreen = onScreen,
                worldPos = headPos
            }
        end
    end
end

function ScreenCache.Get(model)
    return cache[model]
end

function ScreenCache.Has(model)
    return cache[model] ~= nil
end

function ScreenCache.GetAll()
    return cache
end

return ScreenCache
