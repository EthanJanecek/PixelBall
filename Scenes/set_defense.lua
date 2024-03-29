local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local strategyNames = {"Overall", "Speed", "Interior\nDefending", "Exterior\nDefending", "Height"}

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

local function showPlayerCard(name, initialX, initialY, i)
    local function selectPlayer()
        defensiveStrategy = i
        redraw()
    end

    local playerBorder = display.newRect(sceneGroup, initialX, initialY, display.contentWidth / 8, display.contentHeight / 8)
    playerBorder:setFillColor(TRANSPARENT[1], TRANSPARENT[2], TRANSPARENT[3], TRANSPARENT[4])
    playerBorder:addEventListener("tap", selectPlayer)

    if(defensiveStrategy == i) then
        playerBorder:setStrokeColor(0, 0, 1)
        playerBorder.strokeWidth = 4
    else
        playerBorder:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
        playerBorder.strokeWidth = 2
    end

    local playerName = display.newText(sceneGroup, name, playerBorder.x, playerBorder.y, native.systemFont, 12)
    playerName:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    playerName:addEventListener("tap", selectPlayer)
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

    createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextScene)

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
