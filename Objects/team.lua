local PlayerLib = require("Objects.player")
PlaybookLib = require("Objects.playbook")

local team = {}

function team:create(name, abbrev, logo, conference, division, color, rosterData)
    self.__index = self

    return setmetatable({
        name=name,
        abbrev=abbrev,
        players=createRoster(rosterData),
        wins=0,
        losses=0,
        starters={},
        logo=logo,
        conf=conference,
        division=division,
        color=color,
        playbook=PlaybookLib:createPlaybook()
    }, self)
end

function rows(connection, sql_stmt)
    local cursor = assert(connection:execute(sql_stmt))
    return function() 
        return cursor:fetch()
    end
end

function createRandomPlayers()
    local players = {}
    for i = 1, 11 do
        table.insert(players, PlayerLib:createRandom())
    end
    
    return players
end

function createRoster(file)
    local players = {}
    local i = 0

    for line in io.lines("C:/Users/Ethan Janecek/Documents/Coding Projects/Corona Projects/PixelBall/" .. file) do
        if i ~= 0 then
            local params = {}
            
            for param in string.gmatch(line, "([^,]+)") do
                table.insert(params, param)
            end

            table.insert(players, PlayerLib:createPlayer(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9], 10, params[10]))
        end

        i = i + 1
    end

    return players
end

return team