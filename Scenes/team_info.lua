local composer = require( "composer" )
local scene = composer.newScene()

local imageSize = 30

local sceneGroup = nil
local team = nil
local week = league.weekNum
local year = league.year
local playoffTime = not regularSeason
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function back()
    composer.gotoScene("Scenes.pregame")
end

local function freeAgencyBack()
    composer.gotoScene("Scenes.free_agency")
end

local function seasonStart()
    table.sort(league.freeAgents, function(a, b)
        return calculateOverall(a) > calculateOverall(b)
    end)

    preseason = false
    freeAgency = true
    composer.gotoScene("Scenes.free_agency")
end

local function roster()
    local options = {
        params = {
            team = team
        }
    }

    composer.gotoScene("Scenes.roster", options)
end

local function changeTeam()
    local options = {
        params = {
            roster = true
        }
    }

    composer.gotoScene("Scenes.team_selection", options)
end

local function reloadDisplay()
    local options = {
        params = {
            team = team,
            week = week,
            year = year,
            playoffs = playoffTime
        }
    }

    composer.gotoScene("Scenes.load_scene", options)
end

local function findPreviousGameWeekHelper()
    local i = numDays

    while i > 0 do
        if(league:findGameInfo(league.schedule[i], team.name)) then
            return {day = i, playoffs = false}
        end

        i = i - 1
    end

    return {day = -1, playoffs = false}
end

local function findPreviousGameWeek()
    local i = week - 1

    while i > 0 do
        if(playoffTime) then
            if(league:findGameInfo(league.playoffs[i], team.name)) then
                return {day = i, playoffs = playoffTime}
            end
        else
            if(league:findGameInfo(league.schedule[i], team.name)) then
                return {day = i, playoffs = playoffTime}
            end
        end

        i = i - 1
    end

    if(playoffTime) then
        return findPreviousGameWeekHelper()
    end

    return {day = -1, playoffs = false}
end

local function findNextGameWeekHelper()
    local i = 1

    while i < league.weekNum do
        if(league:findGameInfo(league.playoffs[i], team.name)) then
            return {day = i, playoffs = true}
        end

        i = i + 1
    end

    return {day = -1, playoffs = false}
end

local function findNextGameWeek()
    local i = week + 1

    if(playoffTime) then
        while i < league.weekNum do
            if(league:findGameInfo(league.playoffs[i], team.name)) then
                return {day = i, playoffs = playoffTime}
            end
    
            i = i + 1
        end
    else
        local max = league.weekNum
        if(not regularSeason) then
            max = numDays + 1
        end

        while i < max do
            if(league:findGameInfo(league.schedule[i], team.name)) then
                return {day = i, playoffs = playoffTime}
            end
    
            i = i + 1
        end

        if(i == numDays + 1) then
            return findNextGameWeekHelper()
        end
    end

    return {day = -1, playoffs = false}
end

local function lastGame()
    local results = findPreviousGameWeek()
    week = results.day
    playoffTime = results.playoffs
    reloadDisplay()
end

local function nextGame()
    local results = findNextGameWeek()
    week = results.day
    playoffTime = results.playoffs
    reloadDisplay()
end

local function gameLog()
    if(findPreviousGameWeek().day ~= -1) then
        createButtonWithBorder(sceneGroup, "<- Last Game", 16, 0, display.contentHeight * .5, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, lastGame)
    end

    if(findNextGameWeek().day ~= -1) then
        createButtonWithBorder(sceneGroup, "Next Game ->", 16, display.contentWidth, display.contentHeight * .5, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextGame)
    end

    local gameInfo = league:findGameInfo(league.schedule[week], team.name)

    if(playoffTime) then
        gameInfo = league:findGameInfo(league.playoffs[week], team.name)
    end

    if(gameInfo and gameInfo.score.home) then
        local awayTeam = league:findTeam(gameInfo.away)
        local homeTeam = league:findTeam(gameInfo.home)
    
        local awayLogo = display.newImageRect(sceneGroup, awayTeam.logo, imageSize, imageSize)
        awayLogo.x = display.contentWidth * .4
        awayLogo.y = display.contentHeight * .5
    
        local homeLogo = display.newImageRect(sceneGroup, homeTeam.logo, imageSize, imageSize)
        homeLogo.x = display.contentWidth * .6
        homeLogo.y = display.contentHeight * .5
    
        local scoreStr = gameInfo.score.away .. " - " .. gameInfo.score.home
        local score = display.newText(sceneGroup, scoreStr, display.contentWidth * .5, display.contentHeight * .5, native.systemFont, 16)
        score:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    end

    if(not preseason) then
        local playoffStr = display.newText(sceneGroup, "Playoff Appearances: " .. team.playoffAppearances, display.contentWidth * .5, display.contentHeight * .7, native.systemFont, 16)
        playoffStr:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

        local confFinalStr = display.newText(sceneGroup, "Conference Finals Appearances: " .. team.confFinalsAppearances, display.contentWidth * .5, display.contentHeight * .8, native.systemFont, 16)
        confFinalStr:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

        local finalStr = display.newText(sceneGroup, "Finals Appearances: " .. team.finalsAppearances, display.contentWidth * .5, display.contentHeight * .9, native.systemFont, 16)
        finalStr:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    end
end

local function checkIfSeasonCanStart()
    if(#team.players > 15 or #team.players < 5) then
        return false
    end

    if(calculateCap(team) > team.cap) then
        return false
    end

    for i = 1, #team.players do
        if(team.players[i].contract.length == 0) then
            return false
        end
    end

    return true
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view

    team = event.params.team
    year = event.params.year
    week = event.params.week
    playoffTime = event.params.playoffs

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    if(canLevelUp(team)) then
        createButtonWithBorder(sceneGroup, "Roster", 16, display.contentCenterX, 8, 2, TEXT_COLOR, RED, TRANSPARENT, roster)
    else
        createButtonWithBorder(sceneGroup, "Roster", 16, display.contentCenterX, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, roster)
    end

    if(not preseason and not freeAgency) then
        createButtonWithBorder(sceneGroup, "<- Back", 16, 0, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, back)
        createButtonWithBorder(sceneGroup, "Change Team", 16, display.contentWidth - 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, changeTeam)
    elseif(freeAgency) then
        createButtonWithBorder(sceneGroup, "<- Back", 16, 0, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, freeAgencyBack)
    else
        if(checkIfSeasonCanStart()) then
            createButtonWithBorder(sceneGroup, "Start Season", 16, 0, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, seasonStart)
        else
            local options = display.newText(sceneGroup, "1. Team must be under cap\n2. Team must have between 5-15 players\n3.Team can't have any outstanding free agents", display.contentCenterX, display.contentHeight * .75, native.systemFont, 16)
            options:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
        end
    end

    local name = display.newText(sceneGroup, team.name, display.contentCenterX, 35, native.systemFont, 24)
    name:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local recordStr = "Record: " .. team.wins .. " - " .. team.losses
    local record = display.newText(sceneGroup, recordStr, display.contentWidth * .33, 65, native.systemFont, 16)
    record:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local rings = display.newText(sceneGroup, "Rings: " .. team.rings, display.contentWidth * .67, 65, native.systemFont, 16)
    rings:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local capStr = "Cap Hit: $" .. formatContractMoney(calculateCap(team)) .. " / $" .. formatContractMoney(team.cap)
    local cap = display.newText(sceneGroup, capStr, display.contentWidth * .5, 85, native.systemFont, 16)
    cap:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    gameLog()
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
