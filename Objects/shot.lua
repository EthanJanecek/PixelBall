local shot = {}

function shot:createShot(x, y, made)
    self.__index = self

    return setmetatable({
        x=x,
        y=y,
        made=made
    }, self)
end

return shot