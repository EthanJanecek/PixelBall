
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

	if(playoffs) then
		team = league:findPlayoffTeam(userTeam)
	end

	if(gameInfo and score.away) then
		gameInfo.score = score
		
		if(gameInfo.home == userTeam) then
			local opponent = league:findTeam(gameInfo.away)

			if(playoffs) then
				opponent = league:findPlayoffTeam(gameInfo.away)
			end

			if(regularSeason or playoffs) then
				if(score.home > score.away) then
					team.wins = team.wins + 1
					opponent.losses = opponent.losses + 1
				else
					team.losses = team.losses + 1
					opponent.wins = opponent.wins + 1
				end
			end
		else
			local opponent = league:findTeam(gameInfo.home)

			if(playoffs) then
				opponent = league:findPlayoffTeam(gameInfo.home)
			end

			if(regularSeason or playoffs) then
				if(score.home > score.away) then
					team.losses = team.losses + 1
					opponent.wins = opponent.wins + 1
				else
					team.wins = team.wins + 1
					opponent.losses = opponent.losses + 1
				end
			end
		end
	end

	league:nextWeek()
    composer.gotoScene("Scenes.score_recap")
end

local function boxScoreScene()
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
	local titleStr = ""

	if(gameInfo and score.away) then
		gameInfo.score = score
		
		if(gameInfo.home == userTeam) then
			if(score.home > score.away) then
				titleStr = "You won " .. score.home .. " - " .. score.away
			else
				titleStr = "You lost " .. score.home .. " - " .. score.away
			end
		else
			if(score.home > score.away) then
				titleStr = "You lost " .. score.home .. " - " .. score.away
			else
				titleStr = "You won " .. score.home .. " - " .. score.away
			end
		end
	end

	local title = display.newText(sceneGroup, titleStr, display.contentCenterX, display.contentCenterY * .75, native.systemFont, 48)
    title:setFillColor(.922, .910, .329)
	
	local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

	createButtonWithBorder(sceneGroup, "Next Game", 32, display.contentCenterX, display.contentCenterY * 1.2, 2, 
			BLACK, BLACK, TRANSPARENT, nextScene)

	if(#qtrScores > 0) then
		createButtonWithBorder(sceneGroup, "Box Score", 32, display.contentCenterX, display.contentCenterY * 1.5, 2, 
				BLACK, BLACK, TRANSPARENT, boxScoreScene)
	end
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
