local TeamLib = require("Objects.team")
local league = {}

local leagueAvgFinishing = 68
local leagueAvgClose = 43
local leagueAvgMidRange = 40
local leagueAvg3 = 37

local skillScaling = 3
local playerPercentages = {40, 70, 85, 95, 100}
local heightDiffMin = 5
local heightDiffMax = 15

local numDays = 200
local maxLoops = 200

local staminaRunningUsage = -.1
local shotStaminaUsage = -.2
local staminaStandingRegen = -staminaRunningUsage / 2
local staminaBenchRegen = -staminaRunningUsage * 3

function league:createLeague()
    self.__index = self

    return setmetatable({
        teams=createTeams(),
        weekNum=1,
        schedule={}
    }, self)
end

function createTeams()
    local teams = {}

    -- Eastern Conference
    -- Atlantic Division
    table.insert(teams, TeamLib:create("76ers", "PHI", "images/logos/76ers.png", "East", "Atlantic", "blue", "_python/WebScraper/data/philadelphia-76ers.csv"))
    table.insert(teams, TeamLib:create("Nets", "BKN", "images/logos/nets.png", "East", "Atlantic", "black", "_python/WebScraper/data/brooklyn-nets.csv"))
    table.insert(teams, TeamLib:create("Celtics", "BOS", "images/logos/celtics.png", "East", "Atlantic", "green", "_python/WebScraper/data/boston-celtics.csv"))
    table.insert(teams, TeamLib:create("Raptors", "TOR", "images/logos/raptors.png", "East", "Atlantic", "red", "_python/WebScraper/data/toronto-raptors.csv"))
    table.insert(teams, TeamLib:create("Knicks", "NYK", "images/logos/knicks.png", "East", "Atlantic", "blue", "_python/WebScraper/data/new-york-knicks.csv"))

    -- Central Division
    table.insert(teams, TeamLib:create("Bucks", "MIL", "images/logos/bucks.png", "East", "Central", "green", "_python/WebScraper/data/milwaukee-bucks.csv"))
    table.insert(teams, TeamLib:create("Pacers", "IND", "images/logos/pacers.png", "East", "Central", "yellow", "_python/WebScraper/data/indiana-pacers.csv"))
    table.insert(teams, TeamLib:create("Pistons", "DET", "images/logos/pistons.png", "East", "Central", "blue", "_python/WebScraper/data/detroit-pistons.csv"))
    table.insert(teams, TeamLib:create("Bulls", "CHI", "images/logos/bulls.png", "East", "Central", "red", "_python/WebScraper/data/chicago-bulls.csv"))
    table.insert(teams, TeamLib:create("Cavaliers", "CLE", "images/logos/cavaliers.png", "East", "Central", "black", "_python/WebScraper/data/cleveland-cavaliers.csv"))

    -- Southeast Division
    table.insert(teams, TeamLib:create("Heat", "MIA", "images/logos/heat.png", "East", "Southeast", "red", "_python/WebScraper/data/miami-heat.csv"))
    table.insert(teams, TeamLib:create("Magic", "ORL", "images/logos/magic.png", "East", "Southeast", "blue", "_python/WebScraper/data/orlando-magic.csv"))
    table.insert(teams, TeamLib:create("Hawks", "ATL", "images/logos/hawks.png", "East", "Southeast", "red", "_python/WebScraper/data/atlanta-hawks.csv"))
    table.insert(teams, TeamLib:create("Wizards", "WAS", "images/logos/wizards.png", "East", "Southeast", "blue", "_python/WebScraper/data/washington-wizards.csv"))
    table.insert(teams, TeamLib:create("Hornets", "CHA", "images/logos/hornets.png", "East", "Southeast", "blue", "_python/WebScraper/data/charlotte-hornets.csv"))

    -- Western Conference
    -- Pacific Division
    table.insert(teams, TeamLib:create("Lakers", "LAL", "images/logos/lakers.png", "West", "Pacific", "yellow", "_python/WebScraper/data/los-angeles-lakers.csv"))
    table.insert(teams, TeamLib:create("Clippers", "LAC", "images/logos/clippers.png", "West", "Pacific", "blue", "_python/WebScraper/data/los-angeles-clippers.csv"))
    table.insert(teams, TeamLib:create("Suns", "PHX", "images/logos/suns.png", "West", "Pacific", "purple", "_python/WebScraper/data/phoenix-suns.csv"))
    table.insert(teams, TeamLib:create("Warriors", "GSW", "images/logos/warriors.png", "West", "Pacific", "blue", "_python/WebScraper/data/golden-state-warriors.csv"))
    table.insert(teams, TeamLib:create("Kings", "SAC", "images/logos/kings.png", "West", "Pacific", "purple", "_python/WebScraper/data/sacramento-kings.csv"))

    -- Northwest Division
    table.insert(teams, TeamLib:create("Nuggets", "DEN", "images/logos/nuggets.png", "West", "Northwest", "blue", "_python/WebScraper/data/denver-nuggets.csv"))
    table.insert(teams, TeamLib:create("Jazz", "UTA", "images/logos/jazz.png", "West", "Northwest", "orange", "_python/WebScraper/data/utah-jazz.csv"))
    table.insert(teams, TeamLib:create("Trail Blazers", "POR", "images/logos/trail blazers.png", "West", "Northwest", "black", "_python/WebScraper/data/portland-trail-blazers.csv"))
    table.insert(teams, TeamLib:create("Thunder", "OKC", "images/logos/thunder.png", "West", "Northwest", "blue", "_python/WebScraper/data/oklahoma-city-thunder.csv"))
    table.insert(teams, TeamLib:create("Timberwolves", "MIN", "images/logos/timberwolves.png", "West", "Northwest", "blue", "_python/WebScraper/data/minnesota-timberwolves.csv"))

    -- Southwest Division
    table.insert(teams, TeamLib:create("Rockets", "HOU", "images/logos/rockets.png", "West", "Southwest", "red", "_python/WebScraper/data/houston-rockets.csv"))
    table.insert(teams, TeamLib:create("Spurs", "SAS", "images/logos/spurs.png", "West", "Southwest", "black", "_python/WebScraper/data/san-antonio-spurs.csv"))
    table.insert(teams, TeamLib:create("Pelicans", "NOP", "images/logos/pelicans.png", "West", "Southwest", "red", "_python/WebScraper/data/new-orleans-pelicans.csv"))
    table.insert(teams, TeamLib:create("Mavericks", "DAL", "images/logos/mavericks.png", "West", "Southwest", "blue", "_python/WebScraper/data/dallas-mavericks.csv"))
    table.insert(teams, TeamLib:create("Grizzlies", "MEM", "images/logos/grizzlies.png", "West", "Southwest", "cyan", "_python/WebScraper/data/memphis-grizzlies.csv"))

    return teams
end

function checkIfTeamPlays(weeklySchedule, team)
    if(weeklySchedule) then
        for i = 1, #weeklySchedule do
            if(weeklySchedule[i].home == team or weeklySchedule[i].away == team) then
                return true
            end
        end
    end

    return false
end

function league:findGameInfo(weeklySchedule, team)
    if(weeklySchedule) then
        for i = 1, #weeklySchedule do
            if(weeklySchedule[i].home == team or weeklySchedule[i].away == team) then
                return weeklySchedule[i]
            end
        end
    end

    return nil
end

function league:createSchedule()
    self.schedule = {}

    for i = 1, numDays do
        local weeklySchedule = {}
        table.insert(self.schedule, weeklySchedule)
    end

    for i = 1, 30 do
        local team1 = self.teams[i]

        for j = i + 1, 30 do
            local team2 = self.teams[j]

            local numGames = 2
            if(team1.conf == team2.conf) then
                numGames = 3
            end

            for k = 1, numGames do
                local weekNum = math.random(numDays)
                local loops = 0

                while(checkIfTeamPlays(self.schedule[weekNum], team1.name) or checkIfTeamPlays(self.schedule[weekNum], team2.name)) do
                    weekNum = math.random(numDays)
                    loops = loops + 1

                    if(loops > maxLoops) then
                        -- Don't want to get stuck in infinite loop
                        self.createSchedule()
                        break
                    end
                end
                
                if(k % 2 == 0) then
                    table.insert(self.schedule[weekNum], {away=team1.name, home=team2.name, score={}})
                else
                    table.insert(self.schedule[weekNum], {away=team2.name, home=team1.name, score={}})
                end
            end
        end
    end
end

function league:findTeam(name)
    for i = 1, 30 do
        local team = self.teams[i]

        if(team.name == name) then
            return team
        end
    end

    return {}
end

function league:nextWeek()
    local allGames = self.schedule[self.weekNum]

    for i = 1, #allGames do
        local game = allGames[i]
        if(game.away ~= userTeam and game.home ~= userTeam) then
            local score = simulateGame(self:findTeam(game.away), self:findTeam(game.home))
            game.score = score
        end
    end

    self:resetTeams()
    self.weekNum = self.weekNum + 1
end

local function changeStamina(player, diff)
    player.stamina = player.stamina + diff

    if(player.stamina > player.maxStamina) then
        player.stamina = player.maxStamina
    elseif(player.stamina < 1) then
        player.stamina = 1
    end
end

local function sumProps(player)
    return player.closeShot + player.midRange + player.three + player.finishing + player.contestingInterior + player.contestingExterior + player.height + player.dribbling
                + player.blocking + player.stealing + player.speed
end

local function indexOf(table, value)
    for i = 1, #table do
        if(table[i] == value) then
            return i
        end
    end

    return -1
end

local function staminaPercent(player)
    return player.stamina / player.maxStamina
end

local function findBestAvailableBenchPlayer(team)
    local len = #team.players

    for i = 6, len do
        if(team.players[i].starter == true and staminaPercent(team.players[i]) > .8) then
            return i
        end
    end

    local teamBench = {unpack(team.players, 6, len)}
    table.sort(teamBench, function (a, b) 
        return sumProps(a) > sumProps(b)
    end)

    for i = 1, #teamBench do
        if(staminaPercent(teamBench[i]) > .8) then
            return indexOf(team.players, teamBench[i])
        end
    end

    return 6
end

local function isStarterAvailable(team)
    for i = 6, #team.players do
        if(team.players[i].starter == true and staminaPercent(team.players[i]) > .8) then
            return true
        end
    end

    return false
end

local function setStarters(team)
    for i = 1, 5 do
        if(not team.players[i].starter) then
            local j = findBestAvailableBenchPlayer(team)
            local tmp = team.players[i]
            team.players[i] = team.players[j]
            team.players[j] = tmp
        end
    end
end

local function resetStamina(team)
    for i = 1, #team.players do
        team.players[i].stamina = team.players[i].maxStamina
    end
end

function league:resetTeams()
    for i = 1, 30 do
        resetStamina(self.teams[i])
        setStarters(self.teams[i])
    end
end

local function subPlayers(team)
    for i = 1, 5 do
        if(staminaPercent(team.players[i]) < .5 or (not team.players[i].starter and isStarterAvailable(team))) then
            local j = findBestAvailableBenchPlayer(team)
            local tmp = team.players[i]
            team.players[i] = team.players[j]
            team.players[j] = tmp
        end
    end
end

function simulateGame(away, home)
    local index = math.random(1, 2)
    local maxTime = 4 * minutesInQtr * 60
    local time = 0
    local score = {away = 0, home = 0}

    while time <= maxTime do
        if index % 2 == 0 then
            local result = simulatePossession(home, away)
            score.home = score.home + result.points
            time = time + result.time
        else
            local result = simulatePossession(away, home)
            score.away = score.away + result.points
            time = time + result.time
        end

        index = index + 1
    end

    -- Don't allow ties
    while(score.home == score.away) do
        -- Simulate 5 possessions each
        for i = 1, 5 do
            local result = simulatePossession(home, away)
            score.home = score.home + result.points
            time = time + result.time

            result = simulatePossession(away, home)
            score.away = score.away + result.points
            time = time + result.time
        end
    end
    
    if(score.home > score.away) then
        home.wins = home.wins + 1
        away.losses = away.losses + 1
    else
        away.wins = away.wins + 1
        home.losses = home.losses + 1
    end

    return score
end

local function changeTeamStamina(offense, defense, player, defender)
    changeStamina(player, shotStaminaUsage + staminaRunningUsage)
    changeStamina(defender, staminaRunningUsage)
    
    for i = 1, #offense.players do
        if(offense.players[i] ~= player) then
            if(i > 5) then
                changeStamina(offense.players[i], staminaBenchRegen)
            else
                changeStamina(offense.players[i], staminaStandingRegen)
            end
        end
    end

    for i = 1, #defense.players do
        if(defense.players[i] ~= defender) then
            if(i > 5) then
                changeStamina(defense.players[i], staminaBenchRegen)
            else
                changeStamina(defense.players[i], staminaStandingRegen)
            end
        end
    end
end

function simulatePossession(offense, defense)
    subPlayers(offense)
    local teamStarters = {unpack(offense.players, 1, 5)}
    table.sort(teamStarters, function (a, b) 
        return (a.closeShot + a.midRange + a.three + a.finishing) > (b.closeShot + b.midRange + b.three + b.finishing)
    end)

    local opponentStarters = {unpack(defense.players, 1, 5)}
    table.sort(opponentStarters, function (a, b)
        return (a.contestingInterior + a.contestingExterior) > (b.contestingInterior + b.contestingExterior)
    end)

    local playerNum = math.random(1, 100)
    local player = teamStarters[1]
    local defender = opponentStarters[1]

    for i = 1, 5 do
        if(playerNum <= playerPercentages[i]) then
            player = teamStarters[i]
            defender = opponentStarters[i]
            break
        end
    end

    local max = player.finishing + player.closeShot + player.midRange + player.three
    local shotType = math.random(max)
    local time = math.random(6, 24)
    local points = 0

    local heightDiff = player.height - defender.height + 10 -- Will be from 0-20
    if(heightDiff < heightDiffMin) then
        heightDiff = heightDiffMin
    elseif(heightDiff > heightDiffMax) then
        heightDiff = heightDiffMax
    end

    if(shotType <= player.finishing) then
        points = calculatePoints(player.finishing * staminaPercent(player), defender.contestingInterior * staminaPercent(defender), heightDiff, leagueAvgFinishing, 2)
    elseif(shotType <= (player.finishing + player.closeShot)) then
        points = calculatePoints(player.closeShot * staminaPercent(player), defender.contestingInterior * staminaPercent(defender), heightDiff, leagueAvgClose, 2)
    elseif(shotType <= (player.finishing + player.closeShot + player.midRange)) then
        points = calculatePoints(player.midRange * staminaPercent(player), defender.contestingExterior * staminaPercent(defender), heightDiff, leagueAvgMidRange, 2)
    else
        points = calculatePoints(player.three * staminaPercent(player), defender.contestingExterior * staminaPercent(defender), heightDiff, leagueAvg3, 3)
    end

    changeTeamStamina(offense, defense, player, defender)
    
    return {points=points, time=time}
end

function calculatePoints(shooterSkill, defenderSkill, heightDiff, leagueAvg, maxPoints)
    local shotPercent = math.random(100)
    local heightFactor = (shooterSkill - defenderSkill >= 0) and (heightDiff / 10) or (10 / heightDiff)
    local scaling = (shooterSkill - defenderSkill) * skillScaling * heightFactor
    local percentageMade = leagueAvg + scaling

    if(shotPercent <= percentageMade) then
        return maxPoints
    else
        return 0
    end
end

return league