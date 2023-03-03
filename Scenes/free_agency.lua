local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function skip()
    local i = 1
    while i <= #league.freeAgents do
        local result = league:freeAgentOffers(league.freeAgents[i], nil)

        if(result == "") then
            i = i + 1
        end
    end

    league.freeAgents = {}
    league:readjustStarters()
    freeAgency = false
    freeAgentPage = 1
    composer.gotoScene("Scenes.pregame")
end

local function nextPage()
    freeAgentPage = freeAgentPage + 1
    composer.gotoScene("Scenes.load_scene")
end

local function previousPage()
    freeAgentPage = freeAgentPage - 1
    composer.gotoScene("Scenes.load_scene")
end

local function selectPlayer(player)
    local options = {
        params = {
            player = player
        }
    }
    
    composer.gotoScene("Scenes.negotiations", options)
end

local function roster()
    local options = {
        params = {
            team = league:findTeam(userTeam),
            week = 1,
            year = league.year - 1,
            playoffs = false
        }
    }

    composer.gotoScene("Scenes.team_info", options)
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
    playerBorder:setFillColor(TRANSPARENT[1], TRANSPARENT[2], TRANSPARENT[3], TRANSPARENT[4])
    playerBorder:addEventListener("tap", choosePlayer)
    playerBorder:setStrokeColor(UTILITY_COLOR[1], UTILITY_COLOR[2], UTILITY_COLOR[3])
    playerBorder.strokeWidth = 2

    local playerName = display.newText(sceneGroup, getName(player.name), playerBorder.x, playerBorder.y - playerBorder.height / 2.5, native.systemFont, 12)
    playerName:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    playerName:addEventListener("tap", choosePlayer)

    local paramStr = "$" .. formatContractMoney(calculateFairSalary(player)) .. 
                        "\nFNS: " .. player.finishing .. "  CLS: " .. player.closeShot .. 
                        "\nMDR: " .. player.midRange .. "  3PT: " .. player.three .. 
                        "\nCTE: " .. player.contestingExterior .. "  CTI: " .. player.contestingInterior .. 
                        "\nBLK: " .. player.blocking .. "  STL: " .. player.stealing .. 
                        "\nSPD: " .. player.speed .. "  HGT: " .. player.height .. 
                        "\nSTMNA: " .. player.maxStamina .. "  POT: " .. player.potential

    local params = display.newText(sceneGroup, paramStr, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 16 + 8 * 2, native.systemFont, 8)
    params:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
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
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    createButtonWithBorder(sceneGroup, "Team Info", 16, 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, roster)
    createButtonWithBorder(sceneGroup, "Skip", 16, display.contentWidth - 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, skip)

    local maxPlayers = freeAgentPage * 15
    if(maxPlayers > #league.freeAgents) then
        maxPlayers = #league.freeAgents
    end

    for i = (freeAgentPage - 1) * 15 + 1, maxPlayers do
        local player = league.freeAgents[i]
        local j = i - ((freeAgentPage - 1) * 15)

        if(j <= 5) then
            showPlayerCard(player, display.contentWidth * (j - 1) / 4, display.contentHeight * .2)
        elseif(j <= 10) then
           showPlayerCard(player, display.contentWidth * ((j - 6) / 4), display.contentHeight * .5)
        else
            showPlayerCard(player, display.contentWidth * ((j - 11) / 4), display.contentHeight * .8)
        end
    end

    if(freeAgentPage > 1) then
        createButtonWithBorder(sceneGroup, "Previous", 16, 8, display.contentHeight - 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, previousPage)
    end

    if(#league.freeAgents > freeAgentPage * 15) then
        createButtonWithBorder(sceneGroup, "Next", 16, display.contentWidth - 8, display.contentHeight - 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextPage)
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
