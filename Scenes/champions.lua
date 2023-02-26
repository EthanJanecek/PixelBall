local composer = require( "composer" )

local scene = composer.newScene()
local sceneGroup = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function findMVP()
	local players = {}

    for i = 1, #league.teams do
        local team = league.teams[i]
        local games = team.wins + team.losses

        if(games ~= 0) then
            for j = 1, #team.players do
                local player = team.players[j]
                local stats = calculateYearlyStats(player, league.year)
                local points = math.round(stats.points / games)
                local winPercent = math.round(team.wins * 100 / games)

                local twoPtPercent = 0
                if(stats.twoPA ~= 0) then
                    twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
                end
                
                local threePtPercent = 0
                if(stats.threePA ~= 0) then
                    threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
                end

                local ts = 0
                local eFG = 0
                if(stats.twoPA + stats.threePA ~= 0) then
                    ts = math.round(stats.points * 100 / (2 * (stats.twoPA + stats.threePA)))
                    eFG = math.round((stats.twoPM + .5 * stats.threePM) * 100 / (stats.twoPA + stats.threePA))
                end

                local plusMinus = math.round(stats.plusMinus / games)
    
                -- normalize each stat from 0-10
                local rating = (points * 1.5) + plusMinus + (winPercent / 20) + (twoPtPercent / 10) + (threePtPercent / 10) + (ts / 15) + (eFG / 15)
    
                local playerStats = {
					playerObj = player,
                    name = player.name,
                    winPercent = winPercent,
                    pts = points,
                    twoPtPercent = twoPtPercent,
                    threePtPercent = threePtPercent,
                    ts = ts,
                    eFG = eFG,
                    plusMinus = plusMinus,
                    rating = rating
                }
    
                table.insert(players, playerStats)
            end
        end
    end

    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

	local mvp = players[1]

	mvp.playerObj.awards.mvp = mvp.playerObj.awards.mvp + 1
	local name = display.newText(sceneGroup, "MVP: " .. mvp.name, display.contentCenterX, display.contentHeight * .25, native.systemFont, 16)
	name:setFillColor(.922, .910, .329)
end

local function find6MOTY()
	local players = {}

    for i = 1, #league.teams do
        local team = league.teams[i]
        local games = team.wins + team.losses

        if(games ~= 0) then
            for j = 1, #team.players do
                local player = team.players[j]
                if(not player.starter) then
                    local stats = calculateYearlyStats(player, league.year)
                    local points = math.round(stats.points / games)
                    local winPercent = math.round(team.wins * 100 / games)

                    local twoPtPercent = 0
                    if(stats.twoPA ~= 0) then
                        twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
                    end
                    
                    local threePtPercent = 0
                    if(stats.threePA ~= 0) then
                        threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
                    end

                    local ts = 0
                    local eFG = 0
                    if(stats.twoPA + stats.threePA ~= 0) then
                        ts = math.round(stats.points * 100 / (2 * (stats.twoPA + stats.threePA)))
                        eFG = math.round((stats.twoPM + .5 * stats.threePM) * 100 / (stats.twoPA + stats.threePA))
                    end

                    local plusMinus = math.round(stats.plusMinus / games)
        
                    -- normalize each stat from 0-10
                    local rating = (points * 1.5) + (plusMinus / 2) + (winPercent / 20) + (twoPtPercent / 10) + (threePtPercent / 10) + (ts / 15) + (eFG / 15)
        
                    local playerStats = {
						playerObj = player,
                        name = player.name,
                        winPercent = winPercent,
                        pts = points,
                        twoPtPercent = twoPtPercent,
                        threePtPercent = threePtPercent,
                        ts = ts,
                        eFG = eFG,
                        plusMinus = plusMinus,
                        rating = rating
                    }
        
                    table.insert(players, playerStats)
                end
            end
        end
    end

    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

	local smoty = players[1]

	smoty.playerObj.awards.smoty = smoty.playerObj.awards.smoty + 1
	local name = display.newText(sceneGroup, "6MOTY: " .. smoty.name, display.contentCenterX, display.contentHeight * .4, native.systemFont, 16)
	name:setFillColor(.922, .910, .329)
end

local function findROTY()
	local players = {}

    for i = 1, #league.teams do
        local team = league.teams[i]
        local games = team.wins + team.losses

        if(games ~= 0) then
            for j = 1, #team.players do
                local player = team.players[j]

                if(player.years == 0) then
                    local stats = calculateYearlyStats(player, league.year)
                    local points = math.round(stats.points / games)
                    local winPercent = math.round(team.wins * 100 / games)

                    local twoPtPercent = 0
                    if(stats.twoPA ~= 0) then
                        twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
                    end
                    
                    local threePtPercent = 0
                    if(stats.threePA ~= 0) then
                        threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
                    end

                    local ts = 0
                    local eFG = 0
                    if(stats.twoPA + stats.threePA ~= 0) then
                        ts = math.round(stats.points * 100 / (2 * (stats.twoPA + stats.threePA)))
                        eFG = math.round((stats.twoPM + .5 * stats.threePM) * 100 / (stats.twoPA + stats.threePA))
                    end

                    local plusMinus = math.round(stats.plusMinus / games)
        
                    -- normalize each stat from 0-10
                    local rating = (points * 1.5) + (plusMinus / 2) + (winPercent / 50) + (twoPtPercent / 10) + (threePtPercent / 10) + (ts / 15) + (eFG / 15)
        
                    local playerStats = {
						playerObj = player,
                        name = player.name,
                        winPercent = winPercent,
                        pts = points,
                        twoPtPercent = twoPtPercent,
                        threePtPercent = threePtPercent,
                        ts = ts,
                        eFG = eFG,
                        plusMinus = plusMinus,
                        rating = rating
                    }
        
                    table.insert(players, playerStats)
                end
            end
        end
    end

    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

	local roty = players[1]

	roty.playerObj.awards.roty = roty.playerObj.awards.roty + 1
	local name = display.newText(sceneGroup, "ROTY: " .. roty.name, display.contentCenterX, display.contentHeight * .55, native.systemFont, 16)
	name:setFillColor(.922, .910, .329)
end

local function findDPOTY()
	local players = {}

    for i = 1, #league.teams do
        local team = league.teams[i]
        local games = team.wins + team.losses

        if(games ~= 0) then
            for j = 1, #team.players do
                local player = team.players[j]
                local stats = calculateYearlyStats(player, league.year)

                if(stats.shotsAgainst ~= 0) then
                    local winPercent = math.round(team.wins * 100 / games)
                    local points = math.round(stats.pointsAgainst / games)
                    local shots = math.round(stats.shotsAgainst / games)
                    local blocks = math.round(stats.blocks / games)
                    local steals = math.round(stats.steals / games)

                    local ptsPerShot = 0
                    if(shots ~= 0) then
                        ptsPerShot = tonumber(string.format("%.2f", (points / shots)))
                    end
                    
                    local ptsPerShotMin = ptsPerShot
                    if(ptsPerShotMin < .1) then
                        ptsPerShotMin = .1
                    end
                    -- normalize each stat from 0-10
                    local rating = (winPercent / 20) + (3 * shots / ptsPerShotMin) + (blocks * 3) + (steals * 3)
        
                    local playerStats = {
						playerObj = player,
                        name = player.name,
                        winPercent = winPercent,
                        points = points,
                        shots = shots,
                        ptsPerShot = ptsPerShot,
                        blocks = blocks,
                        steals = steals,
                        rating = rating
                    }
        
                    table.insert(players, playerStats)
                end
            end
        end
    end

    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

	local dpoty = players[1]

	dpoty.playerObj.awards.dpoty = dpoty.playerObj.awards.dpoty + 1
	local name = display.newText(sceneGroup, "DPOTY: " .. dpoty.name, display.contentCenterX, display.contentHeight * .7, native.systemFont, 16)
	name:setFillColor(.922, .910, .329)
end

local function findFMVP(team)
	local players = {}
	local games = 7

	for i = 1, #team.players do
		local player = team.players[i]
		local stats = calculateFinalsStats(player, league.year)
		local points = math.round(stats.points / games)

		local twoPtPercent = 0
		if(stats.twoPA ~= 0) then
			twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
		end
		
		local threePtPercent = 0
		if(stats.threePA ~= 0) then
			threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
		end

		local ts = 0
		local eFG = 0
		if(stats.twoPA + stats.threePA ~= 0) then
			ts = math.round(stats.points * 100 / (2 * (stats.twoPA + stats.threePA)))
			eFG = math.round((stats.twoPM + .5 * stats.threePM) * 100 / (stats.twoPA + stats.threePA))
		end

		local plusMinus = math.round(stats.plusMinus / games)

		-- normalize each stat from 0-10
		local rating = (points * 1.5) + plusMinus + (twoPtPercent / 10) + (threePtPercent / 10) + (ts / 15) + (eFG / 15)

		local playerStats = {
			playerObj = player,
			name = player.name,
			pts = points,
			twoPtPercent = twoPtPercent,
			threePtPercent = threePtPercent,
			ts = ts,
			eFG = eFG,
			plusMinus = plusMinus,
			rating = rating
		}

		table.insert(players, playerStats)
	end

	table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

	local fmvp = players[1]

	fmvp.playerObj.awards.fmvp = fmvp.playerObj.awards.fmvp + 1
	local name = display.newText(sceneGroup, "FMVP: " .. fmvp.name, display.contentCenterX, display.contentHeight * .85, native.systemFont, 16)
	name:setFillColor(.922, .910, .329)
end

local function findAwardWinners()
	findMVP()
	find6MOTY()
	findROTY()
	findDPOTY()
end

local function nextScene()
	loadNames()
	generateDraftPlayers()
	league:nextYear()

    composer.gotoScene("Scenes.retiring_players")
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
    background:addEventListener("tap", nextScene)

    local eastTeam = league.playoffTeams.east[1]
    local westTeam = league.playoffTeams.west[1]
    local winner = nil

    if(eastTeam.wins > westTeam.wins) then
        winner = eastTeam.team
		
		league:findTeam(westTeam.team).draftPosition = 29
		league:findTeam(eastTeam.team).draftPosition = 30
    else
        winner = westTeam.team

		league:findTeam(westTeam.team).draftPosition = 30
		league:findTeam(eastTeam.team).draftPosition = 29
    end

	local winningTeam = league:findTeam(winner)
	for i = 1, #winningTeam.players do
		winningTeam.players[i].awards.rings = winningTeam.players[i].awards.rings + 1
	end

	local title = display.newText(sceneGroup, "World Champions: " .. winner, display.contentCenterX, display.contentHeight * .1, native.systemFont, 16)
    title:setFillColor(.922, .910, .329)

	findAwardWinners()
	findFMVP(winningTeam)
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
