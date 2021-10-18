local composer = require( "composer" )
local scene = composer.newScene()

local positions = {"1 - PG", "2 - SG", "3 - SF", "4 - PF", "5 - C"}
local sceneGroup = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
function nextScene()
	composer.removeScene("Scenes.lineup")
    composer.gotoScene("Scenes.pregame")
end

function redraw()
    composer.removeScene("Scenes.lineup")
    composer.gotoScene("Scenes.lineup")
end

local function switchPlayers()
    local team = league:findTeam(userTeam)
    local tmp = team.players[lineupSwitch[1]]
    team.players[lineupSwitch[1]] = team.players[lineupSwitch[2]]
    team.players[lineupSwitch[2]] = tmp

    lineupSwitch = {-1, -1}
end

local function getName(name)
    local params = {}
    
    for param in string.gmatch(name, "([^ ]+)") do
        table.insert(params, param)
    end
    
    return string.sub(params[1], 1, 1) .. ". " .. string.sub(params[2], 1, 7)
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

    local playerBorder = display.newRect(initialX, initialY, display.contentWidth / 8, display.contentHeight / 5)
    playerBorder:setFillColor(0, 0, 0, 0)
    playerBorder:addEventListener("tap", selectPlayer)
    if(i == lineupSwitch[1]) then
        playerBorder:setStrokeColor(0, 0, 1)
        playerBorder.strokeWidth = 4
    else
        playerBorder:setStrokeColor(0, 0, 0)
        playerBorder.strokeWidth = 2
    end

    if(i <= 5) then
        local positionStr = display.newText(sceneGroup, positions[i], initialX, initialY + (playerBorder.height / 2) + 10, native.systemFont, 16)
        positionStr:setFillColor(0, 0, 0)
    end

    local playerName = display.newText(sceneGroup, getName(player.name), playerBorder.x, playerBorder.y - playerBorder.height / 3, native.systemFont, 12)
    playerName:setFillColor(.922, .910, .329)
    playerName:addEventListener("tap", selectPlayer)

    local paramStr1 = "DRB: " .. player.dribbling .. "  STL: " .. player.stealing
    local paramStr2 = "SHT: " .. player.shooting .. "  BLK: " .. player.blocking
    local paramStr3 = "FNS: " .. player.finishing .. "  CNT: " .. player.contesting
    local paramStr4 = "SPD: " .. player.speed .. "  HGT: " .. player.height
    local paramStr5 = "STAMINA: " .. player.stamina

    local param1 = display.newText(sceneGroup, paramStr1, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 12, native.systemFont, 8)
    param1:setFillColor(.922, .910, .329)
    param1:addEventListener("tap", selectPlayer)

    local param2 = display.newText(sceneGroup, paramStr2, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 12 + 8, native.systemFont, 8)
    param2:setFillColor(.922, .910, .329)
    param2:addEventListener("tap", selectPlayer)

    local param3 = display.newText(sceneGroup, paramStr3, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 12 + 8 * 2, native.systemFont, 8)
    param3:setFillColor(.922, .910, .329)
    param3:addEventListener("tap", selectPlayer)

    local param4 = display.newText(sceneGroup, paramStr4, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 12 + 8 * 3, native.systemFont, 8)
    param4:setFillColor(.922, .910, .329)
    param4:addEventListener("tap", selectPlayer)

    local param5 = display.newText(sceneGroup, paramStr5, playerBorder.x, playerBorder.y - (playerBorder.height / 3) + 12 + 8 * 4, native.systemFont, 8)
    param5:setFillColor(.922, .910, .329)
    param5:addEventListener("tap", selectPlayer)
end

local function showPlayer(i)
    local team = league:findTeam(userTeam)
    local player = team.players[i]

    if(i <= 5) then
        showPlayerCard(player, display.contentWidth * i / 6, display.contentHeight / 5, i)
    elseif(i <= 10) then
       showPlayerCard(player, display.contentWidth * (i - 5) / 6, display.contentHeight * 3 / 5, i)
    else
        showPlayerCard(player, display.contentWidth * (i - 10) / 6, display.contentHeight * 4 / 5 + 10, i)
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

	local startersLabel = display.newText(sceneGroup, "Starters", display.contentCenterX, 16, native.systemFont, 32)
    startersLabel:setFillColor(.922, .910, .329)

    local benchLabel = display.newText(sceneGroup, "Bench", display.contentCenterX, display.contentHeight / 3 + 25,  native.systemFont, 32)
    benchLabel:setFillColor(.922, .910, .329)

    local playButton = display.newText(sceneGroup, "<- Back", 8, 8, native.systemFont, 16)
    playButton:setFillColor(0, 0, 0)
    playButton:addEventListener("tap", nextScene)

    local buttonBorder = display.newRect(sceneGroup, playButton.x, playButton.y, playButton.width, playButton.height)
    buttonBorder:setStrokeColor(0, 0, 0)
    buttonBorder.strokeWidth = 2
    buttonBorder:setFillColor(0, 0, 0, 0)
    buttonBorder:addEventListener("tap", nextScene)
    
    for i = 1, 15 do
        showPlayer(i)
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
