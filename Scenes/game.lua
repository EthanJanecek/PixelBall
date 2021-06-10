local StickLib   = require("Objects.virtual_joystick")
local composer = require("composer")

local scene = composer.newScene()
local offense = true

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function controlPlayers(mainGroup, uiGroup, userTeam, opponent)
    -- CREATE ANALOG STICK
    MyStick = StickLib.NewStick( 
        {
        x = display.contentWidth * .0625,
        y = display.contentHeight * .85,
        thumbSize = 8,
        borderSize = 16,
        snapBackSpeed = .2,
        R = 25,
        G = 255,
        B = 255,
        group = uiGroup,
    })

    local player
    for i = 1, 5 do
        local play = userTeam.playbook.plays[1]
        local positions = play.routes[i].points[1]

        local playerImage = display.newImageRect(mainGroup, "images/playerModels/nba_player_red_back.png", 32, 48)
        playerImage.x = tonumber(positions.x)
        playerImage.y = tonumber(positions.y)

        if(i == 3) then
            player = playerImage
        end
    end

    local function move()
        MyStick:move(player, 1)
    end

    Runtime:addEventListener( "enterFrame", move )
end

local function gameLoop(mainGroup, uiGroup)
    local userTeam = league:findTeam(userTeam)
    local gameInfo = userTeam.schedule[league.gameNum]
    local opponent = league:findTeam(gameInfo.opponent)

    controlPlayers(mainGroup, uiGroup, userTeam, opponent)
end

local function setBackdrop(backGroup)
    local background = display.newRect(backGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local conversionFactor = display.contentHeight / 970
    print(display.contentHeight)
    print(display.contentWidth)
    local backgroundImage = display.newImageRect(backGroup, "images/NbaCourt.png", 1000 * conversionFactor, 970 * conversionFactor)
    backgroundImage.x = display.contentCenterX
    backgroundImage.y = display.contentCenterY
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local backGroup = display.newGroup()
    local mainGroup = display.newGroup()
    local uiGroup = display.newGroup()

	-- Code here runs when the scene is first created but has not yet appeared on screen
    setBackdrop(backGroup)
    gameLoop(mainGroup, uiGroup)
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
