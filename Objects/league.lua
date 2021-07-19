local TeamLib = require("Objects.team")
local league = {}

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
    table.insert(teams, TeamLib:create("76ers", "images/logos/76ers.png", "East", "Atlantic", "blue"))
    table.insert(teams, TeamLib:create("Nets", "images/logos/nets.png", "East", "Atlantic", "black"))
    table.insert(teams, TeamLib:create("Celtics", "images/logos/celtics.png", "East", "Atlantic", "green"))
    table.insert(teams, TeamLib:create("Raptors", "images/logos/raptors.png", "East", "Atlantic", "red"))
    table.insert(teams, TeamLib:create("Knicks", "images/logos/knicks.png", "East", "Atlantic", "blue"))

    -- Central Division
    table.insert(teams, TeamLib:create("Bucks", "images/logos/bucks.png", "East", "Central", "green"))
    table.insert(teams, TeamLib:create("Pacers", "images/logos/pacers.png", "East", "Central", "yellow"))
    table.insert(teams, TeamLib:create("Pistons", "images/logos/pistons.png", "East", "Central", "blue"))
    table.insert(teams, TeamLib:create("Bulls", "images/logos/bulls.png", "East", "Central", "red"))
    table.insert(teams, TeamLib:create("Cavaliers", "images/logos/cavaliers.png", "East", "Central", "black"))

    -- Southeast Division
    table.insert(teams, TeamLib:create("Heat", "images/logos/heat.png", "East", "Southeast", "red"))
    table.insert(teams, TeamLib:create("Magic", "images/logos/magic.png", "East", "Southeast", "blue"))
    table.insert(teams, TeamLib:create("Hawks", "images/logos/hawks.png", "East", "Southeast", "red"))
    table.insert(teams, TeamLib:create("Wizards", "images/logos/wizards.png", "East", "Southeast", "blue"))
    table.insert(teams, TeamLib:create("Hornets", "images/logos/hornets.png", "East", "Southeast", "blue"))

    -- Western Conference
    -- Pacific Division
    table.insert(teams, TeamLib:create("Lakers", "images/logos/lakers.png", "West", "Pacific", "yellow"))
    table.insert(teams, TeamLib:create("Clippers", "images/logos/clippers.png", "West", "Pacific", "blue"))
    table.insert(teams, TeamLib:create("Suns", "images/logos/suns.png", "West", "Pacific", "purple"))
    table.insert(teams, TeamLib:create("Warriors", "images/logos/warriors.png", "West", "Pacific", "blue"))
    table.insert(teams, TeamLib:create("Kings", "images/logos/kings.png", "West", "Pacific", "purple"))

    -- Northwest Division
    table.insert(teams, TeamLib:create("Nuggets", "images/logos/nuggets.png", "West", "Northwest", "blue"))
    table.insert(teams, TeamLib:create("Jazz", "images/logos/jazz.png", "West", "Northwest", "orange"))
    table.insert(teams, TeamLib:create("Trail Blazers", "images/logos/trail blazers.png", "West", "Northwest", "black"))
    table.insert(teams, TeamLib:create("Thunder", "images/logos/thunder.png", "West", "Northwest", "blue"))
    table.insert(teams, TeamLib:create("Timberwolves", "images/logos/timberwolves.png", "West", "Northwest", "blue"))

    -- Southwest Division
    table.insert(teams, TeamLib:create("Rockets", "images/logos/rockets.png", "West", "Southwest", "red"))
    table.insert(teams, TeamLib:create("Spurs", "images/logos/spurs.png", "West", "Southwest", "black"))
    table.insert(teams, TeamLib:create("Pelicans", "images/logos/pelicans.png", "West", "Southwest", "red"))
    table.insert(teams, TeamLib:create("Mavericks", "images/logos/mavericks.png", "West", "Southwest", "blue"))
    table.insert(teams, TeamLib:create("Grizzlies", "images/logos/grizzlies.png", "West", "Southwest", "cyan"))

    return teams
end

function league:shuffleGames()
    for j = 1, 50 do
        -- Shuffle weekly games 50 times
        local old = math.random(1, 72)
        local new = math.random(1, 72)
        self.schedule[old], self.schedule[new] = self.schedule[new], self.schedule[old]
    end
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
    for i = 1, 100 do
        local weeklySchedule = {}
        table.insert(self.schedule, weeklySchedule)
    end

    for i = 1, 30 do
        local team1 = self.teams[i]
        local weekNum = 1

        for j = i + 1, 30 do
            local team2 = self.teams[j]

            local numGames = 2
            if(team1.conf == team2.conf) then
                numGames = 3
            end

            for k = 1, numGames do
                if(weekNum > #self.schedule) then
                    weekNum = 1
                end

                while(checkIfTeamPlays(self.schedule[weekNum], team1.name) or checkIfTeamPlays(self.schedule[weekNum], team2.name)) do
                    weekNum = weekNum + 1

                    if(weekNum > #self.schedule) then
                        weekNum = 1
                    end
                end
                
                if(k % 2 == 0) then
                    table.insert(self.schedule[weekNum], {away=team1.name, home=team2.name})
                else
                    table.insert(self.schedule[weekNum], {away=team2.name, home=team1.name})
                end
                
                weekNum = weekNum + 1
            end
        end
    end

    self:shuffleGames()
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

return league