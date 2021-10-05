RouteLib = require("Objects.route")
local defense = {}

function defense:createPlay(routes)
    self.__index = self

    return setmetatable({
        routes=routes,
        name="",
        coverage="man",
        coverPositions={1, 2, 3, 4, 5}
    }, self)
end

function defense:createDefensePlay()
    self.__index = self

    local routes = {}
    for i = 1, 5 do
        local startPositions = startPositionsDefense[i]
        local route = RouteLib:createRoute(startPositions.x, startPositions.y, i)
        table.insert(routes, route)
    end

    return setmetatable({
        routes=routes,
        name="standard",
        coverage="man",
        coverPositions={1, 2, 3, 4, 5}
    }, self)
end

return defense