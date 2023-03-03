local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local player = nil
local team = nil
local week = league.weekNum
local year = league.year
local playoffTime = not regularSeason

local statPositions = {
    0,      -- Name
    .25,    -- Pts
    .35,    -- 2PM
    .425,     -- 2PA
    .525,    -- 3PM
    .6,    -- 3PA
    .7,      -- BLK
    .8,      -- STL
    .9,       -- TRV
    1       -- +/-
}

local fontSize = 12
local rowDist = 16
local paddingX = 8
local paddingY = display.contentHeight * .2
local fairSalary = 0
local fairLength = 4

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    local options = {
        params = {
            team = team
        }
    }

    composer.gotoScene("Scenes.roster", options)
end

local function levelUp()
    local options = {
        params = {
            team = team,
            player = player
        }
    }

    composer.gotoScene("Scenes.level_up", options)
end

local function alterDisplay()
    local options = {
        params = {
            player = player,
            team = team,
            week = week,
            year = year,
            playoffs = playoffTime
        }
    }

    displayPlayerStatsView = not displayPlayerStatsView
    composer.gotoScene("Scenes.load_scene", options)
end

local function reloadDisplay()
    local options = {
        params = {
            player = player,
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

local function displayStatsHeader()
    local name = display.newText(sceneGroup, "Name", display.contentWidth * statPositions[1] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    name:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local pts = display.newText(sceneGroup, "Pts", display.contentWidth * statPositions[2] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    pts:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPM = display.newText(sceneGroup, "2PM", display.contentWidth * statPositions[3] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPA = display.newText(sceneGroup, "2PA", display.contentWidth * statPositions[4] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePM = display.newText(sceneGroup, "3PM", display.contentWidth * statPositions[5] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePA = display.newText(sceneGroup, "3PA", display.contentWidth * statPositions[6] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local blocks = display.newText(sceneGroup, "BLK", display.contentWidth * statPositions[7] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    blocks:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local steals = display.newText(sceneGroup, "STL", display.contentWidth * statPositions[8] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    steals:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local turnovers = display.newText(sceneGroup, "TRV", display.contentWidth * statPositions[9] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local plusMinus = display.newText(sceneGroup, "+/-", display.contentWidth * statPositions[10] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX, paddingY + 4, display.contentWidth * 1.5, 2)
    dividerHorizontal:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end

local function displayStats(text, stats, row)
    local name = display.newText(sceneGroup, text, display.contentWidth * statPositions[1] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    name:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local pts = display.newText(sceneGroup, stats.points, display.contentWidth * statPositions[2] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    pts:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPM = display.newText(sceneGroup, stats.twoPM, display.contentWidth * statPositions[3] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPA = display.newText(sceneGroup, stats.twoPA, display.contentWidth * statPositions[4] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePM = display.newText(sceneGroup, stats.threePM, display.contentWidth * statPositions[5] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePA = display.newText(sceneGroup, stats.threePA, display.contentWidth * statPositions[6] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local blocks = display.newText(sceneGroup, stats.blocks, display.contentWidth * statPositions[7] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    blocks:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local steals = display.newText(sceneGroup, stats.steals, display.contentWidth * statPositions[8] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    steals:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local turnovers = display.newText(sceneGroup, stats.turnovers, display.contentWidth * statPositions[9] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local plusMinus = display.newText(sceneGroup, stats.plusMinus, display.contentWidth * statPositions[10] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end

local function displayString(text, x, y)
    local label = display.newText(sceneGroup, text, x, y, native.systemFont, 16)
    label:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end

local function displayAttributes()
    local y = 60
    displayString("Overall: " .. string.format("%.2f", calculateOverall(player)), 0, y)
    displayString("Potential: " .. player.potential, display.contentWidth * .33, y)
    displayString("Experience: " .. player.exp .. "/500", display.contentWidth * .67, y)
    displayString("Years in NBA: " .. player.years, display.contentWidth, y)
    
    y = y + 50
    displayString("Height: " .. player.height, 0, y)
    displayString("Speed: " .. player.speed, display.contentWidth * .33, y)
    displayString("Ball Speed: " .. player.ballSpeed, display.contentWidth * .67, y)
    displayString("Quickness: " .. player.quickness, display.contentWidth, y)

    y = y + 25
    displayString("Stamina: " .. player.maxStamina, display.contentWidth * .33, y)
    displayString("Strength: " .. player.strength, display.contentWidth * .67, y)

    y = y + 35
    displayString("Finishing: " .. player.finishing, 0, y)
    displayString("Close Shot: " .. player.closeShot, display.contentWidth * .33, y)
    displayString("Mid-Range: " .. player.midRange, display.contentWidth * .67, y)
    displayString("3-PT: " .. player.three, display.contentWidth, y)

    y = y + 25
    displayString("Dribbling: " .. player.dribbling, 0, y)
    displayString("Stealing: " .. player.stealing, display.contentWidth * .5, y)
    displayString("Blocking: " .. player.blocking, display.contentWidth, y)

    y = y + 25
    displayString("Interior Defending: " .. player.contestingInterior, display.contentWidth * .25, y)
    displayString("Exterior Defending: " .. player.contestingExterior, display.contentWidth * .75, y)

    y = y + 50
    if(player.contract.length > 0) then
        displayString("Contract: $" .. formatContractMoney(player.contract.value), display.contentWidth * .25, y)
        displayString("Years: " .. player.contract.length, display.contentWidth * .75, y)
    else
        displayString("Proposed Contract: $" .. formatContractMoney(fairSalary), display.contentWidth * .25, y)
        displayString("Proposed Years: " .. fairLength, display.contentWidth * .75, y)
    end
end

local function showPlayerAttributes()
    -- Number + Name
    local nameStr = "#" .. player.number .. " - " .. player.name
    local startersLabel = display.newText(sceneGroup, nameStr, display.contentCenterX, 24, native.systemFont, 24)
    startersLabel:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    displayAttributes()
end

local function showPlayerStats()
    -- Number + Name
    local nameStr = "#" .. player.number .. " - " .. player.name
    local startersLabel = display.newText(sceneGroup, nameStr, display.contentCenterX, 20, native.systemFont, 24)
    startersLabel:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local gameInfo = league:findGameInfo(league.schedule[week], team.name)
    local dayStr = "Day "

    if(playoffTime) then
        dayStr = "Playoff " .. dayStr
        gameInfo = league:findGameInfo(league.playoffs[week], team.name)
    end

    if(gameInfo) then
        if(gameInfo.home == team.name) then
            displayString(dayStr .. week .. " vs " .. gameInfo.away, display.contentCenterX, display.contentHeight * .15)
        else
            displayString(dayStr .. week .. " vs " .. gameInfo.home, display.contentCenterX, display.contentHeight * .15)
        end

        displayStats("Game", getGameStats(player, year, week, playoffTime), 1)
    else
        displayString("No Games Yet", display.contentCenterX, display.contentHeight * .15)
        displayStats("Game", StatsLib:createStats(), 1)
    end

    displayStatsHeader()
    if(preseason or freeAgency) then
        displayStats("Season", calculateYearlyStats(player, league.year - 1), 2)
    else
        displayStats("Season", calculateYearlyStats(player, league.year), 2)
    end
    displayStats("Career", calculateCareerStats(player), 3)

    if(findPreviousGameWeek().day ~= -1) then
        createButtonWithBorder(sceneGroup, "<- Last Game", 16, 8, display.contentHeight * .15, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, lastGame)
    end

    if(findNextGameWeek().day ~= -1) then
        createButtonWithBorder(sceneGroup, "Next Game ->", 16, display.contentWidth - 8, display.contentHeight * .15, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextGame)
    end

    local y = display.contentCenterY
    displayString("MVP: " .. player.awards.mvp, 0, y)
    displayString("DPOTY: " .. player.awards.dpoty, display.contentWidth * .33, y)
    displayString("ROTY: " .. player.awards.roty, display.contentWidth * .67, y)
    displayString("6MOTY: " .. player.awards.smoty, display.contentWidth, y)

    y = y + 25
    displayString("Rings: " .. player.awards.rings, display.contentWidth * .33, y)
    displayString("FMVP: " .. player.awards.fmvp, display.contentWidth * .67, y)
end

local function cutPlayer()
    table.remove(team.players, indexOf(team.players, player))
    nextScene()
end

local function reSign()
    player.contract.value = fairSalary
    player.contract.length = fairLength

    nextScene()
end

local function reject()
    table.insert(league.freeAgents, player)
    table.remove(team.players, indexOf(team.players, player))

    nextScene()
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    player = event.params.player
    team = event.params.team
    year = event.params.year
    week = event.params.week
    playoffTime = event.params.playoffs

    if(preseason and player.contract.length == 0) then
        fairSalary = calculateFairSalary(player)
    end

    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextScene)

    if(player.levels > 0 and calculateOverallSkills(player) < 10) then
        createButtonWithBorder(sceneGroup, "Level Up (" .. player.levels .. ")", 16, 0, display.contentHeight - 8, 2, 
                TEXT_COLOR, TEXT_COLOR, TRANSPARENT, levelUp)
    end

    if(not displayPlayerStatsView) then
        createButtonWithBorder(sceneGroup, "Stats", 16, display.contentWidth - 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, alterDisplay)
        showPlayerAttributes()
    else
        createButtonWithBorder(sceneGroup, "Attributes", 16, display.contentWidth - 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, alterDisplay)
        showPlayerStats()
    end

    if(team.name == userTeam) then
        if(player.contract.length > 0) then
            createButtonWithBorder(sceneGroup, "Cut", 16, display.contentCenterX, display.contentHeight - 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, cutPlayer)
        else
            createButtonWithBorder(sceneGroup, "Re-Sign", 16, display.contentWidth * .33, display.contentHeight - 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, reSign)
            createButtonWithBorder(sceneGroup, "Reject", 16, display.contentWidth * .67, display.contentHeight - 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, reject)
        end
    elseif(player.contract.length > 0) then
        createButtonWithBorder(sceneGroup, "Sign", 16, display.contentCenterX, display.contentHeight - 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, reSign)
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
