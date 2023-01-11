local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil

local statPositions = {
    0,      -- Name
    .25,    -- Pts
    .35,    -- 2PM
    .425,     -- 2PA
    .525,    -- 3PM
    .6,    -- 3PA
    .7,      -- BLK
    .8,      -- STL
    .9,       -- TRV
    1       -- +/-
}

local fontSize = 12
local rowDist = 16
local paddingX = 8
local paddingY = 70

local qtrWidth = 30
local qtrOffsetPercent = .5

local game = nil
local awayTeam = true

local imageSize = 30
local offsetY = 40

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
	composer.removeScene("Scenes.boxscore_other_teams")
    composer.gotoScene("Scenes.score_recap")
end

local function switchTeam()
    local options = {
        params = {
            game = game,
            away = not awayTeam
        }
    }

	composer.removeScene("Scenes.boxscore_other_teams")
    composer.gotoScene("Scenes.boxscore_other_teams", options)
end

local function showGameScore(game)
    local awayTeam = league:findTeam(game.away)
    local homeTeam = league:findTeam(game.home)
    local x = display.contentWidth / 2
    local y = imageSize / 2

    local boxscoreBox = display.newRect(sceneGroup, x + 50, y + 6, 100 + imageSize, 12 + imageSize)
    boxscoreBox:setFillColor(.286, .835, .961)

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

local function displayHeader()
    local name = display.newText(sceneGroup, "Name", display.contentWidth * statPositions[1] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    name:setFillColor(.922, .910, .329)

    local pts = display.newText(sceneGroup, "Pts", display.contentWidth * statPositions[2] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    pts:setFillColor(.922, .910, .329)

    local twoPM = display.newText(sceneGroup, "2PM", display.contentWidth * statPositions[3] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(.922, .910, .329)

    local twoPA = display.newText(sceneGroup, "2PA", display.contentWidth * statPositions[4] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(.922, .910, .329)

    local threePM = display.newText(sceneGroup, "3PM", display.contentWidth * statPositions[5] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePM:setFillColor(.922, .910, .329)

    local threePA = display.newText(sceneGroup, "3PA", display.contentWidth * statPositions[6] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePA:setFillColor(.922, .910, .329)

    local blocks = display.newText(sceneGroup, "BLK", display.contentWidth * statPositions[7] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    blocks:setFillColor(.922, .910, .329)

    local steals = display.newText(sceneGroup, "STL", display.contentWidth * statPositions[8] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    steals:setFillColor(.922, .910, .329)

    local turnovers = display.newText(sceneGroup, "TRV", display.contentWidth * statPositions[9] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(.922, .910, .329)

    local plusMinus = display.newText(sceneGroup, "+/-", display.contentWidth * statPositions[10] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(.922, .910, .329)

    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX, paddingY + 4, display.contentWidth * 1.5, 2)
    dividerHorizontal:setStrokeColor(.922, .910, .329)
    dividerHorizontal:setFillColor(.922, .910, .329)
end

local function showPlayerStats(player, row)
    local stats = player.gameStats

    local name = display.newText(sceneGroup, player.name, display.contentWidth * statPositions[1] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    name:setFillColor(.922, .910, .329)

    local pts = display.newText(sceneGroup, stats.points, display.contentWidth * statPositions[2] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    pts:setFillColor(.922, .910, .329)

    local twoPM = display.newText(sceneGroup, stats.twoPM, display.contentWidth * statPositions[3] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(.922, .910, .329)

    local twoPA = display.newText(sceneGroup, stats.twoPA, display.contentWidth * statPositions[4] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(.922, .910, .329)

    local threePM = display.newText(sceneGroup, stats.threePM, display.contentWidth * statPositions[5] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePM:setFillColor(.922, .910, .329)

    local threePA = display.newText(sceneGroup, stats.threePA, display.contentWidth * statPositions[6] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePA:setFillColor(.922, .910, .329)

    local blocks = display.newText(sceneGroup, stats.blocks, display.contentWidth * statPositions[7] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    blocks:setFillColor(.922, .910, .329)

    local steals = display.newText(sceneGroup, stats.steals, display.contentWidth * statPositions[8] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    steals:setFillColor(.922, .910, .329)

    local turnovers = display.newText(sceneGroup, stats.turnovers, display.contentWidth * statPositions[9] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(.922, .910, .329)

    local plusMinus = display.newText(sceneGroup, stats.plusMinus, display.contentWidth * statPositions[10] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(.922, .910, .329)
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    game = event.params.game
    awayTeam = event.params.away

    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    createButtonWithBorder(sceneGroup, "<- Back", 16, 0, 8, 2, BLACK, BLACK, TRANSPARENT, nextScene)
    createButtonWithBorder(sceneGroup, "Switch Team", 16, 0, 40, 2, BLACK, BLACK, TRANSPARENT, switchTeam)

    showGameScore(game)
    displayHeader()

    local home = league:findTeam(game.home)
    local away = league:findTeam(game.away)
    
    if(awayTeam) then
        for i = 1, #away.players do
            showPlayerStats(away.players[i], i)
        end
    else
        for i = 1, #home.players do
            showPlayerStats(home.players[i], i)
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
