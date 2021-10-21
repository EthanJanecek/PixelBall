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

local holdingShoot = false
local start = 0
local maxTime = 1250
local playing = true -- Keeps track if a play is in progress or not. Don't allow user input after a play is over
local endedPossession = false -- Keeps track of if the possession is still active. Is basically playing but with the time to shoot
local scoreboard = {away=nil, home=nil, qtr=nil, time=nil, shotClock=nil}
local result = ""

MyStick = nil
local minSpeed = 1.25
local speedScaling = .1
local nameFontSize = 8
local deadzoneBase = 5 -- default
local deadzoneFactor = 3
local deadzoneMin = 4
local contestRadius = 3 * feetToPixels -- 3 feet away
local finishingRadius = 4 * feetToPixels
local maxBlockedProb = 30

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
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

function move(Obj, maxSpeed, pointTowards, angle, percent)
    local newX = Obj.x + math.cos(math.rad(angle-90)) * (maxSpeed * percent)
    local newY = Obj.y + math.sin(math.rad(angle-90)) * (maxSpeed * percent)

    if(percent == 0) then
        if(not Obj.isPlaying or Obj.sequence == "moving") then
            Obj:setSequence("standing")
            Obj:play()
        end

        Obj.rotation = getRotation(Obj, pointTowards)
    elseif(newX >= bounds.minX and newX <= bounds.maxX and newY >= bounds.minY and newY <= bounds.maxY) then
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
end

local function reset()
    Runtime:removeEventListener("enterFrame", movePlayers)
    Runtime:removeEventListener("tap", reset)
    composer.removeScene("Scenes.game")

    if(gameInProgress) then
        composer.gotoScene("Scenes.game")
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
        return "4th"
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

local function simulateDefense()
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local playResult = simulatePossession(opponent, team)
    local points = playResult.points
    local timeUsed = playResult.time

    if(userIsHome) then
        score.away = score.away + points
    else
        score.home = score.home + points
    end

    if(timeUsed > gameDetails.sec) then
        gameDetails.sec = gameDetails.sec - timeUsed + 60
        gameDetails.min = gameDetails.min - 1
    else
        gameDetails.sec = gameDetails.sec - timeUsed
    end

    if(gameDetails.min < 0) then
        gameDetails.qtr = gameDetails.qtr + 1
        gameDetails.min = 12
        gameDetails.sec = 0
        
        if(gameDetails.qtr == 5) then
            gameInProgress = false
        end
    end

    local message = opponent.abbrev .. " scored " .. points .. " points"
    local displayMessage = display.newText(sceneGroup, message, display.contentCenterX, display.contentCenterY, native.systemFont, 32)
    displayMessage:setFillColor(.922, .910, .329)
    displayScoreboard()
    Runtime:addEventListener("tap", reset)
end

local function getDist(a, b)
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

local function nextMenu()
    Runtime:removeEventListener("tap", nextMenu)
    timer.performWithDelay(250, simulateDefense)
end

local function endPossession()
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
    elseif(result == "3") then
        if(userIsHome) then
            score.home = score.home + 3
        else
            score.away = score.away + 3
        end

        message = "The 3 is good!"
    elseif(result == "Miss") then
        message = "The shot is no good!"
    elseif(result == "Blocked") then
        message = "The shot is blocked!"
    elseif(result == "shot clock") then
        message = "The shot clock has expired"
    elseif(result == "qtr end") then
        message = "The " .. getQuarterString() .. " quarter has ended"
    elseif(result == "game end") then
        message = "The game has ended"
        gameInProgress = false
    end

    local displayMessage = display.newText(sceneGroup, message, display.contentCenterX, display.contentCenterY, native.systemFont, 32)
    displayMessage:setFillColor(.922, .910, .329)
    displayScoreboard()

    Runtime:addEventListener("tap", nextMenu)
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
    deadzone = deadzone + (skill * deadzoneFactor)

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
            if(heightDiff < 7.5) then
                heightDiff = 7.5
            elseif(heightDiff > 12.5) then
                heightDiff = 12.5
            end

            local contestSkill = defender.contesting * deadzoneFactor
            local distanceFactor = feetToPixels / distance -- Will be in the range of 1/3 - 2
            local factor = (heightDiff / 10) * distanceFactor * contestSkill
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
            if(heightDiff < 7.5) then
                heightDiff = 7.5
            elseif(heightDiff > 12.5) then
                heightDiff = 12.5
            end

            local contestSkill = defender.blocking * (maxBlockedProb / 10)
            local distanceFactor = feetToPixels / distance -- Will be in the range of 1/3 - 2
            local probability = (heightDiff / 10) * distanceFactor * contestSkill
            local num = math.random(100)

            if(num < probability) then
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

    local dist = bounds.maxY * power * .75
    local rotation = 90 - getRotationToBasket(team.players[userPlayer].sprite)

    local distToHoop = getDist(team.players[userPlayer].sprite, hoopCenter)
    local blocked = isBlocked(team.players[userPlayer])

    if(blocked) then
        result = "Blocked"
        transition.moveTo(basketball, {x=team.players[userPlayer].sprite.x , y=team.players[userPlayer].sprite.y, time = 1, onComplete=endPossession})
    else
        local deadzone = 0

        if(distToHoop < finishingRadius) then
            deadzone = calculateDeadzone(team.players[userPlayer], team.players[userPlayer].finishing)
        else
            deadzone = calculateDeadzone(team.players[userPlayer], team.players[userPlayer].shooting)
        end

        if(math.abs(distToHoop - dist) <= deadzone) then
            result = calculateShotPoints()
        else
            result = "Miss"
        end

        local endPos = calculateShotEndPosition(rotation, dist)
        transition.moveTo(basketball, {x=endPos.x , y=endPos.y, time = dist * 3, onComplete=endPossession})
    end
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

function getInitials(name)
    local initials = ""
    local i = 0

    for param in string.gmatch(name, "([^ ]+)") do
        initials = initials .. string.sub(param, 1, 1)

        i = i + 1

        if(i >= 2) then
            break
        end
    end

    return initials
end

-- local function calculateEndPointMovement(player, route)
--     local maxDist = minSpeed + (player.speed * speedScaling)
--     local nextPoint = route.points[1]
--     local distToNext = getDist(player.sprite, nextPoint)

--     local newAngle = getRotation(player.sprite, nextPoint)
--     local percent = distToNext / maxDist

--     if(distToNext < .1 * feetToPixels) then
--         table.remove(route.points, 1)
--         percent = .001
--     elseif(percent > 1) then
--         percent = 1
--     end

--     move(player.sprite, minSpeed + (player.speed * speedScaling), hoopCenter, newAngle, percent)
-- end

local function calculateEndPointMovement(player, route)
    local maxDist = minSpeed + (player.speed * speedScaling)
    local nextPoint = route.points[1]
    local distToNext = getDist(player.sprite, nextPoint)

    while(route.points[1] and distToNext < .1 * feetToPixels) do
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
        percent = 0
    elseif(distToNext < .1 * feetToPixels) then
        table.remove(route.points, 1)
        percent = .001
    elseif(percent > 1) then
        percent = 1
    end
    
    move(player.sprite, minSpeed + (player.speed * speedScaling), hoopCenter, newAngle, percent)
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
                    move(player.sprite, minSpeed + (player.speed * speedScaling), hoopCenter, 0, 0)
                end
            else
                activePlay.routes[i].points = {nil}
            end
        end
    end
end

local function defenderCloseOut(defender, shooter, distAway)
    local rotationToBasket = getRotationToBasket(shooter.sprite)
    local distToBasket = getDist(shooter.sprite, hoopCenter)

    if(distAway > distToBasket) then
        distAway = distToBasket / 2
    end

    local newPos = {x = shooter.sprite.x + (math.cos(math.rad(rotationToBasket - 90)) * distAway),
                    y = shooter.sprite.y + (math.sin(math.rad(rotationToBasket - 90)) * distAway)}
    local newAngle = getRotation(defender.sprite, newPos)
    local percent = getDist(defender.sprite, newPos) / (minSpeed + (defender.speed * speedScaling))

    if(getDist(defender.sprite, newPos) < .1 * feetToPixels and shooter.sprite.sequence == "standing") then
        percent = 0
    elseif(getDist(defender.sprite, newPos) < .1 * feetToPixels) then
        percent = .001
    elseif(percent > 1) then
        percent = 1
    end

    move(defender.sprite, minSpeed + (defender.speed * speedScaling), shooter.sprite, newAngle, percent)
end

local function moveDefense()
    if(activeDefense.coverage == "zone") then
        -- TODO
    elseif(activeDefense.coverage == "man") then
        -- Move players
        local distAway = math.abs(activeDefense.aggresiveness - 6) * feetToPixels -- Distance away that defender should stand

        for i = 1, 5 do
            defenderCloseOut(opponent.players[i], team.players[i], distAway)
        end
    end
end

local function movePlayers()
    if(playing) then
        local player = team.players[userPlayer]
        MyStick:move(player.sprite, minSpeed + (player.speed * speedScaling), player.hasBall, hoopCenter)

        moveOffense()
        moveDefense()
    end
end

local function createJoystick()
    MyStick = StickLib.NewStick({
        x = display.contentWidth * .055,
        y = display.contentHeight * .85,
        thumbSize = 8,
        borderSize = 16,
        snapBackSpeed = .2,
        R = 25,
        G = 255,
        B = 255,
        group = display.newGroup(),
    })
end

local function createPlayer(player, positions, standingSequenceData, movingSequenceData, pointTowards)
    local playerSprite = display.newSprite(sceneGroup, standingSequenceData, movingSequenceData)
    playerSprite.x = tonumber(positions.x)
    playerSprite.y = tonumber(positions.y)
    playerSprite.rotation = getRotation(positions, pointTowards)
    playerSprite:play()

    local name = display.newText(sceneGroup, getInitials(player.name), positions.x, positions.y, native.systemFont, nameFontSize)
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

local function createDefense()
    activeDefense = opponent.playbook.defensePlays[1]

    for i = 1, 5 do
        local positions = activeDefense.routes[i].points[1]
        local player = opponent.players[i]
        player.sprite = createPlayer(player, positions, standingSheetBlue, sequenceDataBlue, team.players[i].sprite)
    end
end

local function controlClock()
    gameDetails.sec = gameDetails.sec - 1

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
        if(gameDetails.sec < 0) then
            gameDetails.sec = 59
            gameDetails.min = gameDetails.min - 1

            if(gameDetails.min < 0) then
                if(gameDetails.qtr > 4) then
                    playing = false
                    result = "game end"
                    endPossession()
                else
                    playing = false
                    gameDetails.min = 12
                    gameDetails.sec = 0
                    gameDetails.qtr = gameDetails.qtr + 1
                    result = "qtr end"
                    endPossession()
                end
            end
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
    gameDetails.shotClock = 24

    displayScoreboard()
    displayShotBar()
    displayPlays()
    createJoystick()
    createOffense()
    createDefense()
    timer.performWithDelay(1000, controlClock)

    basketball = display.newImageRect(sceneGroup, "images/basketball.png", 15, 15)
    basketball.x = team.players[userPlayer].sprite.x
    basketball.y = team.players[userPlayer].sprite.y - 15

    Runtime:addEventListener("enterFrame", movePlayers)
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
    
    startGame()
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
