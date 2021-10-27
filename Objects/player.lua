local player = {}

function player:createRandom()
    self.__index = self

    return setmetatable({
        name = "Player " .. tostring(math.random(1, 10000)),
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
        attitude = math.random(1, 10),
        number = math.random(0, 99),
        hasBall = false,
        sprite = nil,
        moving = false
    }, self)
end

function player:createPlayer(name, dribbling, closeShot, midRange, three, finishing, stealing, blocking, contestingInt, contestingExt, speed, stamina, passing, height, number)
    self.__index = self

    return setmetatable({
        name = name,
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
        stamina = 10,
        attitude = 10,
        number = "" .. number,
        hasBall = false,
        sprite = nil,
        moving = false
    }, self)
end

return player