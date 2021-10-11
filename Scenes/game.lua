local socket = require("socket")
local StickLib   = require("Objects.virtual_joystick")
local composer = require("composer")

local scene = composer.newScene()
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

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
userPlayer = 3
basketball = nil
team = nil
opponent = nil
userIsHome = true
activePlay = nil
activeDefense = nil

local holdingShoot = false
local start = 0
local maxTime = 1500
local playing = true -- Keeps track if a play is in progress or not. Don't allow user input after a play is over
local scoreboard = {away=nil, home=nil, qtr=nil, min=nil, sec=nil, shotClock=nil}
local result = ""

MyStick = nil
local minSpeed = 1.25
local speedScaling = .1
local nameFontSize = 8
local deadzoneBase = 10 -- default
local deadzoneFactor = 5
local contestRadius = 3 * feetToPixels -- 3 feet away
local finishingRadius = 4 * feetToPixels
local maxBlockedProb = 50

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
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
    Runtime:removeEventListener("touch", reset)
    composer.removeScene("Scenes.game")
    composer.gotoScene("Scenes.game")
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

local function endPossession()
    local background = display.newRect(uiGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local message = ""

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
    end

    local displayMessage = display.newText(uiGroup, message, display.contentCenterX, display.contentCenterY / 2, native.systemFont, 32)
    displayMessage:setFillColor(.922, .910, .329)

    Runtime:addEventListener("touch", reset)
end

local function shootTime()
    local current = socket.gettime() * 1000
    local diff = current - start

    if(diff < maxTime) then
        local height = 150.0 * diff / maxTime
        local powerBar = display.newRect(uiGroup, bounds.maxX + 45, 235 - height / 2, 25, height)
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

        if(math.floor(distance) <= feetToPixels) then
            distance = feetToPixels
        end

        if(distance < contestRadius) then
            -- Scale down based off of how close they are, height difference, and skill at defending
            local heightDiff = defender.height - shooter.height + 10 -- Will be from 0-20
            local contestSkill = defender.contesting * deadzoneFactor
            local distanceFactor = 1 / (distance / feetToPixels) -- Will be in the range of 1/3 - 1
            local factor = math.floor((heightDiff / 20) * distanceFactor * contestSkill)
            deadzone = deadzone - factor
        end
    end

    if(deadzone < 1) then
        deadzone = 1
    end

    return deadzone
end

local function calculateShotEndPosition(result, rotation, dist)
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

local function isBlocked(shooter)
    for i = 1, 5 do
        local defender = opponent.players[i]
        local distance = getDist(shooter.sprite, defender.sprite)

        if(math.floor(distance) <= feetToPixels) then
            distance = feetToPixels
        end

        if(distance < contestRadius) then
            -- Scale down based off of how close they are, height difference, and skill at defending
            local heightDiff = defender.height - shooter.height + 10 -- Will be from 0-20
            local contestSkill = defender.blocking * (maxBlockedProb / 10)
            local distanceFactor = 1 / (distance / feetToPixels) -- Will be in the range of 1/3 - 1
            local probability = (heightDiff / 20) * distanceFactor * contestSkill
            local num = math.random(100)

            if(num < probability) then
                return true
            end
        end
    end

    return false
end

local function finishShot()
    team.players[userPlayer].hasBall = false
    holdingShoot = false
    playing = false

    local endTime = socket.gettime() * 1000
    local power = (endTime - start) / maxTime
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

        local endPos = calculateShotEndPosition(result, rotation, dist)
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
    local shootBtn = display.newImageRect(uiGroup, "images/basketball_shoot_btn.png", 75, 75)
    shootBtn.x = bounds.maxX + 50
    shootBtn.y = bounds.maxY - 40
    shootBtn:addEventListener("touch", shootBall)

    -- Create shot power bar
    local shotBar = display.newRect(uiGroup, bounds.maxX + 45, 160, 25, 150)
    shotBar:setStrokeColor(0, 0, 0)
    shotBar:setFillColor(0, 0, 0, 0)
    shotBar.strokeWidth = 2
end

local function displayScoreboard()
    local scoreboardOutline = display.newRect(uiGroup, 27, 52, 78, 100)
    scoreboardOutline:setStrokeColor(0, 0, 0)
    scoreboardOutline:setFillColor(0, 0, 0, 0)
    scoreboardOutline.strokeWidth = 4

    local dividerVertical = display.newRect(uiGroup, 27, 52, 2, 100)
    dividerVertical:setStrokeColor(0, 0, 0, 0)
    dividerVertical:setFillColor(0, 0, 0)

    local awayLabel = display.newText(uiGroup, "Away", 9, 12, native.systemFont, 12)
    awayLabel:setFillColor(.922, .910, .329)

    local homeLabel = display.newText(uiGroup, "Home", 47, 12, native.systemFont, 12)
    homeLabel:setFillColor(.922, .910, .329)

    local dividerHorizontal = display.newRect(uiGroup, 27, 20, 78, 2)
    dividerHorizontal:setStrokeColor(0, 0, 0, 0)
    dividerHorizontal:setFillColor(0, 0, 0)

    scoreboard.away = display.newText(uiGroup, score.away, 9, 27, native.systemFont, 12)
    scoreboard.away:setFillColor(.922, .910, .329)

    scoreboard.home = display.newText(uiGroup, score.home, 47, 27, native.systemFont, 12)
    scoreboard.home:setFillColor(.922, .910, .329)
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

local function moveOffense()
    -- TODO
end

local function moveDefense()
    if(holdingShoot) then
        -- Have defender close out to shooter
        local player = opponent.players[userPlayer]
        move(player.sprite, minSpeed + (player.speed * speedScaling), team.players[userPlayer].sprite, getRotation(player.sprite, team.players[userPlayer].sprite), 1)
    elseif(activeDefense.coverage == "zone") then
        -- TODO
    elseif(activeDefense.coverage == "man") then
        -- Move player defending ball handler
        local player = opponent.players[userPlayer]
        local shooter = team.players[userPlayer]
        local rotationToBasket = getRotationToBasket(shooter.sprite)
        local distAway = math.abs(activeDefense.aggresiveness - 6) * feetToPixels -- Distance away that defender should stand
        local distToBasket = getDist(shooter.sprite, hoopCenter)

        if(distAway > distToBasket) then
            distAway = distToBasket / 2
        end

        local newPos = {x = shooter.sprite.x + (math.cos(math.rad(rotationToBasket - 90)) * distAway),
                        y = shooter.sprite.y + (math.sin(math.rad(rotationToBasket - 90)) * distAway)}
        local newAngle = getRotation(player.sprite, newPos)
        local percent = getDist(player.sprite, newPos) / (minSpeed + (player.speed * speedScaling))

        if(getDist(player.sprite, newPos) < .1 * feetToPixels and MyStick.percent == 0) then
            percent = 0
        elseif(getDist(player.sprite, newPos) < .1 * feetToPixels and MyStick.percent ~= 0) then
            percent = .001
        elseif(percent > 1) then
            percent = 1
        end

        move(player.sprite, minSpeed + (player.speed * speedScaling), shooter.sprite, newAngle, percent)
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
    local playerSprite = display.newSprite(mainGroup, standingSequenceData, movingSequenceData)
    playerSprite.x = tonumber(positions.x)
    playerSprite.y = tonumber(positions.y)
    playerSprite.rotation = getRotation(positions, pointTowards)
    playerSprite:play()

    local name = display.newText(uiGroup, getInitials(player.name), positions.x, positions.y, native.systemFont, nameFontSize)
    name:setFillColor(1, 1, 1)
    name.rotation = playerSprite.rotation
    playerSprite.name = name

    return playerSprite
end

local function createOffense()
    activePlay = team.playbook.plays[1]

    for i = 1, 5 do
        local positions = activePlay.routes[i].points[1]
        local player = team.players[i]
        player.sprite = createPlayer(player, positions, standingSheet, sequenceData, hoopCenter)

        local function changePlayer()
            if(playing) then
                team.players[userPlayer].hasBall = false
                local oldPlayer = userPlayer
                userPlayer = i
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

local function controlPlayers()
    playing = true
    displayScoreboard()
    displayShotBar()
    createJoystick()
    createOffense()
    createDefense()    

    basketball = display.newImageRect(mainGroup, "images/basketball.png", 15, 15)
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

    controlPlayers()
end

local function setBackdrop()
    local background = display.newRect(backGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local backgroundImage = display.newImageRect(backGroup, "images/NbaCourt.png", 1000 * conversionFactor, 940 * conversionFactor)
    backgroundImage.x = display.contentCenterX
    backgroundImage.y = display.contentCenterY
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	-- Code here runs when the scene is first created but has not yet appeared on screen
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
