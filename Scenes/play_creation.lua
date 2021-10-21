local RouteLib = require("Objects.route")
local PlayLib = require("Objects.play")
local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local team = nil
local inBounds = true
local routes = {nil}
for i = 1, 5 do
    routes[i] = RouteLib:createRoute(startPositionsOffense[i].x, startPositionsOffense[i].y, i)
end

local standingData = {width=32, height=32, numFrames=1}
local standingSheet = graphics.newImageSheet("images/playerModels/TopDownStandingRed.png", standingData)

local movingData = {width=32, height=32, numFrames=4}
local movingSheet = graphics.newImageSheet("images/playerModels/TopDownWalkingRed.png", movingData)

local sequenceData = {
    {name="standing", sheet=standingSheet, start=1, count=1, time=750},
    {name="moving", sheet=movingSheet, start=1, count=4, time=750}
}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
function nextScene()
	composer.removeScene("Scenes.play_creation")
    composer.gotoScene("Scenes.pregame")
end

function clearScreen()
    composer.removeScene("Scenes.play_creation")
    composer.gotoScene("Scenes.play_creation")
end

function saveRoute()
    local play = PlayLib:createPlay(routes, "BI6")
    table.insert(team.playbook.plays, play)
    clearScreen()
end

local function chooseColor(circle, i)
    if(i == 1) then
        circle:setFillColor(0, 0, .5, .25)
    elseif(i == 2) then
        circle:setFillColor(1, 0, 0, .25)
    elseif(i == 3) then
        circle:setFillColor(0, 1, 0, .25)
    elseif(i == 4)  then
        circle:setFillColor(1, 0, 1, .25)
    else
        circle:setFillColor(1, 1, 0, .25)
    end
end

local function touchEvent(event, i)
    if(event.phase == "began") then
        display.getCurrentStage():setFocus(event.target, event.id)
        routes[i] = RouteLib:createRoute(startPositionsOffense[i].x, startPositionsOffense[i].y, i)
        inBounds = true
    elseif(event.phase == "moved") then
        if(event.x <= bounds.minX or event.x >= bounds.maxX or event.y <= bounds.minY or event.y >= bounds.maxY) then
            inBounds = false
        end

        if(inBounds) then
            local circle = display.newCircle(sceneGroup, event.x, event.y, 10)
            chooseColor(circle, i)
            table.insert(routes[i].points, {x=event.x, y=event.y})
        end
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        display.getCurrentStage():setFocus(event.target, nil)
    end
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

local function createPlayer(positions, standingSequenceData, movingSequenceData, pointTowards)
    local playerSprite = display.newSprite(sceneGroup, standingSequenceData, movingSequenceData)
    playerSprite.x = tonumber(positions.x)
    playerSprite.y = tonumber(positions.y)
    playerSprite.rotation = getRotation(positions, pointTowards)

    return playerSprite
end

local function createOffense()
    activePlay = team.playbook.plays[1]

    for i = 1, 5 do
        local positions = activePlay.routes[i].points[1]
        local sprite = createPlayer(positions, standingSheet, sequenceData, hoopCenter)

        local function drawRoute(event)
            touchEvent(event, i)
        end

        sprite:addEventListener("touch", drawRoute)
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

    local backButton = display.newText(sceneGroup, "<- Back", 8, 10, native.systemFont, 16)
    backButton:setFillColor(0, 0, 0)
    backButton:addEventListener("tap", nextScene)

    local backButtonBorder = display.newRect(sceneGroup, backButton.x, backButton.y, backButton.width, backButton.height)
    backButtonBorder:setStrokeColor(0, 0, 0)
    backButtonBorder.strokeWidth = 2
    backButtonBorder:setFillColor(0, 0, 0, 0)
    backButtonBorder:addEventListener("tap", nextScene)

    local clearButton = display.newText(sceneGroup, "Clear", 8, 50, native.systemFont, 16)
    clearButton:setFillColor(0, 0, 0)
    clearButton:addEventListener("tap", clearScreen)

    local clearButtonBorder = display.newRect(sceneGroup, clearButton.x, clearButton.y, clearButton.width, clearButton.height)
    clearButtonBorder:setStrokeColor(0, 0, 0)
    clearButtonBorder.strokeWidth = 2
    clearButtonBorder:setFillColor(0, 0, 0, 0)
    clearButtonBorder:addEventListener("tap", clearScreen)

    local saveButton = display.newText(sceneGroup, "Save", 8, 90, native.systemFont, 16)
    saveButton:setFillColor(0, 0, 0)
    saveButton:addEventListener("tap", saveRoute)

    local saveButtonBorder = display.newRect(sceneGroup, saveButton.x, saveButton.y, saveButton.width, saveButton.height)
    saveButtonBorder:setStrokeColor(0, 0, 0)
    saveButtonBorder.strokeWidth = 2
    saveButtonBorder:setFillColor(0, 0, 0, 0)
    saveButtonBorder:addEventListener("tap", saveRoute)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view
    team = league:findTeam(userTeam)

	-- Code here runs when the scene is first created but has not yet appeared on screen
    setBackdrop()
    createOffense()
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
