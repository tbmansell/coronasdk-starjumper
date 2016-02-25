--local spineFactory = require("core.spine-factory")
local anim        = require("core.animations")
local particles   = require("core.particles")
local builder     = require("level-objects.builders.builder")
local spineStore  = require("level-objects.collections.spine-store")

-- The main class: just a loader class
local newObjectsLoader  = {}

-- Local vars for faster access
local dcWidth           = display.contentCenterX - display.contentWidth
local bgrWidth          = display.contentWidth
local bgrWidthHalf      = display.contentWidth / 2
local rightSwapLimit    = 4320

local backgroundImages  = {}
local lavaChase         = false
local warpChase         = false
local lava              = nil
local warp              = nil
local warpFollowers     = nil
local killedBySpecial   = false
local specialRise       = false
local skyChanging       = false
local skyBlue           = nil
local warpPullMovement1 = {pattern=moveTemplateJerky,        distance=30, isTemplate=true, speed=0.5, dontDraw=true, steering=steeringMild}
local warpPullMovement2 = {pattern=moveTemplateJerkyReverse, distance=30, isTemplate=true, speed=0.5, dontDraw=true, steering=steeringMild}


-- Aliases
local math_abs    = math.abs
local math_floor  = math.floor
local math_random = math.random


---------- PHYSICS EVENT HANDLERS ----------

local function collideLava(self, event)
    local lava   = self
    local object = event.other.object

    if object == nil then return end

    if event.phase == "began" then
        if object.image and (object.isLedge or object.isObstacle) and not (object.collideWithLava or object.isFinish or object.isSpine) then
            object.collideWithLava = true
        end
    end
end


local function collideWarp(self, event)
    local warp   = self
    local object = event.other.object

    if object == nil then return end

    if event.phase == "began" then
        if object.inGame and not object.belongsToSpineStore and not object.collideWithWarp and object.isLedge then
            if not object.isMoving then
                object.collideWithWarp = true

                if object.isLedge then
                    object.canShake = false
                end

                if math_random(100) > 50 then
                    object:moveNow(warpPullMovement1)
                else
                    object:moveNow(warpPullMovement2)
                end

                after(10000, function()
                    if object.inGame then
                        warp.object:sound("ledgeExplodingActivated", {duration=4000})
                        
                        spineStore:showExplosion(hud.camera, object)
                        object:destroy(hud.camera, true)
                    end
                end)
            end
        end
    end
end


-- Wrapper for loading new functions into level:
function newObjectsLoader:load(level)


---------- LOCAL VAR ASSIGNMENT & REMOVAL ----------


    -- Called by main setLocalAssignments() to allow this file to have its own copy of locals
    function level:setSpecialLocalAssignments()
        skyChanging     = self.skyChanging
        skyBlue         = self.skyBlue
        lavaChase       = self.data.lavaChase
        warpChase       = self.data.warpChase
        killedBySpecial = false
        specialRise     = false
    end


    function level:destroySpecial()
        if lava then
            lava:removeSelf()
        elseif warp then
            warp:destroy()
        end
        lava, warp = nil, nil
    end


---------- BACKGROUND MOVEMENT ----------


    -- Do all work to Load backgrounds in from file and set backgrounds for level
    function level:createBackgrounds(camera)
        backgroundImages = {}

        for key=bgrFront, bgrSky do
            backgroundImages[key] = {}

            if self.data.backgroundOrder[key] then
                local count = #self.data.backgroundOrder[key]
                local xpos  = -self.bgrWidth * count

                for i=1, count do
                    self:createBackgroundImage(camera, key, i, i, xpos)
                    xpos = xpos + self.bgrWidth
                    -- Fix visual tearing of sky bgr showing black background by overlapping
                    xpos = xpos - 1
                end

                for i=1, count do
                    self:createBackgroundImage(camera, key, i, i+count, xpos)
                    xpos = xpos + self.bgrWidth
                    -- Fix visual tearing of sky bgr showing black background by overlapping
                    xpos = xpos - 1
                end
            end
        end

        self:setBackgroundTint()
    end


    function level:createBackgroundImage(camera, key, sheetNum, insertOrder, xpos)
        local path   = "levels/planet"..self.planetNumber.."/images/bgr-"
        local sheet  = self.data.backgroundOrder[key][sheetNum]

        if sheet == 0 then
            backgroundImages[key][insertOrder] = 0
        else
            local img    = display.newImage(path..backgroundNames[key].."-"..sheet..".png", xpos, centerY)

            local pinTop = false
            if key == bgrSky then
                pinTop = true
                img:setFillColor(skyBlue, skyBlue, 1)
            end

            img:toBack()
            backgroundImages[key][insertOrder] = img

            if state.data.gameSettings.backgrounds then
                camera:add(img, 4+key, false, true, pinTop)
            end
        end
    end


    -- Reload backgrounds
    function level:clearBackgrounds(camera)
        for key, list in pairs(backgroundImages) do
            for i=1, #list do
                local img = backgroundImages[key][i]

                if type(img) ~= "number" then
                    camera:remove(img)
                    img:removeSelf()
                end
            end
        end
        backgroundImages = nil
    end


    -- Called from main game loop enterframe to check for background image movement
    function level:checkBackgroundMovement()
        local num = #backgroundImages

        for key=1,num do
            local list  = backgroundImages[key]
            local count = #list

            for i=1,count do
                local img = list[i]

                if type(img) ~= "number" then

                    local leftSwapLimit  = dcWidth * (count - 1)

                    if img.x + bgrWidthHalf < leftSwapLimit then
                        local prev = i - 1
                        if prev == 0 then prev = #list end

                        local follow = list[prev]
                        img.x = follow.x + follow.width - 1

                    elseif img.x + bgrWidth + bgrWidthHalf > rightSwapLimit then
                        local prev = i + 1
                        if prev > count then prev = 1 end

                        local follow = list[prev]
                        img.x = follow.x - follow.width + 1
                    end
                end
            end
        end
    end


    -- Randomizes colors for the background images
    function level:colorBackgroundsRandom()
        local ledges = self.ledges.items
        local num    = #ledges
        
        for i=1,num do
            local ledge = ledges[i]
            if ledge and ledge.image then
                randomizeImage(ledge.image, true, 0.3)
            end
        end
        
        for key,list in pairs(backgroundImages) do
            local r,g,b = math_random(), math_random(), math_random(), math_random()
            for i=1,#list do
                local img = backgroundImages[key][i]

                if type(img) ~= "number" then
                    img:setFillColor(r,g,b)
                end
            end
        end
    end


    -- Restores the colour of the background images
    function level:colorBackgroundsRestore()
        local ledges = self.ledges.items
        local num    = #ledges
        
        for i=1,num do
            local ledge = ledges[i]
            if ledge and ledge.image then
                restoreImage(ledge.image)
            end
        end

        -- Restore backgrounds
        for key,list in pairs(backgroundImages) do
            for i=1,#list do
                local img = backgroundImages[key][i]

                if type(img) ~= "number" then
                    img:setFillColor(1,1,1)
                end
            end
        end
    end


    -- Checks if sky bgr should turn darker or lighter
    function level:checkDaytimeChanging()
        if skyChanging == skyChangingNight then
            skyBlue = skyBlue - 0.01
            level:setBackgroundTint()

            if skyBlue <= 0 then
                if self.data.turnDay then
                    skyChanging = skyChangingDay
                else 
                    skyChanging = nil 
                end
            end
        elseif skyChanging == skyChangingDay then
            skyBlue = skyBlue + 0.005
            level:setBackgroundTint()

            if skyBlue >= 1 then 
                if self.data.turnNight then 
                    skyChanging = skyChangingNight 
                else 
                    skyChanging = nil 
                end
            end
        end
    end


    function level:setBackgroundTint()
        local list = backgroundImages[bgrSky]
        for i=1, #list do
            list[i]:setFillColor(skyBlue, skyBlue, 1)
        end
    end


---------- SPECIAL CHASE CONTROL ----------

    function level:stopSpecialFeatures()
        specialRise = false
    end

---------- LAVA CHASE ----------


    -- creates lava at the bottom of the level that chases you up and kills the player
    -- game ends if lava reaches the ledge a player is on before he jumps
    function level:createLavaChase(camera)
        lavaChase = true

        lava = display.newRect(centerX, 820, 1200, 640)
        lava:setFillColor(1,0.5,0)
        lava.alpha     = 0.5
        lava.direction = left
        lava.rotation  = 0

        physics.addBody(lava, "dynamic", {isSensor=true, shape={-500,-640, 500,-640, 500,-320, -500,-320}})
        
        lava.gravityScale = 0
        lava.particles    = particles:showEmitter(nil, "lava-bubbles", lava.x, lava.y - (lava.height/2) + 150, "forever", 0.8, 2)
        lava.collision    = collideLava
        lava:addEventListener("collision", lava)

        -- fix X axis so we dont have to create a large image
        camera:add(lava, 2, false, false, false, true)
        camera:add(lava.particles, 2, false, false, false, true)

        after(10000, function() specialRise = true end)
    end


    function level:scaleLavaChase(scalePosition)
        lava.y = lava.y * scalePosition

        -- Just scaling as above doesnt position correctly: making these adjustments keeps it in the same position
        if scalePosition < 1 then
            lava.y = lava.y + 120
        else
            lava.y = lava.y - 200
        end
    end


    function level:checkLavaChase(delta, player)
        local lavaTop = lava.y - 320
        local playerY = player:y()

        -- Do bobbing action
        if lava.direction == left then
            lava.rotation = lava.rotation + 0.025
            if lava.rotation > 1 then lava.direction = right end
        else
            lava.rotation = lava.rotation - 0.025
            if lava.rotation < -1 then lava.direction = left end
        end

        -- Check if line has exceeded player yet
        if playerY > lavaTop and player.mode ~= playerKilled and not killedBySpecial then
            killedBySpecial = true

            after(50, function()
                -- put this in to make sure lava cant kill player once they have landed on the completion ledges
                if state.data.game ~= levelOverComplete then
                    player:stopMomentum()
                    player.image.gravityScale = 0
                    -- end level if lava has reached player start ledge
                    local lavaTop = lava.y - 340

                    -- If lava has reached their start ledge, end the level
                    if player.startLedge and player.startLedge:topEdge() > lavaTop then
                        specialRise  = false
                        player.lives = 0
                    end

                    player:explode(nil, {action="playerDeathLava"})

                    -- wait until after they have reset, before allowing them to be killed again
                    after(3500, function()
                        if player.lives >= 0 then 
                            killedBySpecial = false
                        end
                    end)
                end
            end)
        elseif playerY > lavaTop then
            -- ensure player cant roll passed the lava if already dead (e.g. from collapsing ledge)
            after(50, function() player:stopMomentum() end)
        end

        -- Check if should rise
        if specialRise then
            lava.y = lava.y - 0.5
            lava.particles.y = lava.particles.y - 0.5
        end
    end


---------- WARP FIELD CHASE ----------


    -- creates lava at the bottom of the level that chases you up and kills the player
    -- game ends if lava reaches the ledge a player is on before he jumps
    function level:createWarpChase(camera)
        warpChase = true
        warp      = self:createWarpField(camera, 800)

        physics.addBody(warp.image, "dynamic", {isSensor=true, shape={-500,-640, 550,-640, 550,-200, -500,-200}})
        warp:moveTo(centerX-50, 800)
        warp.image.gravityScale = 0
        warp.particles          = particles:showEmitter(nil, "warp-field-sparks", warp:x(), 600, "forever", 0.8, 1)
        warp.image.collision    = collideWarp
        warp.image:addEventListener("collision", warp.image)

        camera:add(warp.particles, 1, false, false, false, true)

        warpFollowers = {}
        warpFollowers[#warpFollowers+1] = self:createWarpField(camera, 950)
        warpFollowers[#warpFollowers+1] = self:createWarpField(camera, 1100)

        after(10000, function() specialRise = true end)
    end


    function level:createWarpField(camera, ypos)
        local warp = builder:newSpineObject({type="warpfield"}, {jsonName="space/warpfield", imagePath="effects/warpfield", scale=1, animation="Standard"})

        warp.alwaysAnimate = true
        warp:moveTo(centerX-50, ypos)
        warp.key = "warpfield"

        self.spines:add(warp)
        camera:add(warp.image, 1, false, false, false, true)

        return warp
    end


    function level:scaleWarpChase(scalePosition)
        self:scaleWarpImage(warp, scalePosition)

        for i=1, #warpFollowers do
            self:scaleWarpImage(warpFollowers[i], scalePosition)
        end
    end


    function level:scaleWarpImage(item, scalePosition)
        item.image.y = item.image.y * scalePosition

        -- Just scaling as above doesnt position correctly: making these adjustments keeps it in the same position
        if scalePosition < 1 then
            item.image.y = item.image.y + 120
        else
            item.image.y = item.image.y - 200
        end
    end


    function level:checkWarpChase(delta, player)
        local warpTop = warp:topEdge(-100)
        local playerY = player:y()

        -- Check if line has exceeded player yet
        if playerY > warpTop and player.mode ~= playerKilled and not killedBySpecial then
            killedBySpecial = true
            
            after(50, function()
                -- put this in to make sure warp cant kill player once they have landed on the completion ledges
                if state.data.game ~= levelOverComplete then
                    player:stopMomentum()
                    player.image.gravityScale = 0
                    -- end level if warp has reached player start ledge
                    if player.startLedge and player.startLedge ~= -1 and player.startLedge.inGame and player.startLedge:topEdge() > warpTop then
                        specialRise  = false
                        player.lives = 0
                    end

                    player:explode(nil, "ledgeExplodingActivated")

                    -- wait until after they have reset, before allowing them to be killed again
                    after(3500, function()
                        if player.lives >= 0 then 
                            killedBySpecial = false
                        end
                    end)
                end
            end)
        elseif playerY > warpTop then
            -- ensure player cant roll passed the warp if already dead (e.g. from collapsing ledge)
            after(50, function() player:stopMomentum() end)
        end

        -- Check if should rise
        if specialRise then
            warp:moveBy(0, -0.6)
            warp.particles.y = warp.particles.y - 0.6

            for i=1,#warpFollowers do
                warpFollowers[i]:moveBy(0, -0.6)
            end
        end
    end


---------- HANDLE CUSTOM EVENTS ----------

    -- Called when the level starts to run through any timed custom events and trigger them
    function level:startCustomEvents()
        if self.data.customEvents then
            for name,event in pairs(self.data.customEvents) do
                if event.conditions and event.conditions.zoneStart then
                    self:triggerCustomEvent(name, hud.player, self:getLedge(1))
                end
            end
        end
    end


    -- Called when the level starts to run through any timed custom events and trigger them
    function level:finishCustomEvents()
        if self.data.customEvents then
            for name,event in pairs(self.data.customEvents) do
                if event.conditions and event.conditions.zoneFinish then
                    self:triggerCustomEvent(name, hud.player, self:getLastLedge())
                end
            end
        end
    end


    -- Makes a check to see if the custom event name should be run and if so runs it
    function level:triggerCustomEvent(eventName, player, source)
        if self.data.customEvents then
            local event = self.data.customEvents[eventName]
            if event then
                -- check conditions:
                if self:eventConditionsMet(event, player) then
                    -- check if already been run
                    if not event.hasRun then
                        after(event.delay, function()
                            if event.freezePlayer then
                                state.data.game = levelRunScript
                                hud:scriptMode(true)
                            end

                            event.action(hud.camera, player, source)
                            event.hasRun = true
                        end)
                    end
                end
            end
        end
    end


    function level:eventConditionsMet(event, player)
        if event.conditions then
            for name,condition in pairs(event.conditions) do
                if name == "keys" then
                    for _,color in pairs(condition) do
                        if not player:hasUnlocked(color) then
                            return false
                        end
                    end
                elseif name == "zoneFinish" then
                    local mode = state.data.game

                    if mode == levelOverFailed or mode == levelOverComplete then
                        return false
                    end
                elseif name == "player" then
                    if condition == "main" then
                        if not player.main then
                            return false
                        end
                    elseif condition ~= player.model then
                        return false
                    end
                end
            end
        end
        -- return true by default
        return true
    end


    function level:getTarget(type, name)
        if     type == "scenery"     then return self.scenery:getTargetName(name)
        elseif type == "collectable" then return self.collectables:getTargetName(name)
        elseif type == "ledge"       then return self.ledges:getTargetName(name)
        elseif type == "player"      then return self.players:getTargetName(name)
        elseif type == "enemy"       then return self.enemies:getTargetName(name)
        else   return {} end
    end

end


return newObjectsLoader