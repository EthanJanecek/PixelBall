local composer = require( "composer" )
local json = require( "json" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function setDefense()
    composer.removeScene("Scenes.simulate_defense")
    composer.gotoScene("Scenes.set_defense")
end

local function toGame()
    gameInProgress = true
    score = {away=0, home=0}
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.game")
end

local function seeStandings()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.standings")
end

local function nextWeek()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.postgame")
end

local function changeLineup()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.lineup")
end

local function createPlays()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.play_creation")
end

local function mvpTracker()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.mvp_tracker")
end

local function saveGame()
    local path = getSaveDirectory()
    local file, errorString = io.open(path, "w")
    
    if file then
        file:write(json.encode(league))
        io.close(file)
    else
        print(errorString)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    league:resetTeams()

    lineupSwitch = {-1, -1}
    score = {}
    gameDetails = {qtr=1, min=minutesInQtr, sec=0, shotClock=24}
    qtrScores = {}
    showingUserTeamStats = true
    defenseStats = {}
    
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local allGames = nil
    if(regularSeason) then
        allGames = league.schedule[league.weekNum]
    else
        allGames = league.playoffs[league.weekNum]
    end

    local gameInfo = league:findGameInfo(allGames, userTeam)
    if((gameInfo) and (not regularSeason) and (league:findPlayoffTeam(gameInfo.home).wins >= 4 or league:findPlayoffTeam(gameInfo.away).wins >= 4)) then
        gameInfo = nil
    end

    if(regularSeason) then
        local dayStr = "Day: " .. league.weekNum .. "/" .. numDays
        local day = display.newText(sceneGroup, dayStr, display.contentCenterX, display.contentCenterY * .4, native.systemFont, 32)
        day:setFillColor(.922, .910, .329)
    elseif(playoffs) then
        local roundString = "Round 1"
        if(league.weekNum >= 10 and league.weekNum < 17) then
            roundString = "Round 2"
        elseif(league.weekNum >= 17 and league.weekNum < 24) then
            roundString = "Conf. Finals"
        elseif(league.weekNum >= 24) then
            roundString = "Finals"
        end

        local dayStr = "Playoffs - " .. roundString
        local day = display.newText(sceneGroup, dayStr, display.contentCenterX, display.contentCenterY * .4, native.systemFont, 32)
        day:setFillColor(.922, .910, .329)
    else
        local dayStr = "Play-In"
        local day = display.newText(sceneGroup, dayStr, display.contentCenterX, display.contentCenterY * .4, native.systemFont, 32)
        day:setFillColor(.922, .910, .329)
    end

    if(gameInfo == nil) then
        local title = "Off Day"

        local title = display.newText(sceneGroup, title, display.contentCenterX, display.contentCenterY * .75, native.systemFont, 48)
        title:setFillColor(.922, .910, .329)

        createButtonWithBorder(sceneGroup, "Next Game", 32, display.contentCenterX, display.contentCenterY * 1.2, 2, 
                BLACK, BLACK, TRANSPARENT, nextWeek)
    else
        local titleStr = gameInfo.away .. " vs. " .. gameInfo.home

        local title = display.newText(sceneGroup, titleStr, display.contentCenterX, display.contentCenterY * .75, native.systemFont, 48)
        title:setFillColor(.922, .910, .329)

        createButtonWithBorder(sceneGroup, "Play", 32, display.contentCenterX, display.contentCenterY * 1.2, 2, 
                BLACK, BLACK, TRANSPARENT, toGame)
        createButtonWithBorder(sceneGroup, "Change Lineup", 32, display.contentCenterX * .5, display.contentCenterY * 1.5, 2, 
                BLACK, BLACK, TRANSPARENT, changeLineup)
        createButtonWithBorder(sceneGroup, "Create Plays", 32, display.contentCenterX * 1.5, display.contentCenterY * 1.5, 2, 
                BLACK, BLACK, TRANSPARENT, createPlays)
        createButtonWithBorder(sceneGroup, "Set Defense", 32, display.contentCenterX, display.contentCenterY * 1.8, 2, 
                BLACK, BLACK, TRANSPARENT, setDefense)
    end

    createButtonWithBorder(sceneGroup, "Save Game", 32, 0, 20, 2, BLACK, BLACK, TRANSPARENT, saveGame)
    createButtonWithBorder(sceneGroup, "Standings", 32, display.contentCenterX, 20, 2, BLACK, BLACK, TRANSPARENT, seeStandings)
    createButtonWithBorder(sceneGroup, "Award Tracking", 32, display.contentWidth, 20, 2, BLACK, BLACK, TRANSPARENT, mvpTracker)
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
