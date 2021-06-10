local PlayerLib = require("Objects.player")

local team = {}

function team:create(name, logo, conference, division, color)
    self.__index = self

    return setmetatable({
        name=name,
        players=createRandomPlayers(),
        wins=0,
        losses=0,
        starters={},
        logo=logo,
        conf=conference,
        schedule={},
        division=division,
        color=color
    }, self)
end

function createRandomPlayers()
    local players = {}
    for i = 1, 11 do
        table.insert(players, PlayerLib:createRandom())
    end

    return players
end

return team