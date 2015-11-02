local storyboard  = require("storyboard")
local anim        = require("core.animations")
local scene       = storyboard.newScene()

-- Aliases:
local play = globalSoundPlayer


local function moveZones(event)
    if event.phase == "began" then
        scene.startY = scene.moveable.y
    elseif event.phase == "moved" and event.yStart and scene.startY then
        local y = (event.y - event.yStart) + scene.startY
        
        if y < 0 and y > -1100 then
            scene.moveable.y = y
        end
    end
end


-- Called when the scene's view does not exist:
function scene:createScene(event)
    local gameType  = state.data.gameSelected
    self.planet     = state.data.planetSelected

    package.loaded["levels.planet"..self.planet..".planet"] = nil

    self.planetData = require("levels.planet"..self.planet..".planet")
    self.gameData   = gameTypeData[gameType]
    self.planetInfo = planetData[self.planet]
    self.zones      = {}
    self.moveable   = display.newGroup()
    
    local group     = self.moveable
    local bgr       = display.newImage(self.view, "images/select-zone-simple/planet-bgr1.png", centerX, centerY)

    newGameBanner(gameType, group, 480, 60)
    newButton(group, 55, 50, "back", scene.exitToPlanetSelect)

    self:createLeaderboard(group)
    self:createZones(group)
    self.view:insert(group)

    local border  = display.newImage(self.view, "images/sat-nav-border.png", centerX, centerY)
    local planet  = newText(self.view, "planet: "..self.planetInfo.name, 480, 590, 0.7, self.planetInfo.color, "CENTER")
    local rectTop = display.newRect(self.view, centerX, -50, 960, 100)
    local rectBot = display.newRect(self.view, centerX, 690, 960, 100)
    rectTop:setFillColor(0,0,0)
    rectBot:setFillColor(0,0,0)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    state:newScene("select-space-race")
    globalSceneTransitionGroup:removeSelf()
    globalSceneTransitionGroup = display.newGroup()
end


function scene:createLeaderboard(group)
    local b1 = display.newImage(group, "images/select-zone-simple/chequaboard.jpg", 187, 250)
    local b2 = display.newImage(group, "images/select-zone-simple/chequaboard.jpg", 562, 250)
    local b3 = display.newImage(group, "images/select-zone-simple/chequaboard.jpg", 937, 250)
    b1.alpha, b2.alpha, b3.alpha = 0.3, 0.3, 0.3

    local grad = display.newRect(group, centerX, 150, 960,30)
    grad:setFillColor(0,0,0, 1)

    newText(group, "pos",         170, 150, 0.4, "white", "LEFT")
    newText(group, "racer",       230, 150, 0.4, "white", "LEFT")
    newText(group, "points",      450, 150, 0.4, "white", "LEFT")
    newText(group, "wins",        545, 150, 0.4, "white", "LEFT")
    newText(group, "losses",      640, 150, 0.4, "white", "LEFT")
    newText(group, "cheats",      735, 150, 0.4, "white", "LEFT")

    -- load player rankings from each zones results and planet racer list
    local rankings, numRacers = self:calculateRankings()
    local sortOrder = self:calculateRankingOrder(rankings, numRacers)
    local ypos = 190

    for pos=1,#sortOrder do
        local racer = sortOrder[pos]
        local stats = rankings[racer]
        local info  = characterData[racer]
        local color = info.color

        local grad = display.newRect(group, centerX, ypos, 960, 50)
        if pos%2 == 0 then grad:setFillColor(0,0,0, 0.6) else grad:setFillColor(0,0,0, 0.45) end

        local face = display.newImage(group, "images/select-zone-simple/player-head-"..info.name..".png", 230, ypos)
        face:scale(0.8, 0.8)

        newText(group, pos..".",     170, ypos, 0.4, color, "LEFT")
        newText(group, info.name,    290, ypos, 0.4, color, "LEFT")
        newText(group, stats.points, 450, ypos, 0.4, color, "LEFT")
        newText(group, stats.wins,   545, ypos, 0.4, color, "LEFT")
        newText(group, stats.losses, 640, ypos, 0.4, color, "LEFT")
        newText(group, stats.cheats, 735, ypos, 0.4, color, "LEFT")
        ypos = ypos + 50
    end

    state.racePositions = sortOrder

    local drag = display.newRect(group, 0,120, 960,250)
    drag.alpha = 0.01
    drag:addEventListener("touch", moveZones)
end


function scene:calculateRankings()
    local points    = {3,1,0}
    local racers    = self.planetData.spaceRace
    local numRacers = 0
    local rankings  = {
        [racers.playerModel] = {points=0, wins=0, losses=0, cheats=0}
    }

    for _,data in pairs(racers.ai) do
        if data.inSpaceRace then
            rankings[data.model] = {points=0, wins=0, losses=0, cheats=0}
            numRacers = numRacers + 1
        end
    end

    for number=1, #self.planetData.zones do
        local state = state:zoneState(number)
print("***BYPASSING ZONE PLAYABLE CHECK")        
        --if state.playable then
            -- for race mode, the competedAs is currently used to mark each rank, in order of the winner
            local positions = state.completedAs
            if positions then
                local num = 0
                for _,_ in pairs(positions) do num=num+1 end

                for pos,racer in pairs(positions) do
                    if pos and racer then
                        rankings[racer].points = rankings[racer].points + points[pos]

                        if pos == 1 then 
                            rankings[racer].wins = rankings[racer].wins + 1
                        elseif pos == num then 
                            rankings[racer].losses = rankings[racer].losses + 1
                        end
                    end
                end
            end
        --end
    end

    return rankings, numRacers
end


function scene:calculateRankingOrder(rankings, numRacers)
    local sorted = {}

    for i=1, numRacers do
        local highest = {model=nil, points=-999}

        for key,stats in pairs(rankings) do
            local curPoints = stats.points  -- stats.losses
            if not stats.assigned and curPoints > highest.points then
                highest.model  = key
                highest.points = curPoints
            end
        end

        sorted[i] = highest.model
        rankings[highest.model].assigned = true
    end

    return sorted
end


function scene:createZones(group)
    local gameTypeId = gameTypeData[state.data.gameSelected].id
    local xpos, ypos = 140, 370
    local loop = 1

    for number=1, #self.planetData.zones do
        local zoneContents = require("levels.planet"..self.planet..".zone"..number)

        local data = {
            id      = number,
            summary = self.planetData.zones[number],
            state   = state:zoneState(number),
            name    = zoneContents.name,
            color   = "red",
        }

        package.loaded["levels.planet"..self.planet..".zone"..number] = nil

        -- check if this zone is marked as not playable for the current game mode, in the planet.lua summary
        if data.summary[gameTypeId] ~= "no" then
            if data.state.completed then data.color = "green" end

            local zone = display.newGroup()
            zone.x, zone.y = xpos, ypos

            local bgr   = display.newImage(zone, "images/select-zone-simple/zone-square-"..data.color..".png", 0, 0)
            local title = newText(zone, number, -45, -20, 0.45, "white", "LEFT")

            bgr:scale(1, 0.5)

            if scene:createZoneStatus(data, zone, xpos, ypos) then
                local callback = function() scene:selectZone(number, zone) end
                bgr:addEventListener("tap",   callback)
                title:addEventListener("tap", callback)
            end

            bgr:addEventListener("touch", moveZones)
            
            self.zones[#self.zones+1] = zone
            group:insert(zone)

            if loop%7 == 0 then
                xpos = 140
                ypos = ypos + 100
            else
                xpos = xpos + 115
            end
            loop = loop + 1
        end
    end
end


function scene:createZoneStatus(data, zone, xpos, ypos)
    local canPlay = true

    if data.state.completedAs then
        for pos,model in pairs(data.state.completedAs) do
            if model then
                local head = display.newImage(zone, "images/select-zone-simple/player-head-"..characterData[model].name..".png", -10, 0) 

                if pos == 1 then
                    head.x, head.y = head.x+30, head.y+40
                    head:scale(0.9, 0.9)
                elseif pos == 2 then
                    head.x, head.y = head.x, head.y+70
                    head:scale(0.55, 0.55)
                elseif pos == 3 then
                    head.x, head.y = head.x+60, head.y+70
                    head:scale(0.55, 0.55)
                end
            end
        end
    else--if data.state.playable then
print("***BYPASSING ZONE PLAYABLE CHECK") 
        -- tell player they have not completed it yet
        newText(zone, "?", -10, 0, 0.6, "aqua", "LEFT")
    --[[else
        -- tell player it is locked
        local lock = display.newImage(zone, "images/locking/lock.png", xpos, ypos+10)
        lock:scale(0.4, 0.4)
        canPlay = false]]
    end

    return canPlay
end


function scene:selectZone(zoneNumber, option)
    play(sounds.sceneEnter)

    state.data.zoneSelected = zoneNumber

    local seq = anim:oustSeq("menuActivate", option)
    seq:tran({time=500, scale=1.3})
    seq:tran({time=500, scale=0.01})
    seq.onComplete = function()
        storyboard:gotoScene("scenes.play-zone")
    end
    seq:start()
    loadSceneTransition()
end


function scene:exitToPlanetSelect()
    play(sounds.sceneEnter)
    after(1000, function() storyboard:gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    anim:destroy()
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    storyboard.purgeScene("scenes.select-space-race")
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    local group = self.view
end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local overlay_name = event.sceneName  -- name of the overlay scene
end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local overlay_name = event.sceneName  -- name of the overlay scene
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "didExitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "overlayBegan", scene )
scene:addEventListener( "overlayEnded", scene )

return scene
