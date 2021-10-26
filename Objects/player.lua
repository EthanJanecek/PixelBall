local player = {}

function player:createRandom()
    self.__index = self
    local maxStamina = math.random(1, 10)

    return setmetatable({
        name = "Player " .. tostring(math.random(1, 10000)),
        dribbling = math.random(1, 10),
        shooting = math.random(1, 10),
        finishing = math.random(1, 10),
        stealing = math.random(1, 10),
        blocking = math.random(1, 10),
        contesting = math.random(1, 10),
        height = math.random(72, 84),
        speed = math.random(1, 10),
        maxStamina = 10,
        stamina = 10,
        attitude = math.random(1, 10),
        number = math.random(0, 99),
        hasBall = false,
        sprite = nil,
        moving = false
    }, self)
end

function player:createPlayer(name, dribbling, shooting, finishing, stealing, blocking, contesting, height, speed, attitude, number)
    self.__index = self

    return setmetatable({
        name = name,
        dribbling = tonumber(dribbling),
        shooting = tonumber(shooting),
        finishing = tonumber(finishing),
        stealing = tonumber(stealing),
        blocking = tonumber(blocking),
        contesting = tonumber(contesting),
        height = tonumber(height),
        speed = tonumber(speed),
        maxStamina = 10,
        stamina = 10,
        attitude = tonumber(attitude),
        number = "" .. number,
        hasBall = false,
        sprite = nil,
        moving = false
    }, self)
end

return player