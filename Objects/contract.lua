local contract = {}

function contract:createContract(value, length)
    self.__index = self

    return setmetatable({
        value=value,
        length=length
    }, self)
end

return contract