
local composer = require( "composer" )

local scene = composer.newScene()
local sceneGroup = nil
local player = nil
local salaryOptions = {1000000, 2000000, 5000000, 10000000, 15000000, 20000000, 25000000, 30000000, 35000000, 40000000, 45000000, 50000000}
local lengthOptions = {1, 2, 3, 4}

local salaryIndex = 0
local lengthIndex = 0

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    composer.gotoScene("Scenes.free_agency")
end

local function submit()
    local options = {
        params = {
            offer = OfferLib:createOffer(league:findTeam(userTeam), player, salaryOptions[salaryIndex], lengthOptions[lengthIndex])
        }
    }

    composer.gotoScene("Scenes.submit_offer", options)
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
    label:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
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
        createButtonWithBorder(sceneGroup, "<-", 16, display.contentWidth * .35, display.contentHeight * .25, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, lastContractValue)
    end

    if(salaryIndex ~= #salaryOptions) then
        createButtonWithBorder(sceneGroup, "->", 16, display.contentWidth * .65, display.contentHeight * .25, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextContractValue)
    end

    -- Length Selector
    displayString("Length", display.contentCenterX, display.contentHeight * .4)
    displayString(lengthIndex, display.contentCenterX, display.contentHeight * .45)

    if(lengthIndex ~= 1) then
        createButtonWithBorder(sceneGroup, "<-", 16, display.contentWidth * .35, display.contentHeight * .45, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, lastYearsValue)
    end

    if(lengthIndex ~= #lengthOptions) then
        createButtonWithBorder(sceneGroup, "->", 16, display.contentWidth * .65, display.contentHeight * .45, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextYearsValue)
    end
end

local function canSubmitOffer()
    local team = league:findTeam(userTeam)
    return calculateCap(team) + salaryOptions[salaryIndex] < team.cap and #team.players < 15
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view
    player = event.params.player

	-- Code here runs when the scene is first created but has not yet appeared on screen	
	local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local nameStr = "#" .. player.number .. " - " .. player.name .. " - Year " .. player.years
    local startersLabel = display.newText(sceneGroup, nameStr, display.contentCenterX, 24, native.systemFont, 24)
    startersLabel:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local fairSalary = calculateFairSalary(player)
    table.insert(salaryOptions, fairSalary)

    table.sort(salaryOptions, function(a, b)
        return a < b
    end)

    -- Remove salaries below fair salary
    while(salaryOptions[1] ~= fairSalary) do
        table.remove(salaryOptions, 1)
    end

    salaryIndex = event.params.salary or indexOf(salaryOptions, fairSalary)
    lengthIndex = event.params.length or 4

	createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextScene)
    if(canSubmitOffer()) then
        createButtonWithBorder(sceneGroup, "Submit Offer", 16, display.contentWidth - 8, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, submit)
    end
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
