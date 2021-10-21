RouteLib = require("Objects.route")
local play = {}

function play:createPlay(routes, name)
    self.__index = self

    return setmetatable({
        routes=routes,
        name=name,
    }, self)
end

function play:createIsoPlay()
    self.__index = self

    local routes = {}
    for i = 1, 5 do
        local startPositions = startPositionsOffense[i]
        local route = RouteLib:createRoute(startPositions.x, startPositions.y, i)
        table.insert(routes, route)
    end

    return setmetatable({
        routes=routes,
        name="iso",
    }, self)
end

return play