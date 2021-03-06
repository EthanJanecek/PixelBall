local socket = require("socket")
local StickLib   = require("Objects.virtual_joystick")
local composer = require("composer")
local RouteLib = require("Objects.route")
local PlayLib = require("Objects.play")

local scene = composer.newScene()
local sceneGroup = nil

local standingData = {width=32, height=32, numFrames=1}
local standingSheet = graphics.newImageSheet("images/playerModels/TopDownStandingRed.png", standingData)
local standingSheetBlue = graphics.newImageSheet("images/playerModels/TopDownStandingBlue.png", standingData)

local movingData = {width=32, height=32, numFrames=4}
local movingSheet = graphics.newImageSheet("images/playerModels/TopDownWalkingRed.png", movingData)
local movingSheetBlue = graphics.newImageSheet("images/playerModels/TopDownWalkingBlue.png", movingData)

local sequenceData = {
    {name="standing", sheet=standingSheet, start=1, count=1, time=750},
    {name="moving", sheet=movingSheet, start=1, count=4, time=750}
}

local sequenceDataBlue = {
    {name="standing", sheet=standingSheetBlue, start=1, count=1, time=750},
    {name="moving", sheet=movingSheetBlue, start=1, count=4, time=750}
}

offense = true
userPlayer = 1
basketball = nil
team = nil
opponent = nil
userIsHome = true
activePlay = nil
activeDefense = nil
MyStick = nil

local holdingShoot = false
local start = 0
local maxTime = 1000

local playing = true -- Keeps track if a play is in progress or not. Don't allow user input after a play is over
local endedPossession = false -- Keeps track of if the possession is still active. Is basically playing but with the time to shoot
local scoreboard = {away=nil, home=nil, qtr=nil, time=nil, shotClock=nil}
local result = ""

local nameFontSize = 8

local minSpeed = 1.25
local speedScaling = .1

local deadzoneBase = 6 -- default
local deadzoneFactor = 3
local deadzoneMin = 4
local shootingScale = 1.4

local defenseScale = 1
local zoneSize = 3 * feetToPixels

collisionAngleStep = 5
collisionRadius = .75 * feetToPixels

local contestRadius = 3 * feetToPixels -- 3 feet away
local finishingRadius = 4 * feetToPixels * conversionFactor
local closeShotRadius = 10 * feetToPixels * conversionFactor
local maxBlockedProb = 25

local staminaRunningUsage = -.0005
local shotStaminaUsage = -.4
local staminaStandingRegen = -staminaRunningUsage / 4
local staminaBenchRegen = -staminaRunningUsage

local maxShotPowerModifier = .8
local powerScalingStamina = 5

local heightDiffMin = 5
local heightDiffMax = 15

local reactionTimeDefault = 100
local reactionTimeModifier = 25
local lookBackSteps = 20
local directionChangeThreshold = 2

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function changeStamina(player, diff)
    player.stamina = player.stamina + diff

    if(player.stamina > player.maxStamina) then
        player.stamina = player.maxStamina
    elseif(player.stamina < 1) then
        player.stamina = 1
    end
end

function findRange(player)
    local angle = getRotationToBasket(player.sprite)
    local dist = 23.75

    if(angle > (90 - 24.44) or angle < (-90 + 24.44)) then
        dist = 22
    end

    local distToHoop = getDist(player.sprite, hoopCenter)

    if(distToHoop > (dist * feetToPixels * conversionFactor)) then
        return "three"
    elseif(distToHoop < finishingRadius) then
        return "finishing"
    elseif(distToHoop < closeShotRadius)  then
        return "closeShot"
    else
        return "midRange"
    end
end

local function staminaPercent(player)
    return player.stamina / player.maxStamina
end

local function copyPlay(play)
    -- Copies the play to a new object so that the orginal routes do not get modified
    local newRoutes = {}

    for i = 1, 5 do
        local points = {}
        for j = 1, #play.routes[i].points do
            table.insert(points, play.routes[i].points[j])
        end
        newRoutes[i] = RouteLib:createRouteByPoints(points, i)
    end

    return PlayLib:createPlay(newRoutes, play.name)
end

local function gameClockSubtract(time)
    if(time > gameDetails.sec) then
        gameDetails.sec = gameDetails.sec - time + 60
        gameDetails.min = gameDetails.min - 1
    else
        gameDetails.sec = gameDetails.sec - time
    end

    if(gameDetails.min < 0) then
        gameDetails.min = minutesInQtr
        gameDetails.sec = 0
        gameDetails.qtr = gameDetails.qtr + 1
        result = "qtr end"
        
        if(gameDetails.qtr >= 5) then
            if(score.home ~= score.away) then
                gameInProgress = false
                result = "game end"
            else
                if(minutesInQtr >= 5) then
                    gameDetails.min = 5
                end
            end
        end

        playing = false
        endPossession()
    end
end

function inBounds(x, y)
    return (x <= bounds.maxX and x >= bounds.minX) and (y <= bounds.maxY and y >= bounds.minY)
end

function getCollisionObject(x, y, sprite, radius)
    for i = 1, 5 do
        local player = team.players[i]
        local defender = opponent.players[i]
        
        if(player.sprite ~= sprite) then
            if(getDist({x = x, y = y}, player.sprite) < radius) then
                return player
            end
        end

        if(defender.sprite ~= sprite) then
            if(getDist({x = x, y = y}, defender.sprite) < radius) then
                return defender
            end
        end
    end

    return nil
end

function detectCollision(x, y, sprite, radius)
    for i = 1, 5 do
        local player = team.players[i]
        local defender = opponent.players[i]
        
        if(player.sprite ~= sprite) then
            if(getDist({x = x, y = y}, player.sprite) < radius) then
                return true
            end
        end

        if(defender.sprite ~= sprite) then
            if(getDist({x = x, y = y}, defender.sprite) < radius) then
                return true
            end
        end
    end

    return false
end

function move(player, angle, percent, pointTowards, collisionSize)
    collisionSize = collisionSize or collisionRadius
    local Obj = player.sprite
    local maxSpeed = minSpeed + (player.speed * speedScaling) * staminaPercent(player)
    local newX = Obj.x + math.cos(math.rad(angle-90)) * (maxSpeed * percent)
    local newY = Obj.y + math.sin(math.rad(angle-90)) * (maxSpeed * percent)

    local collisionObject = getCollisionObject(newX, newY, Obj, collisionSize)
    local angleToCollision = 0
    if(collisionObject) then
        angleToCollision = getRotation(Obj, collisionObject.sprite)
    end
    local initialAngle = (angle - angleToCollision) % 360

    local loops = 0
    while((detectCollision(newX, newY, Obj, collisionSize))) do
        if((initialAngle >= 0 and initialAngle <= 180) or (not player.hasBall)) then
            angle = angle + collisionAngleStep
        else
            angle = angle - collisionAngleStep
        end

        newX = Obj.x + math.cos(math.rad(angle-90)) * (maxSpeed * percent)
        newY = Obj.y + math.sin(math.rad(angle-90)) * (maxSpeed * percent)

        loops = loops + 1

        if(loops > (360 / collisionAngleStep)) then
            -- Did a full 360 degree check
            newX = Obj.x
            newY = Obj.y
            break
        end
    end

    if(percent == 0) then
        if(not Obj.isPlaying or Obj.sequence == "moving") then
            Obj:setSequence("standing")
            Obj:play()
        end

        Obj.rotation = getRotation(Obj, pointTowards)
    elseif(inBounds(newX, newY)) then
        if(not Obj.isPlaying or Obj.sequence == "standing") then
            Obj:setSequence("moving")
            Obj:play()
        end
        
        Obj.x = newX
        Obj.y = newY
        Obj.rotation = angle
    end

    Obj.name.x = Obj.x
    Obj.name.y = Obj.y
    Obj.name.rotation = Obj.rotation

    if(player.hasBall) then
        local ballLoc = calculateBballLoc(Obj.rotation)
        basketball.x = ballLoc.x
        basketball.y = ballLoc.y
    end

    table.insert(player.movement, {
        x = Obj.x,
        y = Obj.y,
        angle = Obj.rotation,
        percent = percent,
        time = socket.gettime() * 1000,
        changeX = math.cos(math.rad(angle-90)) * (maxSpeed * percent),
        changeY = math.sin(math.rad(angle-90)) * (maxSpeed * percent)
    })
end

local function reset()
    Runtime:removeEventListener("enterFrame", movePlayers)
    composer.removeScene("Scenes.game")

    if(gameInProgress) then
        local options = {
            params = {
                reSim = true,
            }
        }
        composer.gotoScene("Scenes.simulate_defense", options)
    else
        composer.gotoScene("Scenes.postgame")
    end
end

local function getQuarterString()
    if(gameDetails.qtr == 1) then
        return "1st"
    elseif(gameDetails.qtr == 2) then
        return "2nd"
    elseif(gameDetails.qtr == 3) then
        return "3rd"
    else
        return gameDetails.qtr .. "th"
    end
end

local function getQuarterStringFromQtr(qtr)
    if(qtr == 1) then
        return "1st"
    elseif(qtr == 2) then
        return "2nd"
    elseif(qtr == 3) then
        return "3rd"
    else
        return gameDetails.qtr .. "th"
    end
end

local function convertPoints(courtX, courtY, x, y)
    -- Converts an (x, y) coordinate on the full sized court to a new coordinate on the mini drawing of the play
    local width = 1000 * conversionFactor / 6.5
    local height = 940 * conversionFactor / 6.5

    local xScale = (x - centerX) / courtW
    local x = courtX + (xScale * width)

    local yScale = (y - centerY) / courtH
    local y = courtY + (yScale * height)

    return {x=x, y=y}
end

local function displayPlays()
    local numPlays = #team.playbook.plays
    if(numPlays > 5) then
        numPlays = 5
    end

    for i = 1, numPlays do
        local play = team.playbook.plays[i]

        local function choosePlay()
            activePlay = copyPlay(play)
        end

        local backgroundImage = display.newImageRect(sceneGroup, "images/NbaCourt.png", 1000 * conversionFactor / 6.5, 940 * conversionFactor / 6.5)
        backgroundImage.x = -backgroundImage.width
        backgroundImage.y = display.contentHeight * i / 6
        backgroundImage:addEventListener("tap", choosePlay)

        -- Draw routes on minimap
        for j = 1, #play.routes do
            local route = play.routes[j]

            for k = 1, #route.points do
                local point = route.points[k]
                local circleLoc = convertPoints(backgroundImage.x, backgroundImage.y, point.x, point.y)

                local circle = display.newCircle(sceneGroup, circleLoc.x, circleLoc.y, 2)
                circle:setFillColor(0, 0, .5, .25)
            end
        end
    end
end

local function displayScore()
    local dividerVertical = display.newRect(sceneGroup, 25 + (2 / 2), 40/2, 2, 40)
    dividerVertical:setStrokeColor(0, 0, 0)
    dividerVertical:setFillColor(0, 0, 0)

    local homeStr = opponent.abbrev
    local awayStr = team.abbrev

    if(userIsHome) then
        homeStr = team.abbrev
        awayStr = opponent.abbrev
    end

    local awayLabel = display.newText(sceneGroup, awayStr, 9, 12, native.systemFont, 12)
    awayLabel:setFillColor(.922, .910, .329)

    local homeLabel = display.newText(sceneGroup, homeStr, 47, 12, native.systemFont, 12)
    homeLabel:setFillColor(.922, .910, .329)

    local scoreLabelDividerHorizontal = display.newRect(sceneGroup, 25 + (2 / 2), 20, 78, 2)
    scoreLabelDividerHorizontal:setStrokeColor(0, 0, 0)
    scoreLabelDividerHorizontal:setFillColor(0, 0, 0)

    scoreboard.away = display.newText(sceneGroup, score.away, 9, 27, native.systemFont, 12)
    scoreboard.away:setFillColor(.922, .910, .329)

    scoreboard.home = display.newText(sceneGroup, score.home, 47, 27, native.systemFont, 12)
    scoreboard.home:setFillColor(.922, .910, .329)

    local scoreDividerHorizontal = display.newRect(sceneGroup, 25 + (8 / 2), 40, 78, 8)
    scoreDividerHorizontal:setStrokeColor(0, 0, 0)
    scoreDividerHorizontal:setFillColor(0, 0, 0)
end

local function displayTime()
    scoreboard.time = display.newText(sceneGroup, string.format("%02d", gameDetails.min) .. ":" .. string.format("%02d", gameDetails.sec), 25, 33 + 24, native.systemFont, 24)
    scoreboard.time:setFillColor(.922, .910, .329)

    dividerHorizontal = display.newRect(sceneGroup, 25 + (2 / 2), 70, 78, 2)
    dividerHorizontal:setStrokeColor(0, 0, 0)
    dividerHorizontal:setFillColor(0, 0, 0)

    local dividerVertical = display.newRect(sceneGroup, 25 + (2 / 2), 70 + (30 / 2), 2, 30)
    dividerVertical:setStrokeColor(0, 0, 0)
    dividerVertical:setFillColor(0, 0, 0)

    scoreboard.qtr = display.newText(sceneGroup, getQuarterString(), 9, 65 + 20, native.systemFont, 20)
    scoreboard.qtr:setFillColor(.922, .910, .329)

    scoreboard.shotClock = display.newText(sceneGroup, string.format("%02d", gameDetails.shotClock), 47, 65 + 20, native.systemFont, 20)
    scoreboard.shotClock:setFillColor(.922, .910, .329)
end

local function displayScoreboard()
    local scoreboardOutline = display.newRect(sceneGroup, 27, 52, 78, 100)
    scoreboardOutline:setStrokeColor(0, 0, 0)
    scoreboardOutline:setFillColor(0, 0, 0, 0)
    scoreboardOutline.strokeWidth = 4

    displayScore()
    displayTime()
end

local function clearScoreboard()
    local clearRect = display.newRect(sceneGroup, 27, 52, 78, 100)
    clearRect:setFillColor(.286, .835, .961)
    clearRect.strokeWidth = 4
end

function getDist(a, b)
    return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))
end

local function calculateShotPoints()
    local angle = getRotationToBasket(team.players[userPlayer].sprite)
    local dist = 23.75

    if(angle > (90 - 24.44) or angle < (-90 + 24.44)) then
        dist = 22
    end

    if(getDist(team.players[userPlayer].sprite, hoopCenter) < (dist * feetToPixels * conversionFactor)) then
        return "2"
    else
        return "3"
    end
end

function endPossession()
    endedPossession = true
    local message = ""

    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    if(result == "2") then
        if(userIsHome) then
            score.home = score.home + 2
        else
            score.away = score.away + 2
        end

        message = "The 2 is good!"
        team.players[userPlayer].gameStats.points = team.players[userPlayer].gameStats.points + 2
        team.players[userPlayer].gameStats.twoPA = team.players[userPlayer].gameStats.twoPA + 1
        team.players[userPlayer].gameStats.twoPM = team.players[userPlayer].gameStats.twoPM + 1
    elseif(result == "3") then
        if(userIsHome) then
            score.home = score.home + 3
        else
            score.away = score.away + 3
        end

        message = "The 3 is good!"
        team.players[userPlayer].gameStats.points = team.players[userPlayer].gameStats.points + 3
        team.players[userPlayer].gameStats.threePA = team.players[userPlayer].gameStats.threePA + 1
        team.players[userPlayer].gameStats.threePM = team.players[userPlayer].gameStats.threePM + 1
    elseif(result == "Miss") then
        message = "The shot is no good!"
    elseif(result == "Blocked") then
        message = "The shot is blocked!"
    elseif(result == "shot clock") then
        message = "The shot clock has expired"
    elseif(result == "qtr end") then
        message = "The " .. getQuarterStringFromQtr(gameDetails.qtr - 1) .. " quarter has ended"
    elseif(result == "game end") then
        message = "The game has ended"
        gameInProgress = false
    end

    local displayMessage = display.newText(sceneGroup, message, display.contentCenterX, display.contentCenterY, native.systemFont, 32)
    displayMessage:setFillColor(.922, .910, .329)
    displayScoreboard()

    background:addEventListener("tap", reset)
end

local function shootTime()
    local current = socket.gettime() * 1000
    local diff = current - start

    if(diff < maxTime) then
        local height = 150.0 * diff / maxTime
        local powerBar = display.newRect(sceneGroup, bounds.maxX + 45, 235 - height / 2, 25, height)
        powerBar:setStrokeColor(0, 0, 0, 0)
        powerBar:setFillColor(47 / 255.0, 209 / 255.0, 25 / 255.0)

        if(holdingShoot) then
            timer.performWithDelay(20, shootTime)
        end
    end
end

local function calculateDeadzone(shooter, skill)
    local deadzone = deadzoneBase -- Base value

    -- Scale up based on how good of a shooter they are
    deadzone = deadzone + (math.pow(shootingScale, skill) * staminaPercent(shooter))

    -- Scale down for each defender in the area and how good they are at contesting
    for i = 1, 5 do
        local defender = opponent.players[i]
        local distance = getDist(shooter.sprite, defender.sprite)

        if(distance <= feetToPixels / 1.5) then
            distance = feetToPixels / 1.5
        end

        if(distance < contestRadius) then
            -- Scale down based off of how close they are, height difference, and skill at defending
            local heightDiff = defender.height - shooter.height + 10 -- Will be from 0-20
            if(heightDiff < heightDiffMin) then
                heightDiff = heightDiffMin
            elseif(heightDiff > heightDiffMax) then
                heightDiff = heightDiffMax
            end

            local range = findRange(defender)
            local contestSkill = -1
            if(range == "finishing" or range == "closeShot") then
                contestSkill = defender.contestingInterior * deadzoneFactor * staminaPercent(defender)
            else
                contestSkill = defender.contestingExterior * deadzoneFactor * staminaPercent(defender)
            end
            
            local distanceFactor = feetToPixels / distance -- Will be in the range of 1/3 - 2
            local factor = (heightDiff / 10) * distanceFactor * contestSkill * defenseScale
            deadzone = deadzone - factor
        end
    end

    if(deadzone < deadzoneMin) then
        deadzone = deadzoneMin
    end

    return deadzone
end

local function isBlocked(shooter)
    for i = 1, 5 do
        local defender = opponent.players[i]
        local distance = getDist(shooter.sprite, defender.sprite)

        if(math.floor(distance) <= feetToPixels / 1.5) then
            distance = feetToPixels / 1.5
        end

        if(distance < contestRadius) then
            -- Scale down based off of how close they are, height difference, and skill at defending
            local heightDiff = defender.height - shooter.height + 10 -- Will be from 0-20

            local contestSkill = defender.blocking * 5 * staminaPercent(defender)
            local distanceFactor = feetToPixels / distance -- Will be in the range of 1/3 - 2
            local probability = (heightDiff / 10) * distanceFactor * contestSkill
            local num = math.random(100)

            if(probability > maxBlockedProb) then
                probability = maxBlockedProb
            end

            if(num < probability) then
                defender.gameStats.blocks = defender.gameStats.blocks + 1
                return true
            end
        end
    end

    return false
end

local function calculateShotEndPosition(rotation, dist)
    local endPos = nil

    if(result == "Miss") then
        endPos = {x = basketball.x + (dist * math.cos(math.rad(rotation))), y = basketball.y - (dist * math.sin(math.rad(rotation)))}

        if(endPos.y < 0) then
            endPos.y = 0
        end

        if(endPos.x > bounds.maxX) then
            endPos.x = bounds.maxX
        elseif(endPos.x < bounds.minX) then
            endPos.x = bounds.minX
        end
    else
        endPos = {x = hoopCenter.x, y = hoopCenter.y}
    end

    return endPos
end

local function finishShot()
    team.players[userPlayer].hasBall = false
    holdingShoot = false
    playing = false

    local endTime = socket.gettime() * 1000
    local power = (endTime - start) / maxTime

    if(power > 1) then
        power = 1
    end

    local maxShotPower = maxShotPowerModifier -- * (team.players[userPlayer].maxStamina / 10.0)
    local dist = (bounds.maxY * power * maxShotPower) - (powerScalingStamina / staminaPercent(team.players[userPlayer]))
    local rotation = 90 - getRotationToBasket(team.players[userPlayer].sprite)

    local distToHoop = getDist(team.players[userPlayer].sprite, hoopCenter)
    local blocked = isBlocked(team.players[userPlayer])

    if(blocked) then
        result = "Blocked"
        transition.moveTo(basketball, {x=team.players[userPlayer].sprite.x , y=team.players[userPlayer].sprite.y, time = 1, onComplete=endPossession})
    else
        local deadzone = 0
        local range = findRange(team.players[userPlayer])

        if(range == "finishing") then
            deadzone = calculateDeadzone(team.players[userPlayer], team.players[userPlayer].finishing)
        elseif(range == "closeShot") then
            deadzone = calculateDeadzone(team.players[userPlayer], team.players[userPlayer].closeShot)
        elseif(range == "midRange") then
            deadzone = calculateDeadzone(team.players[userPlayer], team.players[userPlayer].midRange)
        else
            deadzone = calculateDeadzone(team.players[userPlayer], team.players[userPlayer].three)
        end

        if(math.abs(distToHoop - dist) <= deadzone) then
            result = calculateShotPoints()
        else
            result = "Miss"
            pts = calculateShotPoints()

            if pts == "2" then
                team.players[userPlayer].gameStats.twoPA = team.players[userPlayer].gameStats.twoPA + 1
            elseif pts == "3" then
                team.players[userPlayer].gameStats.threePA = team.players[userPlayer].gameStats.threePA + 1
            end
        end

        local endPos = calculateShotEndPosition(rotation, dist)
        transition.moveTo(basketball, {x=endPos.x , y=endPos.y, time = dist * 3, onComplete=endPossession})
    end

    changeStamina(team.players[userPlayer], shotStaminaUsage)
end

local function shootBall(event)
    if(playing) then
        if(event.phase == "began") then
            start = socket.gettime() * 1000
            holdingShoot = true
            timer.performWithDelay(20, shootTime)
        elseif (event.phase == "ended") then
            finishShot()
        end
    end
end

local function displayShotBar()
    -- Create shoot button
    local shootBtn = display.newImageRect(sceneGroup, "images/basketball_shoot_btn.png", 75, 75)
    shootBtn.x = bounds.maxX + 50
    shootBtn.y = bounds.maxY - 40
    shootBtn:addEventListener("touch", shootBall)

    -- Create shot power bar
    local shotBar = display.newRect(sceneGroup, bounds.maxX + 45, 160, 25, 150)
    shotBar:setStrokeColor(0, 0, 0)
    shotBar:setFillColor(0, 0, 0, 0)
    shotBar.strokeWidth = 2
end

local function getNameStr(player)
    local nameStr = player.number .. " - "

    local i = 1
    for str in string.gmatch(player.name, "([^ ]+)") do
        if(i == 1) then
            nameStr = nameStr .. str:sub(1, 1) .. ". "
        else
            nameStr = nameStr .. str
        end
        
        i = i + 1
    end

    return nameStr
end

local function displayNames()
    local teamName = display.newText(sceneGroup, team.name, bounds.maxX + 100, 20, native.systemFont, 8)
    teamName:setFillColor(0, 0, 0)

    for i = 1, 5 do
        local player = team.players[i]
        local playerName = display.newText(sceneGroup, getNameStr(player), bounds.maxX + 100, 20 + 10 * i, native.systemFont, 8)

        if(staminaPercent(player) >= .75) then
            playerName:setFillColor(0, 1, 0)
        elseif(staminaPercent(player) >= .5) then
            playerName:setFillColor(1, 1, 0)
        else
            playerName:setFillColor(1, 0, 0)
        end
    end

    local opponentName = display.newText(sceneGroup, opponent.name, bounds.maxX + 100, display.contentCenterY * 2/3, native.systemFont, 8)
    opponentName:setFillColor(0, 0, 0)

    for i = 1, 5 do
        local player = opponent.players[i]
        local playerName = display.newText(sceneGroup, getNameStr(player), bounds.maxX + 100, display.contentCenterY * 2/3 + 10 * i, native.systemFont, 8)

        if(staminaPercent(player) >= .75) then
            playerName:setFillColor(0, 1, 0)
        elseif(staminaPercent(player) >= .5) then
            playerName:setFillColor(1, 1, 0)
        else
            playerName:setFillColor(1, 0, 0)
        end
    end
end

function calculateBballLoc(angle)
    local x = team.players[userPlayer].sprite.x + 15*math.cos(math.rad(90 - angle))
    local y = team.players[userPlayer].sprite.y - 15*math.sin(math.rad(90 - angle))

    return {x=x, y=y}
end

function getRotation(position1, position2)
    local o = position1.y - position2.y
    local a = position1.x - position2.x
    local h = math.sqrt(o * o + a * a)
    local angle = math.deg(math.acos(a / h)) - 90

    if(position1.y >= position2.y) then
        return angle
    else
        return -angle + 180
    end
end

function getRotationToBasket(position)
    return getRotation(position, hoopCenter)
end

local function calculateEndPointMovement(player, route)
    local maxDist = minSpeed + (player.speed * speedScaling)
    local nextPoint = route.points[1]
    local distToNext = getDist(player.sprite, nextPoint)

    while(nextPoint and distToNext < .1 * feetToPixels or (detectCollision(nextPoint.x, nextPoint.y, player.sprite, collisionRadius) and 
                    getDist(nextPoint, player.sprite) < collisionRadius)) do
        table.remove(route.points, 1)

        if(route.points[1] == nil) then
            break
        end
        nextPoint = route.points[1]
        distToNext = getDist(player.sprite, nextPoint)
    end

    local newAngle = getRotation(player.sprite, nextPoint)
    local percent = distToNext / maxDist

    if(route.points[1] == nil) then
        player.moving = false
        percent = 0
    elseif(distToNext < .1 * feetToPixels) then
        table.remove(route.points, 1)
        percent = .001
        player.moving = true
    elseif(percent > 1) then
        player.moving = true
        percent = 1
    end
    
    move(player, newAngle, percent, hoopCenter)
    changeStamina(player, staminaRunningUsage * percent)
end

local function calculateEndPointMovementZone(player, route, pointTowards)
    local maxDist = minSpeed + (player.speed * speedScaling)
    local nextPoint = route.points[1]
    local distToNext = getDist(player.sprite, nextPoint)
    local newAngle = getRotation(player.sprite, nextPoint)
    local percent = distToNext / maxDist

    if((distToNext < .1 * feetToPixels or (detectCollision(nextPoint.x, nextPoint.y, player.sprite, collisionRadius) and getDist(nextPoint, player.sprite) < collisionRadius)) 
                    and not pointTowards.moving) then
        percent = 0
    elseif(distToNext < .1 * feetToPixels or (detectCollision(nextPoint.x, nextPoint.y, player.sprite, collisionRadius) and 
                    getDist(nextPoint, player.sprite) < collisionRadius)) then
        table.remove(route.points, 1)
        percent = .001
    elseif(percent > 1) then
        percent = 1
    end
    
    move(player, newAngle, percent, pointTowards.sprite)
    changeStamina(player, staminaRunningUsage * percent)
end

local function moveOffense()
    if(activePlay) then
        for i = 1, 5 do
            local player = team.players[i]
            local route = activePlay.routes[i]
    
            if(not player.hasBall) then
                -- Follow defined route
                local nextPoint = route.points[1]

                if(nextPoint) then
                    calculateEndPointMovement(player, route)
                else
                    moving = false
                    move(player, 0, 0, hoopCenter)
                    changeStamina(player, staminaStandingRegen)
                end
            else
                local player = team.players[userPlayer]
                MyStick:move(player, hoopCenter)
                activePlay.routes[i].points = {nil}

                if(MyStick.percent == 0) then
                    player.moving = false
                    changeStamina(player, staminaStandingRegen)
                else
                    player.moving = true
                    changeStamina(player, staminaRunningUsage * MyStick.percent)
                end
            end
        end
    end
end

local function getMovementPoint(shooter, defender)
    local reactionTime = reactionTimeDefault + (shooter.speed - defender.speed) * reactionTimeModifier
    if(reactionTime < 0) then
        reactionTime = 0
    end

    local lastTime = (socket.gettime() * 1000) - reactionTime

    for i = 1, #shooter.movement do
        if(shooter.movement[i].time >= lastTime) then
            return shooter.movement[i]
        end
    end

    return nil
end

local function directionChange(player)
    if(#player.movement <= lookBackSteps) then
        return false
    end

    local movementNow = player.movement[#player.movement]

    local movementOld = player.movement[#player.movement - lookBackSteps]

    local dist = math.sqrt(math.pow(movementNow.changeX - movementOld.changeX, 2) + 
                    math.pow(movementNow.changeY - movementOld.changeY, 2))

    if(dist > directionChangeThreshold) then
        return true
    end

    return false
end

local function defenderCloseOut(defender, shooter, distAway)
    local rotationToBasket = getRotationToBasket(shooter.sprite)
    local distToBasket = getDist(shooter.sprite, hoopCenter)
    local newPos = {x = shooter.sprite.x + (math.cos(math.rad(rotationToBasket - 90)) * distAway),
                    y = shooter.sprite.y + (math.sin(math.rad(rotationToBasket - 90)) * distAway)}
    
    if(directionChange(shooter)) then
        local movementPoint = getMovementPoint(shooter, defender)

        if(movementPoint) then
            rotationToBasket = getRotationToBasket(movementPoint)
            distToBasket = getDist(movementPoint, hoopCenter)
            newPos = {x = movementPoint.x + (math.cos(math.rad(rotationToBasket - 90)) * distAway),
                        y = movementPoint.y + (math.sin(math.rad(rotationToBasket - 90)) * distAway)}
        end
    end

    if(distAway > distToBasket) then
        distAway = distToBasket / 2
    end

    local newAngle = getRotation(defender.sprite, newPos) 
    local percent = getDist(defender.sprite, newPos) / (minSpeed + (defender.speed * speedScaling))

    if((getDist(defender.sprite, newPos) < .1 * feetToPixels or (detectCollision(newPos.x, newPos.y, defender.sprite, collisionRadius) and 
                    getDist(newPos, defender.sprite) < collisionRadius)) and shooter.sprite.sequence == "standing") then
        percent = 0
    elseif(getDist(defender.sprite, newPos) < .1 * feetToPixels or (detectCollision(newPos.x, newPos.y, defender.sprite, collisionRadius) and 
                    getDist(newPos, defender.sprite) < collisionRadius)) then
        percent = .001
    elseif(percent > 1) then
        percent = 1
    end

    move(defender, newAngle, percent, shooter.sprite)

    if(percent == 0) then
        changeStamina(defender, staminaStandingRegen)
    else
        changeStamina(defender, staminaRunningUsage * percent)
    end
end

local function findPlayersInZone(zoneCenter, offensePlayers)
    local players = {}

    for i = 1, 5 do
        local offensePlayer = offensePlayers[i]
        local dist = getDist(zoneCenter, offensePlayer.sprite)

        if(dist <= zoneSize) then
            table.insert(players, offensePlayer)
        end
    end

    return players
end

local function findBallCarrier(players)
    for i = 1, #players do
        if(players[i].hasBall) then
            return i
        end
    end

    return -1
end

local function moveZone(defender, zoneCenter, noCoverOnBallHandler, closestDefender)
    local offensePlayers = {unpack(team.players, 1, 5)}
    table.sort(offensePlayers, function (a, b)
        return getDist(zoneCenter, a.sprite) < getDist(zoneCenter, b.sprite)
    end)

    local playersInZone = findPlayersInZone(zoneCenter, offensePlayers)
    local ballCarrier = findBallCarrier(playersInZone)

    if(noCoverOnBallHandler and closestDefender == defender) then
        -- If nobody is covering ball carrier and this defender is the closest defender, move him to ball carrier
        defenderCloseOut(defender, team.players[userPlayer], feetToPixels)
    elseif(ballCarrier ~= -1) then
        -- Ball carrier is in zone
        defenderCloseOut(defender, offensePlayers[ballCarrier], feetToPixels)
    elseif(#playersInZone ~= 0) then
        -- Choose random other player in zone
        local num = math.random(1, #playersInZone)
        defenderCloseOut(defender, offensePlayers[num], feetToPixels)
    else
        -- Move to edge of zone in direction of nearest player
        local angle = getRotation(zoneCenter, offensePlayers[1].sprite)
        local newPos = {x = zoneCenter.x + math.cos(math.rad(angle-90)) * zoneSize, y = zoneCenter.y + math.sin(math.rad(angle-90)) * zoneSize}
        calculateEndPointMovementZone(defender, {points = {newPos}}, offensePlayers[1])
    end
end

local function moveDefense()
    if(activeDefense.coverage == "zone") then
        local zone = nil

        if(activeDefense.name == "1-2-2") then
            zone = zone122
        elseif(activeDefense.name == "2-3") then
            zone = zone23
        end

        local defensePlayers = {unpack(opponent.players, 1, 5)}
        table.sort(defensePlayers, function (a, b)
            return getDist(team.players[userPlayer].sprite, zone[indexOf(opponent.players, a)]) < getDist(team.players[userPlayer].sprite, zone[indexOf(opponent.players, b)])
        end)

        local noCoverOnBallHandler = getDist(team.players[userPlayer].sprite, zone[indexOf(opponent.players, defensePlayers[1])]) > zoneSize
        local closestDefender = defensePlayers[1]

        for i = 1, 5 do
            moveZone(opponent.players[i], zone[i], noCoverOnBallHandler, closestDefender)
        end
    elseif(activeDefense.coverage == "man") then
        -- Move players
        local distAway = math.abs(activeDefense.aggresiveness - 6) * feetToPixels -- Distance away that defender should stand

        for i = 1, 5 do
            if(activeDefense.aggresiveness == -1) then
                -- Scale based on how good of a shooter they are
                distAway = math.abs(team.players[i].three - 11) * (feetToPixels / 2.5)
            end

            defenderCloseOut(opponent.players[i], team.players[i], distAway)
        end
    end
end

local function regenBench()
    for i = 6, 15 do
        changeStamina(team.players[i], staminaBenchRegen)
    end
end

local function movePlayers()
    if(playing) then
        moveOffense()
        moveDefense()
        regenBench()
    end
end

local function createJoystick()
    local newGroup = display.newGroup()
    sceneGroup:insert(newGroup)

    MyStick = StickLib.NewStick({
        x = display.contentWidth * .055,
        y = display.contentHeight * .85,
        thumbSize = 8,
        borderSize = 16,
        snapBackSpeed = .2,
        R = 25,
        G = 255,
        B = 255,
        group = newGroup,
    })
end

local function createPlayer(player, positions, standingSequenceData, movingSequenceData, pointTowards)
    local playerSprite = display.newSprite(sceneGroup, standingSequenceData, movingSequenceData)
    playerSprite.x = tonumber(positions.x)
    playerSprite.y = tonumber(positions.y)
    playerSprite.rotation = getRotation(positions, pointTowards)
    playerSprite:play()

    local name = display.newText(sceneGroup, player.number, positions.x, positions.y, native.systemFont, nameFontSize)
    name:setFillColor(1, 1, 1)
    name.rotation = playerSprite.rotation
    playerSprite.name = name

    return playerSprite
end

local function createOffense()
    activePlay = copyPlay(team.playbook.plays[1])

    for i = 1, 5 do
        local positions = activePlay.routes[i].points[1]
        local player = team.players[i]
        player.movement = {}
        player.sprite = createPlayer(player, positions, standingSheet, sequenceData, hoopCenter)

        local function changePlayer()
            if(playing) then
                local oldPlayer = userPlayer
                userPlayer = i

                team.players[oldPlayer].sprite:removeEventListener("tap", changePlayer)
                team.players[oldPlayer].hasBall = false
                
                team.players[userPlayer].hasBall = true
                local ballLoc = calculateBballLoc(team.players[userPlayer].sprite.rotation)
                transition.moveTo(basketball, {x=ballLoc.x, y=ballLoc.y, time=getDist(team.players[oldPlayer].sprite, team.players[userPlayer].sprite) * 3})
            end
        end

        player.sprite:addEventListener("tap", changePlayer)
    end

    team.players[userPlayer].hasBall = true
end

local function mapByFunction(offenseFunc, defenseFunc)
    local teamStarters = {unpack(team.players, 1, 5)}
    table.sort(teamStarters, offenseFunc)

    local opponentStarters = {unpack(opponent.players, 1, 5)}
    table.sort(opponentStarters, defenseFunc)

    for i = 1, 5 do
        local index = indexOf(team.players, teamStarters[i])
        opponent.players[index] = opponentStarters[i]
    end
end

local function setDefenseMatchups()
    if(activeDefense.coverage == "man") then
        local num = math.random(1, 3)

        if(num == 1) then
            mapByFunction(
                function (a, b) 
                    return a.speed > b.speed 
                end,
                function (a, b)
                    return a.speed > b.speed
                end
            )
        elseif(num == 2) then
            mapByFunction(
                function (a, b) 
                    return a.height > b.height 
                end,
                function (a, b)
                    return a.height > b.height
                end
            )
        elseif(num == 3) then
            mapByFunction(
                function (a, b) 
                    return (a.closeShot + a.midRange + a.three + a.finishing) > (b.closeShot + b.midRange + b.three + b.finishing)
                end,
                function (a, b)
                    return (a.contestingInterior + a.contestingExterior) > (b.contestingInterior + b.contestingExterior)
                end
            )
        end
    elseif(activeDefense.coverage == "zone") then
        local opponentStarters = {unpack(opponent.players, 1, 5)}

        if(activeDefense.name == "1-2-2") then
            -- 2 at baseline are tallest, 1 at top is best defender, 2 at wings are the 2 left over
            table.sort(opponentStarters, function (a, b)
                return a.height < b.height
            end)

            local max = {value = -1, index = -1}
            for i = 1, 3 do
                if(opponentStarters[i].contestingInterior + opponentStarters[i].contestingExterior > max.value) then
                    max.index = i
                    max.value = opponentStarters[i].contestingInterior + opponentStarters[i].contestingExterior
                end
            end

            local tmp = opponentStarters[1]
            opponentStarters[1] = opponentStarters[max.index]
            opponentStarters[max.index] = tmp
        elseif(activeDefense.name == "2-3") then
            table.sort(opponentStarters, function (a, b)
                return a.height < b.height
            end)
        end

        for i = 1, 5 do
            opponent.players[i] = opponentStarters[i]
        end
    end
end

local function createDefense()
    local playNum = math.random(1, #opponent.playbook.defensePlays)
    activeDefense = opponent.playbook.defensePlays[playNum]
    setDefenseMatchups()

    for i = 1, 5 do
        local positions = activeDefense.routes[i].points[1]
        local player = opponent.players[i]
        player.movement = {}
        player.sprite = createPlayer(player, positions, standingSheetBlue, sequenceDataBlue, team.players[i].sprite)
    end
end

local function controlClock()
    gameClockSubtract(1)

    if(gameDetails.shotClock > 0 and playing) then
        gameDetails.shotClock = gameDetails.shotClock - 1
    end

    if(gameDetails.shotClock == 0) then
        if(playing ~= false) then
            -- They didn't get the shot off in time
            playing = false
            result = "shot clock"
            endPossession()
        end
    end

    if(not endedPossession) then
        clearScoreboard()
        displayScoreboard()
        timer.performWithDelay(1000, controlClock)
    end
end

local function startGame()
    playing = true
    endedPossession = false
    result = ""
    gameDetails.shotClock = 18

    displayScoreboard()
    displayShotBar()
    displayPlays()
    displayNames()
    createJoystick()
    createOffense()
    createDefense()
    timer.performWithDelay(1000, controlClock)

    basketball = display.newImageRect(sceneGroup, "images/basketball.png", 15, 15)
    basketball.x = team.players[userPlayer].sprite.x
    basketball.y = team.players[userPlayer].sprite.y - 15

    Runtime:addEventListener("enterFrame", movePlayers)
end

function indexOf(table, value)
    for i = 1, #table do
        if(table[i] == value) then
            return i
        end
    end

    return -1
end

local function gameLoop()
    local allGames = league.schedule[league.weekNum]
    local gameInfo = league:findGameInfo(allGames, userTeam)
    team = league:findTeam(userTeam)
    
    if(gameInfo.home == userTeam) then
        opponent = league:findTeam(gameInfo.away)
    else
        userIsHome = false
        opponent = league:findTeam(gameInfo.home)
    end
    
    if(gameInProgress) then
        if(gameDetails.min == 0 and gameDetails.sec < 6) then
            gameClockSubtract(6)
        else
            gameClockSubtract(6)
            startGame()
        end
    else
        result = "game end"
        endPossession()
    end
end

local function setBackdrop()
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local backgroundImage = display.newImageRect(sceneGroup, "images/NbaCourt.png", 1000 * conversionFactor, 940 * conversionFactor)
    backgroundImage.x = display.contentCenterX
    backgroundImage.y = display.contentCenterY
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	-- Code here runs when the scene is first created but has not yet appeared on screen
    sceneGroup = self.view

    setBackdrop()
    gameLoop()
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
