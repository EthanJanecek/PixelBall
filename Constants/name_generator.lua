firstNames = {}
lastNames = {}

function generateName()
    local firstNum = math.random(1, 1000)
    local lastNum = math.random(1, 1000)

    return firstNames[firstNum] .. " " .. lastNames[lastNum]
end

function loadNames()
    local path = system.pathForFile( "data/names_first.csv", system.ResourceDirectory )
    for line in io.lines(path) do
        table.insert(firstNames, line)
    end

    path = system.pathForFile( "data/names_last.csv", system.ResourceDirectory )
    for line in io.lines(path) do
        table.insert(lastNames, line)
    end
end