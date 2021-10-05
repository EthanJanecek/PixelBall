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

local holdingShoot = false
local start = 0
local maxTime = 2000
local deadzoneFactor = 3
local playing = true -- Keeps track if a play is in progress or not. Don't allow user input after a play is over
local scoreboard = {away=nil, home=nil, qtr=nil, min=nil, sec=nil, shotClock=nil}
local result = ""

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function reset()
    Runtime:removeEventListener("touch", reset)
    composer.removeScene("Scenes.game")
    composer.gotoScene("Scenes.game")
end

local function getDist(a, b)
    return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))
end

local function calculateShot()
    local angle = getRotationToBasket(team.starters[userPlayer].sprite)
    local dist = 23.75

    if(angle > (90 - 24.44) or angle < (-90 + 24.44)) then
        dist = 22
    end

    if(getDist(team.starters[userPlayer].sprite, hoopCenter) < (dist * 20 * conversionFactor)) then
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

local function shootBall(event)
    if(playing) then
        if(event.phase == "began") then
            start = socket.gettime() * 1000
            holdingShoot = true
            timer.performWithDelay(20, shootTime)
        elseif (event.phase == "ended") then
            team.starters[userPlayer].hasBall = false
            holdingShoot = false
            playing = false
            local endTime = socket.gettime() * 1000
            local power = (endTime - start) / maxTime
            local dist = bounds.maxY * power * .9
            local rotation = 90 - getRotationToBasket(team.starters[userPlayer].sprite)
    
            local endPos = {x = 0, y = 0}
            local distToHoop = getDist(team.starters[userPlayer].sprite, hoopCenter)
            local deadzone = 15 -- default
            deadzone = deadzone + (team.starters[userPlayer].shooting * deadzoneFactor)
    
            if(math.abs(distToHoop - dist) < deadzone) then
                result = calculateShot()
                endPos = {x = hoopCenter.x, y = hoopCenter.y}
            else
                result = "Miss"
                endPos = {x = basketball.x + (dist * math.cos(math.rad(rotation))), y = basketball.y - (dist * math.sin(math.rad(rotation)))}
    
                if(endPos.y < 0) then
                    endPos.y = 0
                end
    
                if(endPos.x > bounds.maxX) then
                    endPos.x = bounds.maxX
                elseif(endPos.x < bounds.minX) then
                    endPos.x = bounds.minX
                end
            end
    
            transition.moveTo(basketball, {x=endPos.x , y=endPos.y, time = dist * 3, onComplete=endPossession})
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
    local x = team.starters[userPlayer].sprite.x + 15*math.cos(math.rad(90 - angle))
    local y = team.starters[userPlayer].sprite.y - 15*math.sin(math.rad(90 - angle))

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

local function controlPlayers()
    -- Create scoreboard
    displayScoreboard()
    playing = true

    -- CREATE ANALOG STICK
    MyStick = StickLib.NewStick( 
        {
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

    -- Create shot button and power bar
    displayShotBar()

    -- Create offensive players
    for i = 1, 5 do
        local play = opponent.playbook.plays[1]
        local positions = play.routes[i].points[1]
        local player = team.starters[i]

        local playerSprite = display.newSprite(mainGroup, standingSheet, sequenceData)
        playerSprite.x = tonumber(positions.x)
        playerSprite.y = tonumber(positions.y)
        playerSprite.rotation = getRotationToBasket(positions)
        playerSprite:play()
        player.sprite = playerSprite

        local function changePlayer()
            if(playing) then
                team.starters[userPlayer].hasBall = false
                local oldPlayer = userPlayer
                userPlayer = i
                team.starters[userPlayer].hasBall = true
                local ballLoc = calculateBballLoc(team.starters[userPlayer].sprite.rotation)
                transition.moveTo(basketball, {x=ballLoc.x, y=ballLoc.y, time=getDist(team.starters[oldPlayer].sprite, team.starters[userPlayer].sprite) * 3})
            end
        end

        playerSprite:addEventListener("tap", changePlayer)
    end

    -- Create defensive players
    for i = 1, 5 do
        local play = opponent.playbook.defensePlays[1]
        local positions = play.routes[i].points[1]
        local player = opponent.starters[i]

        local playerSprite = display.newSprite(mainGroup, standingSheetBlue, sequenceDataBlue)
        playerSprite.x = tonumber(positions.x)
        playerSprite.y = tonumber(positions.y)
        playerSprite.rotation = getRotation(positions, team.starters[i].sprite)
        playerSprite:play()
        player.sprite = playerSprite
    end

    team.starters[userPlayer].hasBall = true
    basketball = display.newImageRect(mainGroup, "images/basketball.png", 15, 15)
    basketball.x = team.starters[userPlayer].sprite.x
    basketball.y = team.starters[userPlayer].sprite.y - 15

    local function move()
        if(playing) then
            MyStick:move(team.starters[userPlayer].sprite, 1.75, team.starters[userPlayer].hasBall)
        end
    end

    Runtime:addEventListener("enterFrame", move)
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
