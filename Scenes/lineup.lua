local composer = require( "composer" )
local scene = composer.newScene()

local positions = {"1 - PG", "2 - SG", "3 - SF", "4 - PF", "5 - C"}
local sceneGroup = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    composer.gotoScene(lastScene)
end

local function redraw()
    composer.gotoScene("Scenes.load_scene")
end

local function switchPlayers()
    local team = league:findTeam(userTeam)
    local tmp = team.players[lineupSwitch[1]]
    team.players[lineupSwitch[1]] = team.players[lineupSwitch[2]]
    team.players[lineupSwitch[2]] = tmp

    if(not gameInProgress) then
        local tmpStarter = team.players[lineupSwitch[1]].starter
        team.players[lineupSwitch[1]].starter = team.players[lineupSwitch[2]].starter
        team.players[lineupSwitch[2]].starter = tmpStarter
    end

    lineupSwitch = {-1, -1}
end

local function getName(name)
    local params = {}
    
    for param in string.gmatch(name, "([^ ]+)") do
        table.insert(params, param)
    end
    
    return string.sub(params[2], 1, 7)
end

local function showPlayerCard(player, initialX, initialY, i)
    local function selectPlayer()
        if(lineupSwitch[1] ~= -1) then
            lineupSwitch[2] = i
            switchPlayers()
        else
            lineupSwitch[1] = i
        end

        redraw()
    end

    local playerBorder = display.newRect(sceneGroup, initialX, initialY, display.contentWidth / 8, display.contentHeight / 4)
    playerBorder:setFillColor(TRANSPARENT[1], TRANSPARENT[2], TRANSPARENT[3], TRANSPARENT[4])
    playerBorder:addEventListener("tap", selectPlayer)
    if(i == lineupSwitch[1]) then
        playerBorder:setStrokeColor(0, 0, 1)
        playerBorder.strokeWidth = 4
    else
        playerBorder:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
        playerBorder.strokeWidth = 2
    end

    if(i <= 5) then
        local positionStr = display.newText(sceneGroup, positions[i], initialX, initialY + (playerBorder.height / 2) + 10, native.systemFont, 16)
        positionStr:setFillColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    end

    local playerName = display.newText(sceneGroup, player.number .. " " .. getName(player.name), playerBorder.x, playerBorder.y - playerBorder.height / 2.5, native.systemFont, 12)
    playerName:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    playerName:addEventListener("tap", selectPlayer)

    local paramStr = "DRB: " .. player.dribbling .. "  STL: " .. player.stealing .. 
                        "\nFNS: " .. player.finishing .. "  CLS: " .. player.closeShot .. 
                        "\nMDR: " .. player.midRange .. "  3PT: " .. player.three .. 
                        "\nCTE: " .. player.contestingExterior .. "  CTI: " .. player.contestingInterior .. 
                        "\nBLK: " .. player.blocking .. "  PSS: " .. player.passing .. 
                        "\nSPD: " .. player.speed .. "  HGT: " .. player.height .. 
                        "\nSTMNA: " .. string.format("%.1f", player.stamina) .. "/" .. player.maxStamina

    local params = display.newText(sceneGroup, paramStr, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 16 + 8 * 2, native.systemFont, 8)
    params:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    params:addEventListener("tap", selectPlayer)
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

    if(composer.getSceneName("previous") ~= composer.getSceneName("current") and composer.getSceneName("previous") ~= "Scenes.load_scene") then
        lastScene = composer.getSceneName("previous")
    end

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

	local startersLabel = display.newText(sceneGroup, "Starters", display.contentCenterX, 12, native.systemFont, 24)
    startersLabel:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local benchLabel = display.newText(sceneGroup, "Bench", display.contentCenterX, display.contentHeight / 3 + 27,  native.systemFont, 24)
    benchLabel:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextScene)
    
    local team = league:findTeam(userTeam)
    for i = 1, #team.players do
        showPlayer(team, i)
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
