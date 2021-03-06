local composer = require( "composer" )
local scene = composer.newScene()
local sceneGroup = nil

local imageSize = 30
local offsetY = 40

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextWeek()
    composer.removeScene("Scenes.score_recap")
    composer.gotoScene("Scenes.pregame")
end

local function showGameScore(game, xIndex, yIndex)
    local awayTeam = league:findTeam(game.away)
    local homeTeam = league:findTeam(game.home)
    local x = xIndex * (display.contentWidth / 3)
    local y = yIndex * (display.contentHeight / 5) + offsetY

    local awayLogo = display.newImageRect(sceneGroup, awayTeam.logo, imageSize, imageSize)
    awayLogo.x = x
    awayLogo.y = y

    local homeLogo = display.newImageRect(sceneGroup, homeTeam.logo, imageSize, imageSize)
    homeLogo.x = x + 100
    homeLogo.y = y

    local scoreStr = game.score.away .. " - " .. game.score.home
    local score = display.newText(sceneGroup, scoreStr, 0, y, native.systemFont, 16)
    score.x = x + imageSize + ((110 - score.width) / 2)
    score:setFillColor(.922, .910, .329)

    local awayRecordStr = "(" .. awayTeam.wins .. "-" .. awayTeam.losses .. ")"
    local awayRecord = display.newText(sceneGroup, awayRecordStr, x, y + (imageSize / 2) + 6, native.systemFont, 12)
    awayRecord:setFillColor(.922, .910, .329)

    local homeRecordStr = "(" .. homeTeam.wins .. "-" .. homeTeam.losses .. ")"
    local homeRecord = display.newText(sceneGroup, homeRecordStr, x + 100, y + (imageSize / 2) + 6, native.systemFont, 12)
    homeRecord:setFillColor(.922, .910, .329)
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
    background:addEventListener("tap", nextWeek)

    league:nextWeek()
    local allGames = league.schedule[league.weekNum - 1]

    for i = 1, #allGames do
        showGameScore(allGames[i], (i - 1) % 3, math.floor((i - 1) / 3))
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
