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
        maxStamina = maxStamina,
        stamina = maxStamina,
        attitude = math.random(1, 10),
        position = math.random(1, 5),
        hasBall = false,
        sprite = nil
    }, self)
end

function player:createPlayer(name, dribbling, shooting, finishing, stealing, blocking, contesting, height, speed, maxStamina, attitude, position)
    self.__index = self

    return setmetatable({
        name = name,
        dribbling = dribbling,
        shooting = shooting,
        finishing = finishing,
        stealing = stealing,
        blocking = blocking,
        contesting = contesting,
        height = height,
        speed = speed,
        maxStamina = maxStamina,
        stamina = maxStamina,
        attitude = attitude,
        position = position,
        hasBall = false,
        sprite = nil
    }, self)
end

return player