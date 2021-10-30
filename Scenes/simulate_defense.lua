local composer = require( "composer" )
local scene = composer.newScene()
local sceneGroup = nil

local scoreboard = {away=nil, home=nil, qtr=nil, time=nil, shotClock=nil}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function offense()
    composer.removeScene("Scenes.simulate_defense")
    composer.gotoScene("Scenes.game")
end

local function changeLineup()
    composer.removeScene("Scenes.simulate_defense")
    composer.gotoScene("Scenes.lineup")
    return true
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

        if(gameDetails.qtr == 5) then
            gameInProgress = false
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

local function simulateDefense()    
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local playResult = simulatePossession(opponent, team)
    local points = playResult.points
    gameClockSubtract(playResult.time)

    if(userIsHome) then
        score.away = score.away + points
    else
        score.home = score.home + points
    end

    local message = opponent.abbrev .. " scored " .. points .. " points"
    local displayMessage = display.newText(sceneGroup, message, display.contentCenterX, display.contentCenterY, native.systemFont, 32)
    displayMessage:setFillColor(.922, .910, .329)
    displayScoreboard()

    local lineupButton = display.newText(sceneGroup, "Change Lineup", display.contentCenterX, display.contentCenterY * 1.3, native.systemFont, 32)
    lineupButton:setFillColor(0, 0, 0)
    lineupButton:addEventListener("tap", changeLineup)

    local lineupButtonBorder = display.newRect(sceneGroup, lineupButton.x, lineupButton.y, lineupButton.width, lineupButton.height)
    lineupButtonBorder:setStrokeColor(0, 0, 0)
    lineupButtonBorder.strokeWidth = 2
    lineupButtonBorder:setFillColor(0, 0, 0, 0)
    lineupButtonBorder:addEventListener("tap", changeLineup)

    background:addEventListener("tap", offense)
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    simulateDefense()
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
