local league = {}

function league:createLeague()
    self.__index = self

    return setmetatable({
        teams=createTeams(),
        gameNum=1,
    }, self)
end

return route