local PlayerLib = require("Objects.player")
PlaybookLib = require("Objects.playbook")

local team = {}

function team:create(name, abbrev, logo, conference, division, color, rosterData, desirability)
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
        playbook=PlaybookLib:createPlaybook(),
        cityDesirability=desirability
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
        if(teamObj.players[i].contract.length > 0) then
            sum = sum + teamObj.players[i].contract.value 
        end
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

function retirePlayers(teamObj)
    local i = #teamObj.players
    while i >= 1 do
        local player = teamObj.players[i]

        if(player.years >= 18) then
            table.remove(teamObj.players, i)
        end

        i = i - 1
    end
end

function adjustCap(teamObj)
    if(teamObj.draftPosition <= 8) then
        teamObj.cap = SALARY_CAP_LEVEL_1
    elseif(teamObj.draftPosition <= 14) then
        teamObj.cap = SALARY_CAP_LEVEL_2
    elseif(teamObj.draftPosition <= 22) then
        teamObj.cap = SALARY_CAP_LEVEL_3
    else -- Made Conference Finals or better
        teamObj.cap = SALARY_CAP_MAX
    end
end

function resignPlayers(teamObj)
    table.sort(teamObj.players, function (a, b)
        return calculateOverall(a) > calculateOverall(b)
    end)

    local cutPlayers = {}
    for i = 1, #teamObj.players do
        local player = teamObj.players[i]

        if(player.contract.length == 0) then
            local salary = calculateFairSalary(player)

            if(calculateCap(teamObj) + salary <= teamObj.cap) then
                player.contract.value = salary
                player.contract.length = 4
            else
                table.insert(cutPlayers, player)
            end
        end
    end

    for i = 1, #cutPlayers do
        table.insert(league.freeAgents, cutPlayers[i])
        table.remove(teamObj.players, indexOf(teamObj.players, cutPlayers[i]))
    end

    if(calculateCap(teamObj) > teamObj.cap) then
        local playerRatings = {}

        for i = 1, #teamObj.players do
            local player = teamObj.players[i]

            if(player.years ~= 0) then
                local fairSalary = calculateFairSalary(player)
                local salaryDiff = (fairSalary - player.contract.value) / player.contract.value -- The lower value the worse
                
                table.insert(playerRatings, {
                    player=player,
                    salaryDiff=salaryDiff,
                    fairSalary=fairSalary
                }) 
            end
        end

        table.sort(playerRatings, function (a, b)
            return a.salaryDiff < b.salaryDiff
        end)

        local i = 1
        while calculateCap(teamObj) > teamObj.cap do
            local player = playerRatings[i].player
            table.insert(league.freeAgents, player)
            table.remove(teamObj.players, indexOf(teamObj.players, player))
            i = i + 1
        end
    end

    if(#teamObj.players > 15) then
        local tmpPlayers = {}
        for j, player in ipairs(teamObj.players) do
            if(player.years ~= 0) then
                table.insert(tmpPlayers, player)
            end
        end

        table.sort(tmpPlayers, function(player1, player2)
            return calculateOverall(player1) < calculateOverall(player2)
        end)

        local i = 1
        while #teamObj.players > 15 do
            table.remove(teamObj.players, indexOf(teamObj.players, tmpPlayers[i]))
            i = i + 1
        end
    end
end

return team