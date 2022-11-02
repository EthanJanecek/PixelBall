local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local strategyNames = {"Overall", "Speed", "Interior\nDefending", "Exterior\nDefending", "Height"}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    local prevScene = composer.getSceneName( "previous" )
	composer.removeScene("Scenes.set_defense")
    composer.gotoScene(prevScene)
end

local function redraw()
    composer.removeScene("Scenes.set_defense")
    composer.gotoScene("Scenes.set_defense")
end

local function showPlayerCard(name, initialX, initialY, i)
    local function selectPlayer()
        defensiveStrategy = i
        redraw()
    end

    local playerBorder = display.newRect(sceneGroup, initialX, initialY, display.contentWidth / 8, display.contentHeight / 8)
    playerBorder:setFillColor(0, 0, 0, 0)
    playerBorder:addEventListener("tap", selectPlayer)

    if(defensiveStrategy == i) then
        playerBorder:setStrokeColor(0, 0, 1)
        playerBorder.strokeWidth = 4
    else
        playerBorder:setStrokeColor(.922, .910, .329)
        playerBorder.strokeWidth = 2
    end

    local playerName = display.newText(sceneGroup, name, playerBorder.x, playerBorder.y, native.systemFont, 12)
    playerName:setFillColor(.922, .910, .329)
    playerName:addEventListener("tap", selectPlayer)
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

    createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, BLACK, BLACK, TRANSPARENT, nextScene)

    for i = 1, 5 do
        showPlayerCard(strategyNames[i], display.contentWidth * i / 6, display.contentHeight / 5, i)
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
