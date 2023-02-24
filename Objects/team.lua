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
        logo=logo,
        conf=conference,
        division=division,
        color=color,
        cap=SALARY_CAP_LEVEL_1,
        draftPosition=-1,
        playbook=PlaybookLib:createPlaybook()
    }, self)
end

function rows(connection, sql_stmt)
    local cursor = assert(connection:execute(sql_stmt))
    return function() 
        return cursor:fetch()
    end
end

function calculateCap(teamObj)
    local sum = 0

    for i = 1, #teamObj.players do
        sum = sum + teamObj.players[i].contract.value
    end

    return sum
end

function createRoster(file)
    local players = {}
    local i = 1
    local path = system.pathForFile( file, system.ResourceDirectory )
    for line in io.lines(path) do
        local params = {}
        
        for param in string.gmatch(line, "([^,]+)") do
            table.insert(params, param)
        end

        table.insert(players, PlayerLib:createPlayer(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], 
                params[9], params[10], params[11], params[12], params[13], params[14], params[15], params[16], params[17], params[18], 
                params[19], params[20], params[21], params[22], params[23], (i <= 5)))

        i = i + 1
    end

    return players
end

return team