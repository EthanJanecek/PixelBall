
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
	local allGames = nil
    if(regularSeason) then
        allGames = league.schedule[league.weekNum]
    else
        allGames = league.playoffs[league.weekNum]
    end

    local gameInfo = league:findGameInfo(allGames, userTeam)
	local team = league:findTeam(userTeam)

	if(not regularSeason) then
		team = league:findPlayoffTeam(userTeam)
	end

	local titleStr = ""

	if(gameInfo and score.away) then
		gameInfo.score = score
		
		if(gameInfo.home == userTeam) then
			local opponent = league:findTeam(gameInfo.away)

			if(not regularSeason) then
				opponent = league:findPlayoffTeam(gameInfo.away)
			end

			if(score.home > score.away) then
				team.wins = team.wins + 1
				opponent.losses = opponent.losses + 1
			else
				team.losses = team.losses + 1
				opponent.wins = opponent.wins + 1
			end
		else
			local opponent = league:findTeam(gameInfo.home)

			if(not regularSeason) then
				opponent = league:findPlayoffTeam(gameInfo.home)
			end

			if(score.home > score.away) then
				titleStr = "You lost " .. score.home .. " - " .. score.away
				team.losses = team.losses + 1
				opponent.wins = opponent.wins + 1
			else
				titleStr = "You won " .. score.home .. " - " .. score.away
				team.wins = team.wins + 1
				opponent.losses = opponent.losses + 1
			end
		end
	end

	league:nextWeek()
	composer.removeScene("Scenes.postgame")
    composer.gotoScene("Scenes.score_recap")
end

local function boxScoreScene()
	composer.removeScene("Scenes.postgame")
    composer.gotoScene("Scenes.boxscore")
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
	local allGames = nil
    if(regularSeason) then
        allGames = league.schedule[league.weekNum]
    else
        allGames = league.playoffs[league.weekNum]
    end

    local gameInfo = league:findGameInfo(allGames, userTeam)
	local team = league:findTeam(userTeam)
	local titleStr = ""

	if(gameInfo and score.away) then
		gameInfo.score = score
		
		if(gameInfo.home == userTeam) then
			local opponent = league:findTeam(gameInfo.away)

			if(score.home > score.away) then
				titleStr = "You won " .. score.home .. " - " .. score.away
			else
				titleStr = "You lost " .. score.home .. " - " .. score.away
			end
		else
			local opponent = league:findTeam(gameInfo.home)

			if(score.home > score.away) then
				titleStr = "You lost " .. score.home .. " - " .. score.away
			else
				titleStr = "You won " .. score.home .. " - " .. score.away
			end
		end
	end

	local title = display.newText(sceneGroup, titleStr, display.contentCenterX, display.contentCenterY / 2, native.systemFont, 48)
    title:setFillColor(.922, .910, .329)
	
	local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local playButton = display.newText(sceneGroup, "Next Game", display.contentCenterX, display.contentCenterY * .9, native.systemFont, 32)
    playButton:setFillColor(0, 0, 0)
    playButton:addEventListener("tap", nextScene)

	local buttonBorder = display.newRect(sceneGroup, playButton.x, playButton.y, playButton.width, playButton.height)
	buttonBorder:setStrokeColor(0, 0, 0)
	buttonBorder.strokeWidth = 2
	buttonBorder:setFillColor(0, 0, 0, 0)
	buttonBorder:addEventListener("tap", nextScene)

	if(#qtrScores > 0) then
		local boxScoreButton = display.newText(sceneGroup, "Box Score", display.contentCenterX, display.contentCenterY * 1.3, native.systemFont, 32)
		boxScoreButton:setFillColor(0, 0, 0)
		boxScoreButton:addEventListener("tap", boxScoreScene)

		local boxScoreButtonBorder = display.newRect(sceneGroup, boxScoreButton.x, boxScoreButton.y, boxScoreButton.width, boxScoreButton.height)
		boxScoreButtonBorder:setStrokeColor(0, 0, 0)
		boxScoreButtonBorder.strokeWidth = 2
		boxScoreButtonBorder:setFillColor(0, 0, 0, 0)
		boxScoreButtonBorder:addEventListener("tap", boxScoreScene)
	end
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
