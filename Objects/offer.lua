local offer = {}

function offer:createOffer(team, player, salary, length)
    self.__index = self

    return setmetatable({
        team=team,
        player=player,
        salary=salary,
        length=length
    }, self)
end

return offer