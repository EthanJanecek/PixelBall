PlayLib = require("Objects.play")

local playbook = {}

function playbook:createPlaybook()
    self.__index = self

    return setmetatable({
        plays={PlayLib:createIsoPlay()}
    }, self)
end

return playbook