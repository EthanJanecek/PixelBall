local composer = require( "composer" )
local json = require( "json" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function findLastGameWeekHelper(team)
    local i = numDays

    while i > 0 do
        if(league:findGameInfo(league.schedule[i], team.name)) then
            return {day = i, playoffs = false}
        end

        i = i - 1
    end

    return {day = -1, playoffs = false}
end

local function findLastGameWeek(team)
    local i = league.weekNum - 1

    while i > 0 do
        if(not regularSeason) then
            if(league:findGameInfo(league.playoffs[i], team.name)) then
                return {day = i, playoffs = not regularSeason}
            end
        else
            if(league:findGameInfo(league.schedule[i], team.name)) then
                return {day = i, playoffs = not regularSeason}
            end
        end

        i = i - 1
    end

    if(not regularSeason) then
        return findLastGameWeekHelper(team)
    end

    return {day = -1, playoffs = false}
end

local function setDefense()
    composer.gotoScene("Scenes.set_defense")
end

local function toGame()
    gameInProgress = true
    score = {away=0, home=0}
    composer.gotoScene("Scenes.game")
end

local function seeStandings()
    composer.gotoScene("Scenes.standings")
end

local function nextWeek()
    composer.gotoScene("Scenes.postgame")
end

local function changeLineup()
    composer.gotoScene("Scenes.lineup")
end

local function createPlays()
    composer.gotoScene("Scenes.play_creation")
end

local function mvpTracker()
    composer.gotoScene("Scenes.mvp_tracker")
end

local function settings()
    local options = {
        params = {
            leagueStarted = true
        }
    }

    composer.gotoScene("Scenes.settings", options)
end

local function teamInfo()
    local results = findLastGameWeek(league:findTeam(userTeam))

    local options = {
        params = {
            team = league:findTeam(userTeam),
            week = results.day,
            year = league.year,
            playoffs = results.playoffs
        }
    }

    composer.gotoScene("Scenes.team_info", options)
end

local function saveGame()
    local path = currentSaveFile
    local file, errorString = io.open(path, "w")
    
    if file then
        file:write(json.encode(league))
        io.close(file)
    else
        print(errorString)
    end
end

local function reloadScene()
    composer.gotoScene("Scenes.load_scene")
end

local function simSeason()
    simulateMainGame = true

    while league.weekNum < numDays do
        league:nextWeek()
    end

    reloadScene()
end

local function simGame()
    simulateMainGame = true
    nextWeek()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    league:resetTeams()
    simulateMainGame = false

    lineupSwitch = {-1, -1}
    score = {}
    gameDetails = {qtr=1, min=minutesInQtr, sec=0, shotClock=24}
    qtrScores = {}
    showingUserTeamStats = true
    defenseStats = {}
    
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local allGames = nil
    if(regularSeason) then
        allGames = league.schedule[league.weekNum]
    else
        allGames = league.playoffs[league.weekNum]
    end

    local gameInfo = league:findGameInfo(allGames, userTeam)
    if((gameInfo) and (playoffs) and (league:findPlayoffTeam(gameInfo.home).wins >= 4 or league:findPlayoffTeam(gameInfo.away).wins >= 4)) then
        gameInfo = nil
    end

    if(regularSeason) then
        local dayStr = "Year: " .. league.year .. "    Day: " .. league.weekNum .. "/" .. numDays
        local day = display.newText(sceneGroup, dayStr, display.contentCenterX, display.contentCenterY * .4, native.systemFont, 32)
        day:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    elseif(playoffs) then
        local roundString = "Round 1"
        if(league.weekNum >= 10 and league.weekNum < 17) then
            roundString = "Round 2"
        elseif(league.weekNum >= 17 and league.weekNum < 24) then
            roundString = "Conf. Finals"
        elseif(league.weekNum >= 24) then
            roundString = "Finals"
        end

        local dayStr = "Year: " .. league.year .. "    Playoffs - " .. roundString
        local day = display.newText(sceneGroup, dayStr, display.contentCenterX, display.contentCenterY * .4, native.systemFont, 32)
        day:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    else
        local dayStr = "Year: " .. league.year .. "    Play-In"
        local day = display.newText(sceneGroup, dayStr, display.contentCenterX, display.contentCenterY * .4, native.systemFont, 32)
        day:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    end

    if(gameInfo == nil) then
        local title = "Off Day"

        local title = display.newText(sceneGroup, title, display.contentCenterX, display.contentCenterY * .75, native.systemFont, 48)
        title:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

        createButtonWithBorder(sceneGroup, "Next Game", 32, display.contentCenterX, display.contentCenterY * 1.2, 2, 
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextWeek)
    else
        local titleStr = gameInfo.away .. " vs. " .. gameInfo.home

        local title = display.newText(sceneGroup, titleStr, display.contentCenterX, display.contentCenterY * .75, native.systemFont, 48)
        title:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

        createButtonWithBorder(sceneGroup, "Play", 32, display.contentWidth * .2, display.contentCenterY * 1.2, 2, 
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, toGame)
        createButtonWithBorder(sceneGroup, "Sim Game", 32, display.contentWidth * .5, display.contentCenterY * 1.2, 2,
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, simGame)
        createButtonWithBorder(sceneGroup, "Change Lineup", 32, display.contentCenterX * .5, display.contentCenterY * 1.5, 2, 
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, changeLineup)
        createButtonWithBorder(sceneGroup, "Create Plays", 32, display.contentCenterX * 1.5, display.contentCenterY * 1.5, 2, 
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, createPlays)
        createButtonWithBorder(sceneGroup, "Set Defense", 32, display.contentCenterX, display.contentCenterY * 1.8, 2, 
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, setDefense)
    end

    if(regularSeason and league.weekNum < numDays) then
            createButtonWithBorder(sceneGroup, "Sim Season", 32, display.contentWidth * .9, display.contentCenterY * 1.2, 2,
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, simSeason)
        end

    createButtonWithBorder(sceneGroup, "Save Game", 32, 0, 20, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, saveGame)
    createButtonWithBorder(sceneGroup, "Standings", 32, display.contentCenterX, 20, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, seeStandings)
    createButtonWithBorder(sceneGroup, "Award Tracking", 32, display.contentWidth, 20, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, mvpTracker)
    createButtonWithBorder(sceneGroup, "Settings", 32, display.contentCenterX * .2, display.contentCenterY * 1.8, 2, 
            TEXT_COLOR, TEXT_COLOR, TRANSPARENT, settings)
    
    if(canLevelUp(league:findTeam(userTeam))) then
        createButtonWithBorder(sceneGroup, "Team Info", 32, display.contentCenterX * 1.8, display.contentCenterY * 1.8, 2, 
            TEXT_COLOR, RED, TRANSPARENT, teamInfo)
    else
        createButtonWithBorder(sceneGroup, "Team Info", 32, display.contentCenterX * 1.8, display.contentCenterY * 1.8, 2, 
            TEXT_COLOR, TEXT_COLOR, TRANSPARENT, teamInfo)
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
