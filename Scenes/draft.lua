local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local draftTeams = {}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextPage()

end

local function selectPlayer(player)
    table.insert(league.findTeam(userTeam), player)
    table.remove(draftPlayers, indexOf(draftPlayers, player))

    for i = league.findTeam(userTeam).draftPosition + 1, 30 do
        table.insert(draftTeams[i].players, table.remove(draftPlayers, 1))
    end

    composer.removeScene("Scenes.draft")
    composer.gotoScene("Scenes.player_card")
end

local function getName(name)
    local params = {}
    
    for param in string.gmatch(name, "([^ ]+)") do
        table.insert(params, param)
    end
    
    return string.sub(params[2], 1, 7)
end

local function showPlayerCard(player, initialX, initialY)
    local function choosePlayer()
        selectPlayer(player)
    end

    local playerBorder = display.newRect(sceneGroup, initialX, initialY, display.contentWidth / 6, display.contentHeight / 4)
    playerBorder:setFillColor(0, 0, 0, 0)
    playerBorder:addEventListener("tap", choosePlayer)
    playerBorder:setStrokeColor(0, 0, 0)
    playerBorder.strokeWidth = 2

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

    for team in league.teams do
        table.insert(draftTeams, team)
    end

    table.sort(draftTeams, function(team1, team2)
        return team1.draftPosition > team2.draftPosition
    end)

    for i = 1, league.findTeam(userTeam).draftPosition - 1 do
        table.insert(draftTeams[i].players, table.remove(draftPlayers, 1))
    end

    local maxPlayers = 15
    if(#draftPlayers < 15) then
        maxPlayers = #draftPlayers
    end

    for i = 1, maxPlayers do
        local player = draftPlayers[i]

        if(i <= 5) then
            showPlayerCard(player, display.contentWidth * (i - 1) / 4, display.contentHeight * .2)
        elseif(i <= 10) then
           showPlayerCard(player, display.contentWidth * ((i - 6) / 4), display.contentHeight * .5)
        else
            showPlayerCard(player, display.contentWidth * ((i - 11) / 4), display.contentHeight * .8)
        end
    end
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
