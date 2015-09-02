local soundEngine = require("core.sound-engine")


-- @class Scenery main class
local scenery = {
	-- Methods:
	-----------
	-- eventCollideSpike()
	-- eventCollideWall()
    -- playrCollideWall()
    -- createPhysicsShape()
}


-- Aliases:
local play = realPlayer


function scenery.eventCollideSpike(self, event)
    local spike  = self
    local object = event.other.object

    if event.phase == "began" and object ~= nil and object.isPlayer and object.shielded ~= true then
        play(sounds.playerDeathSpikes)
        object:explode(self, "Death EXPLODE SMALL")

        if object.main then hud:displayMessageDied("spike") end
    end
end


function scenery.eventCollideWall(self, event)
    local wall   = self.object
    local object = event.other.object

    if object then
        if event.phase == "began" then
            if object.isPlayer then
                wall:playerCollideWall(object)

            elseif object.isRing == false and wall.image.bodyType == "dynamic" then
                playInternal(sounds.landLedge)
            end

        elseif event.phase == "ended" and object.isPlayer then
            -- only activate the fall after the collision ends: so if they sit on a wall it doesnt trigger
            after(500, function()
                if object.mode == playerMissedDeath or object.mode == playerJump or object.mode == playerFall then
                    object:animate("Death JUMP HIGH")
                end
            end)
        end
    end
end


-- Complex logic for handling differnt player collisions with a wall
-- @param player
----
function scenery:playerCollideWall(player)
    soundEngine:playLandEdge(player.model)

    player:destroyEmitter()
    player:emit("landing-whitegood", {ypos=player:y()-50, alpha=0.75})
    player:animate("Landing FAR EDGE")
    player.image.gravityScale = 1

    -- put a check in place that if we bounce off the same self 3 or more times we kill the player to avoid bouncing forever
    player.repeatWallCollision = player.repeatWallCollision or 0

    if player.lastWallCollision == self.key then
        player.repeatWallCollision = player.repeatWallCollision + 1
    else
        player.repeatWallCollision = 0
    end

    if player.repeatWallCollision >= 3 then
        return player:explode(self)
    end

    -- put a check in place that if after hitting a self 1500ms after if player is still in fall state then kill them or they can get stuck
    player.lastWallCollision = self.key

    after(1500, function()
        local xvel, yvel = player:getForce()
        if xvel == 0 and yvel == 0  and player.lastWallCollision == self.key and (player.mode == playerMissedDeath or player.mode == playerFall) then
            player.lastWallCollision = nil
            player:explode(self)
        end
    end)

    if player.mode == playerWalk or player.mode == playerRun then
        player.mode = playerReady
    end
end


-- Creates the physics shape for blocking and deadly scenery
-- @param scale
-- @return physics stats
----
--[[
function scenery:createPhysicsShape(scale)
    local stats = {density=1, friction=0, bounce=0}
    local size  = self.size or 1  -- only use scale passed in for hard figures as image size already scaled by this number
    local p     = self.physics

    if p then
        if p.density  then stats.density  = p.density end
        if p.friction then stats.friction = p.friction end
        if p.bounce   then stats.bounce   = p.bounce end

        if p.shape == "circle" then
            local width  = self.preScaleWidth or self:width()
            stats.radius = (width/2) * scale

        elseif p.shape then
            stats.shape = {}
            for i=1, #p.shape do
                stats.shape[i] = p.shape[i] * scale
            end

        elseif p.shapeOffset then
            local offset = p.shapeOffset
            local w      = (self:width()/2)
            local h      = (self:height()/2)
            local top    = (offset.top    or 0) * scale
            local bot    = (offset.bottom or 0) * scale
            local left   = (offset.left   or 0) * scale
            local right  = (offset.right  or 0) * scale

            stats.shape = {-w+left,-h+top, w+right,-h+top, w+right,h+bot, -w+left,h+bot}
        end
    else
        local w, h  = (self:width()/2), (self:height()/2)
        stats.shape = {-w,-h, w,-h, w,h, -w,h}
    end

    return stats
end
]]


function scenery:createPhysicsShape(scale)
    local stats = {density=1, friction=0, bounce=0}
    local size  = self.size or 1  -- only use scale passed in for hard figures as image size already scaled by this number
    local p     = self.physics

    if p then
        if p.density  then stats.density  = p.density end
        if p.friction then stats.friction = p.friction end
        if p.bounce   then stats.bounce   = p.bounce end

        if p.shape == "circle" then
            local width  = self.preScaleWidth or self:width()
            stats.radius = (width/2) * size * scale

        elseif p.shape then
            stats.shape = {}
            for i=1, #p.shape do
                stats.shape[i] = p.shape[i] * size * scale
            end

        elseif p.shapeOffset then
            local offset = p.shapeOffset
            local w      = (self:width()/2)     * size
            local h      = (self:height()/2)    * size
            local top    = (offset.top    or 0) * scale
            local bot    = (offset.bottom or 0) * scale
            local left   = (offset.left   or 0) * scale
            local right  = (offset.right  or 0) * scale

            stats.shape = {-w+left,-h+top, w+right,-h+top, w+right,h+bot, -w+left,h+bot}
        end
    else
        local w, h  = (self:width()/2) * size, (self:height()/2) * size
        stats.shape = {-w,-h, w,-h, w,h, -w,h}
    end

    return stats
end


return scenery