SALARY_CAP_MAX = 200000000
SALARY_CAP_LEVEL_3 = 175000000
SALARY_CAP_LEVEL_2 = 150000000
SALARY_CAP_LEVEL_1 = 125000000

CONTRACT_MAX = 50000000
CONTRACT_MAX_LENGTH = 4

OFFENSE_FACTOR = .4
DEFENSE_FACTOR = .25
SKILL_LEVEL_FACTOR = .2
AGE_FACTOR = .15

BAD_CITY = .7
MID_CITY = .9
GOOD_CITY = 1.1
GREAT_CITY = 1.3

PLAYER_AGING_START = 15
PLAYER_MAX_AGE = 18

MIN_SHOT_ATTEMPTS = 25

local function findOffenseRanking(playerObj)
    local playerStats = calculateYearlyStats(playerObj, league.year - 1)

    if(playerStats.twoPA + playerStats.threePA == 0) then
        return 0
    end

    local players = {}

    for j = 1, #league.teams do
        local team = league.teams[j]

        for i = 1, #team.players do
            local player = team.players[i]
            local stats = calculateYearlyStats(player, league.year - 1)

            if(stats.twoPA + stats.threePA >= MIN_SHOT_ATTEMPTS) then
                local points = math.round(stats.points)
    
                local twoPtPercent = 0
                if(stats.twoPA ~= 0) then
                    twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
                end
                
                local threePtPercent = 0
                if(stats.threePA ~= 0) then
                    threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
                end
        
                local plusMinus = math.round(stats.plusMinus / games)
        
                -- normalize each stat from 0-10
                local rating = (points * 2) + plusMinus + (twoPtPercent / 10) + (threePtPercent / 10)
        
                local playerStats = {
                    playerObj = player,
                    rating = rating
                }
        
                table.insert(players, playerStats)
            end
        end
    end

    for j = 1, #league.freeAgents do
        local player = league.freeAgents[j]
        local stats = calculateYearlyStats(player, league.year - 1)

        if(stats.twoPA + stats.threePA >= MIN_SHOT_ATTEMPTS) then
            local points = math.round(stats.points)

            local twoPtPercent = 0
            if(stats.twoPA ~= 0) then
                twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
            end
            
            local threePtPercent = 0
            if(stats.threePA ~= 0) then
                threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
            end
    
            local plusMinus = math.round(stats.plusMinus / games)
    
            -- normalize each stat from 0-10
            local rating = (points * 2) + plusMinus + (twoPtPercent / 10) + (threePtPercent / 10)
    
            local playerStats = {
                playerObj = player,
                rating = rating
            }
    
            table.insert(players, playerStats)
        end
    end
    
    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

    for i = 1, #players do
        if players[i].playerObj == playerObj then
            return (#players - i) / #players
        end
    end

    return 0
end

local function findDefenseRanking(playerObj)
    local playerStats = calculateYearlyStats(playerObj, league.year - 1)
    if(playerStats.shotsAgainst == 0) then
        return 0
    end

    local players = {}

    for i = 1, #league.teams do
        local team = league.teams[i]

        for j = 1, #team.players do
            local player = team.players[j]
            local stats = calculateYearlyStats(player, league.year - 1)
            
            if(stats.shotsAgainst >= MIN_SHOT_ATTEMPTS) then
                local points = math.round(stats.pointsAgainst)
                local shots = math.round(stats.shotsAgainst)
                local blocks = math.round(stats.blocks)
                local steals = math.round(stats.steals)

                local ptsPerShot = tonumber(string.format("%.2f", (points / shots)))
                
                local ptsPerShotMin = ptsPerShot
                if(ptsPerShotMin < .1) then
                    ptsPerShotMin = .1
                end
                -- normalize each stat from 0-10
                local rating = (3 * shots / ptsPerShotMin) + (blocks * 3) + (steals * 3)

                local playerStats = {
                    playerObj = player,
                    rating = rating
                }

                table.insert(players, playerStats)
            end
        end
    end

    for j = 1, #league.freeAgents do
        local player = league.freeAgents[j]
        local stats = calculateYearlyStats(player, league.year - 1)
        
        if(stats.shotsAgainst >= MIN_SHOT_ATTEMPTS) then
            local points = math.round(stats.pointsAgainst)
            local shots = math.round(stats.shotsAgainst)
            local blocks = math.round(stats.blocks)
            local steals = math.round(stats.steals)

            local ptsPerShot = tonumber(string.format("%.2f", (points / shots)))
            
            local ptsPerShotMin = ptsPerShot
            if(ptsPerShotMin < .1) then
                ptsPerShotMin = .1
            end
            -- normalize each stat from 0-10
            local rating = (3 * shots / ptsPerShotMin) + (blocks * 3) + (steals * 3)

            local playerStats = {
                playerObj = player,
                rating = rating
            }

            table.insert(players, playerStats)
        end
    end

    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

    for i = 1, #players do
        if players[i].playerObj == playerObj then
            return (#players - i) / #players
        end
    end

    return 0
end

function calculateFairSalary(player)
    local offenseRanking = findOffenseRanking(player)
    local defenseRanking = findDefenseRanking(player)
    local skillLevel = calculateOverall(player)

    local offenseFactor = offenseRanking
    local defenseFactor = defenseRanking
    local ageFactor = (12 - player.years) / 12
    local skillFactor = ((skillLevel - 2.5) * 3.5) / 10
    if(skillFactor > 1) then
        skillFactor = 1
    elseif(skillFactor < 0) then
        skillFactor = 0
    end

    local percent = (offenseFactor * OFFENSE_FACTOR) + (defenseFactor * DEFENSE_FACTOR) + (skillFactor * SKILL_LEVEL_FACTOR) +
        (ageFactor * AGE_FACTOR)
    
    if(percent < .02) then
        percent = .02
    end

    return math.floor(CONTRACT_MAX * percent)
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

function offerRating(offer, fairSalary)
    local salaryRating = offer.salary / fairSalary
    local lengthRating = offer.length / 4
    local cityRating = offer.team.cityDesirability
    local chanceToWin = offer.team.cap / SALARY_CAP_MAX

    return salaryRating * lengthRating * cityRating * chanceToWin
end