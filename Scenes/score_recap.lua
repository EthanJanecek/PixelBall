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
    local function seeBoxscore()
        local options = {
            params = {
                game = game,
                away = true
            }
        }
    
        composer.removeScene("Scenes.score_recap")
        composer.gotoScene("Scenes.boxscore_other_teams", options)
        return true
    end

    local awayTeam = league:findTeam(game.away)
    local homeTeam = league:findTeam(game.home)
    local x = xIndex * (display.contentWidth / 3)
    local y = yIndex * (display.contentHeight / 5) + offsetY

    local boxscoreBox = display.newRect(sceneGroup, x + 50, y + 6, 100 + imageSize, 12 + imageSize)
    boxscoreBox:setFillColor(.286, .835, .961)

    local awayLogo = display.newImageRect(sceneGroup, awayTeam.logo, imageSize, imageSize)
    awayLogo.x = x
    awayLogo.y = y

    local homeLogo = display.newImageRect(sceneGroup, homeTeam.logo, imageSize, imageSize)
    homeLogo.x = x + 100
    homeLogo.y = y

    if(game.score.away) then
        boxscoreBox:addEventListener("tap", seeBoxscore)
        local scoreStr = game.score.away .. " - " .. game.score.home
        local score = display.newText(sceneGroup, scoreStr, 0, y, native.systemFont, 16)
        score.x = x + imageSize + ((110 - score.width) / 2)
        score:setFillColor(.922, .910, .329)
    end

    if(regularSeason) then
        local awayRecordStr = "(" .. awayTeam.wins .. "-" .. awayTeam.losses .. ")"
        local awayRecord = display.newText(sceneGroup, awayRecordStr, x, y + (imageSize / 2) + 6, native.systemFont, 12)
        awayRecord:setFillColor(.922, .910, .329)

        local homeRecordStr = "(" .. homeTeam.wins .. "-" .. homeTeam.losses .. ")"
        local homeRecord = display.newText(sceneGroup, homeRecordStr, x + 100, y + (imageSize / 2) + 6, native.systemFont, 12)
        homeRecord:setFillColor(.922, .910, .329)
    elseif(playoffs) then
        awayTeam = league:findPlayoffTeam(game.away)
        homeTeam = league:findPlayoffTeam(game.home)

        local awayRecordStr = awayTeam.wins
        local awayRecord = display.newText(sceneGroup, awayRecordStr, x, y + (imageSize / 2) + 6, native.systemFont, 12)
        awayRecord:setFillColor(.922, .910, .329)

        local homeRecordStr = homeTeam.wins
        local homeRecord = display.newText(sceneGroup, homeRecordStr, x + 100, y + (imageSize / 2) + 6, native.systemFont, 12)
        homeRecord:setFillColor(.922, .910, .329)
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
    background:addEventListener("tap", nextWeek)

    local allGames = nil
    if(regularSeason) then
        allGames = league.schedule[league.weekNum - 1]
    else
        allGames = league.playoffs[league.weekNum - 1]
    end

    for i = 1, #allGames do
        showGameScore(allGames[i], (i - 1) % 3, math.floor((i - 1) / 3))
    end

    if(league.weekNum == numDays + 1) then
        league:startPlayoffs()
    elseif(not regularSeason and league.weekNum == 2) then
        league:playinRoundTwo()
    elseif(not regularSeason and league.weekNum == 3) then
        league:firstRound()
    elseif(not regularSeason and league.weekNum == 10) then
        league:secondRound()
    elseif(not regularSeason and league.weekNum == 17) then
        league:conferenceChampionship()
    elseif(not regularSeason and league.weekNum == 24) then
        league:finals()
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
