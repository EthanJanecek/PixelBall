local composer = require( "composer" )
local scene = composer.newScene()
local sceneGroup = nil

local scoreboard = {away=nil, home=nil, qtr=nil, time=nil, shotClock=nil}
local reSim = false

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function offense()
    composer.gotoScene("Scenes.game")
end

local function changeLineup()
    composer.gotoScene("Scenes.lineup")
    return true
end

local function createPlays()
    composer.gotoScene("Scenes.play_creation")
    return true
end

local function setDefense()
    composer.gotoScene("Scenes.set_defense")
    return true
end

local function gameClockSubtract(time)
    if(time > gameDetails.sec) then
        gameDetails.sec = gameDetails.sec - time + 60
        gameDetails.min = gameDetails.min - 1
    else
        gameDetails.sec = gameDetails.sec - time
    end

    if(gameDetails.min < 0) then
        insertQtrScore()
        gameDetails.min = minutesInQtr
        gameDetails.sec = 0
        gameDetails.qtr = gameDetails.qtr + 1
        

        if(gameDetails.qtr >= 5) then
            if(score.home ~= score.away) then
                gameInProgress = false
            else
                if(minutesInQtr >= 5) then
                    gameDetails.min = 5
                end
            end
        end

        return true
    end

    return false
end

local function displayScore()
    local dividerVertical = display.newRect(sceneGroup, 25 + (2 / 2), 40/2, 2, 40)
    dividerVertical:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    dividerVertical:setFillColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])

    local homeStr = opponent.abbrev
    local awayStr = team.abbrev

    if(userIsHome) then
        homeStr = team.abbrev
        awayStr = opponent.abbrev
    end

    local awayLabel = display.newText(sceneGroup, awayStr, 9, 12, native.systemFont, 12)
    awayLabel:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local homeLabel = display.newText(sceneGroup, homeStr, 47, 12, native.systemFont, 12)
    homeLabel:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local scoreLabelDividerHorizontal = display.newRect(sceneGroup, 25 + (2 / 2), 20, 78, 2)
    scoreLabelDividerHorizontal:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    scoreLabelDividerHorizontal:setFillColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])

    scoreboard.away = display.newText(sceneGroup, score.away, 9, 27, native.systemFont, 12)
    scoreboard.away:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    scoreboard.home = display.newText(sceneGroup, score.home, 47, 27, native.systemFont, 12)
    scoreboard.home:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local scoreDividerHorizontal = display.newRect(sceneGroup, 25 + (8 / 2), 40, 78, 8)
    scoreDividerHorizontal:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    scoreDividerHorizontal:setFillColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
end

local function displayTime()
    scoreboard.time = display.newText(sceneGroup, string.format("%02d", gameDetails.min) .. ":" .. string.format("%02d", gameDetails.sec), 25, 33 + 24, native.systemFont, 24)
    scoreboard.time:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    dividerHorizontal = display.newRect(sceneGroup, 25 + (2 / 2), 70, 78, 2)
    dividerHorizontal:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    dividerHorizontal:setFillColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])

    local dividerVertical = display.newRect(sceneGroup, 25 + (2 / 2), 70 + (30 / 2), 2, 30)
    dividerVertical:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    dividerVertical:setFillColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])

    scoreboard.qtr = display.newText(sceneGroup, getQuarterString(), 9, 65 + 20, native.systemFont, 20)
    scoreboard.qtr:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    scoreboard.shotClock = display.newText(sceneGroup, string.format("%02d", gameDetails.shotClock), 47, 65 + 20, native.systemFont, 20)
    scoreboard.shotClock:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end

local function displayScoreboard()
    local scoreboardOutline = display.newRect(sceneGroup, 27, 52, 78, 100)
    scoreboardOutline:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    scoreboardOutline:setFillColor(TRANSPARENT[1], TRANSPARENT[2], TRANSPARENT[3], TRANSPARENT[4])
    scoreboardOutline.strokeWidth = 4

    displayScore()
    displayTime()
end

local function simulateDefense()
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    if(reSim) then
        local ranOutOfTime = gameClockSubtract(6)

        if(ranOutOfTime) then
            local message = opponent.abbrev .. " didn't get the shot off in time"
            local displayMessage = display.newText(sceneGroup, message, display.contentCenterX, display.contentCenterY * .75, native.systemFont, 20)
            displayMessage:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

            displayScoreboard()
        else
            local playResult = simulatePossession(opponent, team, defensiveStrategy)
            local points = playResult.points

            if(userIsHome) then
                score.away = score.away + points
            else
                score.home = score.home + points
            end

            local message = playResult.player.name .. " (" .. opponent.abbrev .. ") scored " .. points .. " points"
            local displayMessage = display.newText(sceneGroup, message, display.contentCenterX, display.contentCenterY * .75, native.systemFont, 20)
            displayMessage:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

            local message2 = playResult.message .. " by " .. playResult.defender.name
            local displayMessage2 = display.newText(sceneGroup, message2, display.contentCenterX, display.contentCenterY * .95, native.systemFont, 20)
            displayMessage2:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

            gameClockSubtract(playResult.time - 6)
            displayScoreboard()
        end
    end  

    createButtonWithBorder(sceneGroup, "Change Lineup", 32, display.contentCenterX, display.contentCenterY * 1.2, 2, 
            TEXT_COLOR, TEXT_COLOR, TRANSPARENT, changeLineup)
    createButtonWithBorder(sceneGroup, "Create Plays", 32, display.contentCenterX, display.contentCenterY * 1.5, 2, 
            TEXT_COLOR, TEXT_COLOR, TRANSPARENT, createPlays)
    createButtonWithBorder(sceneGroup, "Set Defense", 32, display.contentCenterX, display.contentCenterY * 1.8, 2, 
            TEXT_COLOR, TEXT_COLOR, TRANSPARENT, setDefense)

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
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    if(event.params and event.params.reSim) then
        reSim = true
    end

    simulateDefense()
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
        local previous = composer.getSceneName("previous")
		composer.removeScene(previous)
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
