local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local draftTeams = {}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function cut()
    local team = league:findTeam(userTeam)
    table.sort(cutPlayers, function(num1, num2)
        return num1 > num2
    end)

    table.remove(team.players, cutPlayers[1])
    table.remove(team.players, cutPlayers[2])

    composer.gotoScene("Scenes.draft")
end

local function selectPlayer(i)
    local index = indexOf(cutPlayers, i)
    if index ~= -1 then
        table.remove(cutPlayers, index)
    elseif(#cutPlayers < 2) then
        table.insert(cutPlayers, i)
    end

    composer.gotoScene("Scenes.load_scene")
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
        selectPlayer(i)
    end

    local playerBorder = display.newRect(sceneGroup, initialX, initialY, display.contentWidth / 6, display.contentHeight / 4)
    playerBorder:setFillColor(0, 0, 0, 0)
    playerBorder:addEventListener("tap", choosePlayer)
    if(indexOf(cutPlayers, i) ~= -1) then
        playerBorder:setStrokeColor(0, 0, 1)
        playerBorder.strokeWidth = 4
    else
        playerBorder:setStrokeColor(0, 0, 0)
        playerBorder.strokeWidth = 2
    end

    local playerName = display.newText(sceneGroup, getName(player.name), playerBorder.x, playerBorder.y - playerBorder.height / 2.5, native.systemFont, 12)
    playerName:setFillColor(.922, .910, .329)
    playerName:addEventListener("tap", choosePlayer)

    local paramStr = "DRB: " .. player.dribbling .. "  STL: " .. player.stealing .. 
                        "\nFNS: " .. player.finishing .. "  CLS: " .. player.closeShot .. 
                        "\nMDR: " .. player.midRange .. "  3PT: " .. player.three .. 
                        "\nCTE: " .. player.contestingExterior .. "  CTI: " .. player.contestingInterior .. 
                        "\nBLK: " .. player.blocking .. "  PSS: " .. player.passing .. 
                        "\nSPD: " .. player.speed .. "  HGT: " .. player.height .. 
                        "\nSTMNA: " .. player.maxStamina .. "  POT: " .. player.potential

    local params = display.newText(sceneGroup, paramStr, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 16 + 8 * 2, native.systemFont, 8)
    params:setFillColor(.922, .910, .329)
    params:addEventListener("tap", choosePlayer)
end

local function showPlayer(team, i)
    local player = team.players[i]

    if(i <= 5) then
        showPlayerCard(player, display.contentWidth * (i - 1) / 4, display.contentHeight * 1.5 / 5, i)
    elseif(i <= 10) then
       showPlayerCard(player, display.contentWidth * (i - 6) / 4, display.contentHeight * 3 / 5, i)
    else
        showPlayerCard(player, display.contentWidth * (i - 11) / 4, display.contentHeight * 4 / 5 + 20, i)
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

    local label = display.newText(sceneGroup, "Choose 2 players to cut", display.contentCenterX, 12, native.systemFont, 24)
    label:setFillColor(.922, .910, .329)

    if(#cutPlayers == 2) then
        createButtonWithBorder(sceneGroup, "Cut", 16, display.contentWidth - 8, 8, 2, BLACK, BLACK, TRANSPARENT, cut)
    end
    
    chosenTeam = league:findTeam(userTeam)
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
