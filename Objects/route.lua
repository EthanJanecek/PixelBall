local route = {}

function route:createRoute(startX, startY, position)
    self.__index = self

    local points = {}
    table.insert(points, {x=startX, y=startY})
    return setmetatable({
        position=position, points=points
    }, self)
end

function route:createRouteByPoints(points, position)
    self.__index = self

    return setmetatable({
        position=position, points=points
    }, self)
end

return route