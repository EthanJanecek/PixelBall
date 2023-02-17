local awards = {}

function awards:createAwards()
    self.__index = self

    return setmetatable({
        mvp=0,
        roty=0,
        smoty=0,
        dpoty=0,
        fmvp=0,
        rings=0
    }, self)
end

return awards