SALARY_CAP_MAX = 200000000
SALARY_CAP_LEVEL_3 = 175000000
SALARY_CAP_LEVEL_2 = 150000000
SALARY_CAP_LEVEL_1 = 125000000

CONTRAC_MAX = 50000000
CONTRACT_MAX_LENGTH = 4

OFFENSE_FACTOR = .45
DEFENSE_FACTOR = .15
SKILL_LEVEL_FACTOR = .15
AGE_FACTOR = .25

local function findOffenseRanking(playerObj)
    local players = {}

    for j = 1, #league.teams do
        local team = league.teams[j]

        for i = 1, #team.players do
            local player = team.players[i]
            local stats = calculateFinalsStats(player, league.year - 1)
            local points = math.round(stats.points / games)
            local winPercent = math.round(team.wins * 100 / games)
    
            local twoPtPercent = 0
            if(stats.twoPA ~= 0) then
                twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
            end
            
            local threePtPercent = 0
            if(stats.threePA ~= 0) then
                threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
            end
    
            local ts = 0
            local eFG = 0
            if(stats.twoPA + stats.threePA ~= 0) then
                ts = math.round(stats.points * 100 / (2 * (stats.twoPA + stats.threePA)))
                eFG = math.round((stats.twoPM + .5 * stats.threePM) * 100 / (stats.twoPA + stats.threePA))
            end
    
            local plusMinus = math.round(stats.plusMinus / games)
    
            -- normalize each stat from 0-10
            local rating = (points * 1.5) + plusMinus + (winPercent / 20) + (twoPtPercent / 10) + (threePtPercent / 10) + (ts / 15) + (eFG / 15)
    
            local playerStats = {
                playerObj = player,
                name = player.name,
                winPercent = winPercent,
                pts = points,
                twoPtPercent = twoPtPercent,
                threePtPercent = threePtPercent,
                ts = ts,
                eFG = eFG,
                plusMinus = plusMinus,
                rating = rating
            }
    
            table.insert(players, playerStats)
            calculateFinalsStats(team.players[i], league.year)
        end
    end
    
    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

    for i = 1, #players do
        if players[i].playerObj == playerObj then
            return i / #players
        end
    end

    return 0
end

local function findDefenseRanking(playerObj)
    local players = {}

    for i = 1, #league.teams do
        local team = league.teams[i]
        local games = team.wins + team.losses

        if(games ~= 0) then
            for j = 1, #team.players do
                local player = team.players[j]
                local stats = calculateYearlyStats(player, league.year - 1)

                if(stats.shotsAgainst ~= 0) then
                    local winPercent = math.round(team.wins * 100 / games)
                    local points = math.round(stats.pointsAgainst / games)
                    local shots = math.round(stats.shotsAgainst / games)
                    local blocks = math.round(stats.blocks / games)
                    local steals = math.round(stats.steals / games)

                    local ptsPerShot = 0
                    if(shots ~= 0) then
                        ptsPerShot = tonumber(string.format("%.2f", (points / shots)))
                    end
                    
                    local ptsPerShotMin = ptsPerShot
                    if(ptsPerShotMin < .1) then
                        ptsPerShotMin = .1
                    end
                    -- normalize each stat from 0-10
                    local rating = (winPercent / 20) + (3 * shots / ptsPerShotMin) + (blocks * 3) + (steals * 3)
        
                    local playerStats = {
                        name = player.name,
                        winPercent = winPercent,
                        points = points,
                        shots = shots,
                        ptsPerShot = ptsPerShot,
                        blocks = blocks,
                        steals = steals,
                        rating = rating
                    }
        
                    table.insert(players, playerStats)
                end
            end
        end
    end

    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

    for i = 1, #players do
        if players[i].playerObj == playerObj then
            return i / #players
        end
    end

    return 0
end

function calculateFairSalary(player)
    local offenseRanking = findOffenseRanking(player)
    local defenseRanking = findDefenseRanking(player)
    local skillLevel = calculateOverall(player) / 10
    local age = player.age

    local offenseFactor = (offenseRanking - .5) * 2
    local defenseFactor = (defenseRanking - .5) * 2
    local skillFactor = skillLevel * 2
    local ageFactor = (15 - (age - 20)) / 15

    local percent = ((offenseFactor * OFFENSE_FACTOR) + (defenseFactor * DEFENSE_FACTOR) + (skillFactor * SKILL_LEVEL_FACTOR) +
        (ageFactor * AGE_FACTOR)) / 4
    
    if(percent < .02) then
        percent = .02
    end

    return math.floor(CONTRAC_MAX * percent)
end

function formatContractMoney(value)
    local str = "" .. value
    local tmp = ""

    for i = 0, string.len(str) - 1 do
        local j = string.len(str) - i

        if(i > 0 and i % 3 == 0) then
            tmp = tmp .. ","
        end

        tmp = tmp .. string.sub(str, j, j)
        i = i - 1
    end

    return string.reverse(tmp)
end