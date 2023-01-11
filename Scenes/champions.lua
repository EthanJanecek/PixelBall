local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function setUpDraft()
	table.sort(draftPlayers, function(player1, player2) 
		return calculateDraftStock(player1) > calculateDraftStock(player2)
	end)

	for team in league.teams do
		local tmpPlayers = {}
		for player in team.players do
			table.insert(tmpPlayers, player)
		end

		table.sort(tmpPlayers, function(player1, player2)
			return calculateOverall(player1) < calculateOverall(player2)
		end)

		table.remove(team.players, indexOf(team.players, tmpPlayers[1]))
		table.remove(team.players, indexOf(team.players, tmpPlayers[2]))
	end
end

local function nextScene()
	loadNames()
	generateDraftPlayers()
	setUpDraft()

	composer.removeScene("Scenes.champions")
    composer.gotoScene("Scenes.draft")
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background:addEventListener("tap", nextScene)

    local eastTeam = league.playoffTeams.east[1]
    local westTeam = league.playoffTeams.west[1]
    local winner = ""

    if(eastTeam.wins > westTeam.wins) then
        winner = eastTeam.team
		
		westTeam.draftPosition = 29
		eastTeam.draftPosition = 30
    else
        winner = westTeam.team

		eastTeam.draftPosition = 29
		westTeam.draftPosition = 30
    end

	local title = display.newText(sceneGroup, "The " .. winner .. "\nare your World Champions!", display.contentCenterX, display.contentCenterY / 2, native.systemFont, 64)
    title:setFillColor(.922, .910, .329)
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
