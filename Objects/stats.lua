local stats = {}

function stats:createStats()
    self.__index = self

    return setmetatable({
        points = 0,
        twoPA = 0,
        twoPM = 0,
        threePA = 0,
        threePM = 0,
        blocks = 0,
        steals = 0,
        turnovers = 0
    }, self)
end


function addStats(stats1, stats2)
    stats1.points = stats1.points + stats2.points
    stats1.twoPA = stats1.twoPA + stats2.twoPA
    stats1.twoPM = stats1.twoPM + stats2.twoPM
    stats1.threePA = stats1.threePA + stats2.threePA
    stats1.threePM = stats1.threePM + stats2.threePM
    stats1.blocks = stats1.blocks + stats2.blocks
    stats1.steals = stats1.steals + stats2.steals
    stats1.turnovers = stats1.turnovers + stats2.turnovers
end

return stats