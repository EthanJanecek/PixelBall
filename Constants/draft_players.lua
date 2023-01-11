local PlayerLib = require("Objects.player")

draftPlayers = {}

function generateDraftPlayers()
    for i = 1, 60 do
        table.insert(draftPlayers, PlayerLib:createRookie())
    end
end