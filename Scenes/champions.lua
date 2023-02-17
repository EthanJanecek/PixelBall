local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function resetYear()
	regularSeason = true
	playoffs = false
	
	league.year = league.year + 1
	league.weekNum = 1
	league.regularSeason = true
	league.playoffsActive = false
	league:createSchedule()

	for i = 1, 30 do
		local team = league.teams[i]
		team.wins = 0
		team.losses = 0

		for j = 1, #team.players do
			local player = team.players[j]
			player.years = player.years + 1
		end
	end
end

local function setUpDraft()
	table.sort(draftPlayers, function(player1, player2) 
		return calculateDraftStock(player1) > calculateDraftStock(player2)
	end)

	for i, team in ipairs(league.teams) do
		if(team.name ~= userTeam) then
			local tmpPlayers = {}
			for j, player in ipairs(team.players) do
				table.insert(tmpPlayers, player)
			end

			table.sort(tmpPlayers, function(player1, player2)
				return calculateOverall(player1) < calculateOverall(player2)
			end)

			table.remove(team.players, indexOf(team.players, tmpPlayers[1]))
			table.remove(team.players, indexOf(team.players, tmpPlayers[2]))
		end
	end
end

local function nextScene()
	loadNames()
	generateDraftPlayers()
	resetYear()
	setUpDraft()

    composer.gotoScene("Scenes.remove_players")
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
		
		league:findTeam(westTeam.team).draftPosition = 29
		league:findTeam(eastTeam.team).draftPosition = 30
    else
        winner = westTeam.team

		league:findTeam(westTeam.team).draftPosition = 30
		league:findTeam(eastTeam.team).draftPosition = 29
    end

	local title = display.newText(sceneGroup, "The " .. winner .. " are your World Champions!", display.contentCenterX, display.contentCenterY / 2, native.systemFont, 24)
    title:setFillColor(.922, .910, .329)
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
