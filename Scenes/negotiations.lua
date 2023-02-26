
local composer = require( "composer" )

local scene = composer.newScene()
local sceneGroup = nil
local player = nil
local team = nil
local salaryOptions = {1000000, 2000000, 5000000, 10000000, 15000000, 20000000, 25000000, 30000000, 35000000, 40000000}
local lengthOptions = {1, 2, 3, 4}

local salaryIndex = 0
local lengthIndex = 0

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    local options = {
        params = {
            team = team
        }
    }

    composer.gotoScene("Scenes.free_agency", options)
end

local function reloadScene(deltaSalary, deltaLength)
    local options = {
        params = {
            player = player,
            team = team,
            salary = salaryIndex + deltaSalary,
            length = lengthIndex + deltaLength
        }
    }

    composer.gotoScene("Scenes.load_scene", options)
end

local function displayString(text, x, y)
    local label = display.newText(sceneGroup, text, x, y, native.systemFont, 16)
    label:setFillColor(.922, .910, .329)
end

local function showContractOptions()
    local function lastContractValue()
        reloadScene(-1, 0)
    end

    local function nextContractValue()
        reloadScene(1, 0)
    end

    local function lastYearsValue()
        reloadScene(0, -1)
    end

    local function nextYearsValue()
        reloadScene(0, 1)
    end

    -- Salary Selector
    displayString("Salary", display.contentCenterX, display.contentHeight * .2)
    displayString(formatContractMoney(salaryOptions[salaryIndex]), display.contentCenterX, display.contentHeight * .25)

    if(salaryIndex ~= 1) then
        createButtonWithBorder(sceneGroup, "<-", 16, display.contentWidth * .4, display.contentHeight * .25, 2, BLACK, BLACK, TRANSPARENT, lastContractValue)
    end

    if(salaryIndex ~= #salaryOptions) then
        createButtonWithBorder(sceneGroup, "->", 16, display.contentWidth * .6, display.contentHeight * .25, 2, BLACK, BLACK, TRANSPARENT, nextContractValue)
    end

    -- Length Selector
    displayString("Length", display.contentCenterX, display.contentHeight * .4)
    displayString(lengthIndex, display.contentCenterX, display.contentHeight * .45)

    if(lengthIndex ~= 1) then
        createButtonWithBorder(sceneGroup, "<-", 16, display.contentWidth * .4, display.contentHeight * .45, 2, BLACK, BLACK, TRANSPARENT, lastYearsValue)
    end

    if(lengthIndex ~= #lengthOptions) then
        createButtonWithBorder(sceneGroup, "->", 16, display.contentWidth * .6, display.contentHeight * .45, 2, BLACK, BLACK, TRANSPARENT, nextYearsValue)
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view
    player = event.pararms.player
    team = event.pararms.team

	-- Code here runs when the scene is first created but has not yet appeared on screen	
	local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local nameStr = "#" .. player.number .. " - " .. player.name
    local startersLabel = display.newText(sceneGroup, nameStr, display.contentCenterX, 24, native.systemFont, 24)
    startersLabel:setFillColor(.922, .910, .329)

    local fairSalary = calculateFairSalary(player)
    table.insert(salaryOptions, fairSalary)

    if(team.name == userTeam) then
        table.insert(salaryOptions, 45000000)
        table.insert(salaryOptions, 50000000)
    end

    table.sort(salaryOptions, function(a, b)
        return a < b
    end)

    salaryIndex = event.params.salary or indexOf(salaryOptions, fairSalary)
    lengthIndex = event.params.length or 4

	createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, BLACK, BLACK, TRANSPARENT, nextScene)
    showPlayerAttributes()
    showContractOptions()
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
