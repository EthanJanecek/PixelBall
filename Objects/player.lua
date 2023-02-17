StatsLib = require("Objects.stats")
AwardsLib = require("Objects.awards")

local player = {}

function player:createRandom()
    self.__index = self

    return setmetatable({
        name = "Player " .. tostring(math.random(1, 10000)),
        years = math.random(1, 10),
        dribbling = math.random(1, 10),
        closeShot = math.random(1, 10),
        midRange = math.random(1, 10),
        three = math.random(1, 10),
        finishing = math.random(1, 10),
        stealing = math.random(1, 10),
        blocking = math.random(1, 10),
        contestingInterior = math.random(1, 10),
        contestingExterior = math.random(1, 10),
        height = math.random(72, 84),
        speed = math.random(1, 10),
        maxStamina = 10,
        stamina = 10,
        passing = math.random(1, 10),
        ballSpeed = math.random(1, 10),
        quickness = math.random(1, 10),
        passDefending = math.random(1, 10),
        strength = math.random(1, 10),
        potential = math.random(1, 10),
        attitude = math.random(1, 10),
        number = math.random(0, 99),
        hasBall = false,
        sprite = nil,
        moving = false,
        starter = false,
        stats = {},
        manualMoving = false,
        movement = {},
        awards = AwardsLib:createAwards(),
        exp = 0,
        levels = 0
    }, self)
end

function player:createRookie()
    self.__index = self
    local speed = math.random(10)
    local minBallSpeed = speed - 4

    if(minBallSpeed < 1) then
        minBallSpeed = 1
    end

    return setmetatable({
        name = generateName(),
        years = 0,

        dribbling = math.random(1, 7),
        closeShot = math.random(1, 7),
        midRange = math.random(1, 7),
        three = math.random(1, 7),
        finishing = math.random(1, 7),
        stealing = math.random(1, 7),
        blocking = math.random(1, 7),
        contestingInterior = math.random(1, 7),
        contestingExterior = math.random(1, 7),
        passing = math.random(1, 7),
        passDefending = math.random(1, 7),

        height = math.random(1, 10),
        speed = speed,
        maxStamina = math.random(5, 10),
        stamina = 10,
        ballSpeed = math.random(minBallSpeed, speed),
        quickness = math.random(1, 10),
        strength = math.random(1, 10),
        potential = math.random(4, 10),

        attitude = math.random(1, 10),
        number = math.random(0, 99),
        hasBall = false,
        sprite = nil,
        moving = false,
        starter = false,
        stats = {},
        manualMoving = false,
        movement = {},
        awards = AwardsLib:createAwards(),
        exp = 0,
        levels = 0,
        last5 = {}
    }, self)
end

function calculateOverall(player)
    local sumOverall = player.dribbling + player.closeShot + player.midRange + player.three + player.finishing + player.stealing + 
            player.blocking + player.contestingInterior + player.contestingExterior + player.levels
    local overall = sumOverall / 11.0

    return overall
end

function calculateDraftStock(player)
    local sumOverall = player.dribbling + player.closeShot + player.midRange + player.three + player.finishing + player.stealing + 
            player.blocking + player.contestingInterior + player.contestingExterior + player.speed + player.height + player.stamina
            + player.potential * 3
    local overall = sumOverall / 15.0

    return overall
end

function addToLast5(player, result)
    table.insert(player.last5, result)

    if(#player.last5 > 5) then
        table.remove(player.last5, 1)
    end
end

function player:createPlayer(name, dribbling, closeShot, midRange, three, finishing, stealing, blocking, contestingInt, contestingExt, 
                speed, stamina, passing, ballSpeed, quickness, passDefending, strength, potential, height, number, years, starter)
    self.__index = self

    return setmetatable({
        name = name,
        years = tonumber(years),
        dribbling = tonumber(dribbling),
        closeShot = tonumber(closeShot),
        midRange = tonumber(midRange),
        three = tonumber(three),
        finishing = tonumber(finishing),
        stealing = tonumber(stealing),
        blocking = tonumber(blocking),
        contestingInterior = tonumber(contestingInt),
        contestingExterior = tonumber(contestingExt),
        height = tonumber(height),
        speed = tonumber(speed),
        maxStamina = tonumber(stamina),
        passing = tonumber(passing),
        ballSpeed = tonumber(ballSpeed),
        quickness = tonumber(quickness),
        passDefending = tonumber(passDefending),
        strength = tonumber(strength),
        potential = tonumber(potential),
        stamina = 10,
        attitude = 10,
        number = "" .. number,
        hasBall = false,
        sprite = nil,
        moving = false,
        starter = starter,
        stats = {},
        manualMoving = false,
        movement = {},
        awards = AwardsLib:createAwards(),
        exp = 0,
        levels = 0,
        last5 = {}
    }, self)
end

function player:getGameStats(year, week)
    for i = 1, #self.stats do
        local stat = self.stats[i]

        if stat.year == year and stat.week == week then
            return stat
        end
    end

    return StatsLib:createStats()
end

function player:calculateYearlyStats(year)
    local tmpStats = StatsLib:createStats()

    for i = 1, #self.stats do
        local stat = self.stats[i]

        if stat.year == year then
            addStats(tmpStats, stat)
        end
    end

    return tmpStats
end

function player:calculateCareerStats()
    local tmpStats = StatsLib:createStats()

    for i = 1, #self.stats do
        addStats(tmpStats, self.stats[i])
    end

    return tmpStats
end

return player