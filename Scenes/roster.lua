local composer = require( "composer" )
local scene = composer.newScene()

local positions = {"1 - PG", "2 - SG", "3 - SF", "4 - PF", "5 - C"}
local sceneGroup = nil
local chosenTeam = nil
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function findLastGameWeekHelper()
    local i = numDays

    while i > 0 do
        if(league:findGameInfo(league.schedule[i], chosenTeam.name)) then
            return {day = i, playoffs = false}
        end

        i = i - 1
    end

    return {day = -1, playoffs = false}
end

local function findLastGameWeek()
    local i = league.weekNum - 1

    while i > 0 do
        if(not regularSeason) then
            if(league:findGameInfo(league.playoffs[i], chosenTeam.name)) then
                return {day = i, playoffs = not regularSeason}
            end
        else
            if(league:findGameInfo(league.schedule[i], chosenTeam.name)) then
                return {day = i, playoffs = not regularSeason}
            end
        end

        i = i - 1
    end

    if(not regularSeason) then
        return findLastGameWeekHelper()
    end

    return {day = -1, playoffs = false}
end

local function nextScene()
    local results = findLastGameWeek()
    
    local options = {
        params = {
            team = chosenTeam,
            week = results.day,
            year = league.year,
            playoffs = results.playoffs
        }
    }

    composer.gotoScene("Scenes.team_info", options)
end

local function selectPlayer(player)
    local results = findLastGameWeek()

    local options = {
        params = {
            player = player,
            team = chosenTeam,
            week = results.day,
            year = league.year,
            playoffs = results.playoffs
        }
    }

    composer.gotoScene("Scenes.player_card", options)
end

local function getName(name)
    local params = {}
    
    for param in string.gmatch(name, "([^ ]+)") do
        table.insert(params, param)
    end
    
    return string.sub(params[2], 1, 7)
end

local function showPlayerCard(player, initialX, initialY, i)
    local function choosePlayer()
        selectPlayer(player)
    end

    local playerBorder = display.newRect(sceneGroup, initialX, initialY, display.contentWidth / 8, display.contentHeight / 4)
    playerBorder:setFillColor(0, 0, 0, 0)
    playerBorder:addEventListener("tap", choosePlayer)

    if(player.levels == 0) then
        playerBorder:setStrokeColor(0, 0, 0)
        playerBorder.strokeWidth = 2
    else
        playerBorder:setStrokeColor(1, 0, 0)
        playerBorder.strokeWidth = 4
    end

    if(i <= 5) then
        local positionStr = display.newText(sceneGroup, positions[i], initialX, initialY + (playerBorder.height / 2) + 10, native.systemFont, 16)
        positionStr:setFillColor(0, 0, 0)
    end

    local playerName = display.newText(sceneGroup, player.number .. " " .. getName(player.name), playerBorder.x, playerBorder.y - playerBorder.height / 2.5, native.systemFont, 12)
    playerName:setFillColor(.922, .910, .329)
    playerName:addEventListener("tap", choosePlayer)

    local paramStr = "DRB: " .. player.dribbling .. "  STL: " .. player.stealing .. 
                        "\nFNS: " .. player.finishing .. "  CLS: " .. player.closeShot .. 
                        "\nMDR: " .. player.midRange .. "  3PT: " .. player.three .. 
                        "\nCTE: " .. player.contestingExterior .. "  CTI: " .. player.contestingInterior .. 
                        "\nBLK: " .. player.blocking .. "  PSS: " .. player.passing .. 
                        "\nSPD: " .. player.speed .. "  HGT: " .. player.height .. 
                        "\nSTMNA: " .. string.format("%.1f", player.stamina) .. "/" .. player.maxStamina

    local params = display.newText(sceneGroup, paramStr, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 16 + 8 * 2, native.systemFont, 8)
    params:setFillColor(.922, .910, .329)
    params:addEventListener("tap", choosePlayer)
end

local function showPlayer(team, i)
    local player = team.players[i]
    local remainder = #team.players - 5

    if(i <= 5) then
        showPlayerCard(player, display.contentWidth * i / 6, display.contentHeight / 5, i)
    elseif(i <= 5 + (remainder / 2)) then
       showPlayerCard(player, display.contentWidth * (i - 5) / ((remainder / 2) + 1), display.contentHeight * 3 / 5, i)
    else
        showPlayerCard(player, display.contentWidth * (i - (5 + (remainder / 2))) / ((remainder / 2) + 1), display.contentHeight * 4 / 5 + 20, i)
    end
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

    displayPlayerStatsView = false

	local startersLabel = display.newText(sceneGroup, "Starters", display.contentCenterX, 12, native.systemFont, 24)
    startersLabel:setFillColor(.922, .910, .329)

    local benchLabel = display.newText(sceneGroup, "Bench", display.contentCenterX, display.contentHeight / 3 + 27,  native.systemFont, 24)
    benchLabel:setFillColor(.922, .910, .329)

    createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, BLACK, BLACK, TRANSPARENT, nextScene)
    
    chosenTeam = event.params.team
    for i = 1, #chosenTeam.players do
        showPlayer(chosenTeam, i)
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
