local socket = require("socket")
local StickLib   = require("Objects.virtual_joystick")
local composer = require("composer")

local scene = composer.newScene()
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

offense = true
userPlayer = 3
basketball = nil
team = nil
opponent = nil

local standingData = {width=32, height=32, numFrames=1}
local standingSheet = graphics.newImageSheet("images/playerModels/TopDownStandingRed.png", standingData)

local movingData = {width=32, height=32, numFrames=4}
local movingSheet = graphics.newImageSheet("images/playerModels/TopDownWalkingRed.png", movingData)

local sequenceData = {
    {name="standing", sheet=standingSheet, start=1, count=1, time=750},
    {name="moving", sheet=movingSheet, start=1, count=4, time=750}
}

local holdingShoot = false
local start = 0
local maxTime = 2000
local deadzoneFactor = 3

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function shootTime()
    local current = socket.gettime() * 1000
    local diff = current - start

    if(diff < maxTime) then
        local height = 150.0 * diff / maxTime
        local powerBar = display.newRect(uiGroup, bounds.maxX + 22, -50 - height / 2, 25, height)
        powerBar:setStrokeColor(0, 0, 0, 0)
        powerBar:setFillColor(47 / 255.0, 209 / 255.0, 25 / 255.0)

        if(holdingShoot) then
            timer.performWithDelay(20, shootTime)
        end
    end
end

local function shootBall(event)
    if(event.phase == "began") then
        start = socket.gettime() * 1000
        holdingShoot = true
        timer.performWithDelay(20, shootTime)
    elseif (event.phase == "ended") then
        team.starters[userPlayer].hasBall = false
        holdingShoot = false
        local endTime = socket.gettime() * 1000
        local power = (endTime - start) / maxTime
        local dist = bounds.maxY * power * .9
        local rotation = 90 - getRotationToBasket(team.starters[userPlayer].sprite)

        local endPos = {x = 0, y = 0}
        local distToHoop = math.sqrt(math.pow(team.starters[userPlayer].sprite.x - hoopCenter.x, 2) + math.pow(team.starters[userPlayer].sprite.y - hoopCenter.y, 2))
        local deadzone = 15 -- default
        deadzone = deadzone + (team.starters[userPlayer].shooting * deadzoneFactor)
        print(math.abs(distToHoop - dist))
        print(deadzone)

        if(math.abs(distToHoop - dist) < deadzone) then
            endPos = {x = hoopCenter.x, y = hoopCenter.y}
        else
            endPos = {x = basketball.x + (dist * math.cos(math.rad(rotation))), y = basketball.y - (dist * math.sin(math.rad(rotation)))}
        end

        transition.moveTo(basketball, {x=endPos.x , y=endPos.y, time = dist * 4})
    end
end

function calculateBballLoc(angle)
    local x = team.starters[userPlayer].sprite.x + 15*math.cos(math.rad(90 - angle))
    local y = team.starters[userPlayer].sprite.y - 15*math.sin(math.rad(90 - angle))

    return {x=x, y=y}
end

function getRotationToBasket(position)
    local o = position.y - hoopCenter.y
    local a = position.x - hoopCenter.x
    local h = math.sqrt(o * o + a * a)
    return math.deg(math.acos(a / h)) - 90
end

local function controlPlayers()
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
        group = uiGroup,
    })

    -- Create shoot button
    local shootBtn = display.newImageRect(uiGroup, "images/basketball_shoot_btn.png", 75, 75)
    shootBtn.x = bounds.maxX + 25
    shootBtn.y = bounds.minY
    shootBtn:addEventListener("touch", shootBall)

    -- Create shot power bar
    local shootBtn = display.newRect(uiGroup, bounds.maxX + 22, -125, 25, 150)
    shootBtn:setStrokeColor(0, 0, 0)
    shootBtn:setFillColor(0, 0, 0, 0)
    shootBtn.strokeWidth = 2

    -- Create offensive players
    for i = 1, 5 do
        local play = team.playbook.plays[1]
        local positions = play.routes[i].points[1]
        local player = team.starters[i]

        local playerSprite = display.newSprite(mainGroup, standingSheet, sequenceData)
        playerSprite.x = tonumber(positions.x)
        playerSprite.y = tonumber(positions.y)
        playerSprite.rotation = getRotationToBasket(positions)
        playerSprite:play()
        player.sprite = playerSprite

        local function changePlayer()
            team.starters[userPlayer].hasBall = false
            userPlayer = i
            team.starters[userPlayer].hasBall = true
            local ballLoc = calculateBballLoc(team.starters[userPlayer].sprite.rotation)
            transition.moveTo(basketball, {x=ballLoc.x, y=ballLoc.y, time=1000})
        end

        playerSprite:addEventListener("tap", changePlayer)
    end

    team.starters[userPlayer].hasBall = true
    basketball = display.newImageRect(mainGroup, "images/basketball.png", 15, 15)
    basketball.x = team.starters[userPlayer].sprite.x
    basketball.y = team.starters[userPlayer].sprite.y - 15

    local function move()
        MyStick:move(team.starters[userPlayer].sprite, 1, team.starters[userPlayer].hasBall)
    end

    Runtime:addEventListener("enterFrame", move)
end

local function gameLoop()
    team = league:findTeam(userTeam)
    local gameInfo = team.schedule[league.gameNum]
    opponent = league:findTeam(gameInfo.opponent)

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
