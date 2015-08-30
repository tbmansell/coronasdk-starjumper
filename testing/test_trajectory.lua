--- original jump curve algorithm

-- Used to plot a single point along a trajectory path
function curve:getTrajectoryPoint(startingPosition, startingVelocity, n)
    --velocity and gravity are given per second but we want time step values here
    local t = 1/display.fps  --seconds per time step at 60fps
    local stepVelocity = { x=t*startingVelocity.x, y=t*startingVelocity.y }
    local stepGravity  = { x=t*0, y=t*self.Gravity }
    return {
        -- Calc for 30fps:
        --x = startingPosition.x + n * stepVelocity.x + 0.5 * (n*n+n) * stepGravity.x,
        --y = startingPosition.y + n * stepVelocity.y + 0.5 * (n*n+n) * stepGravity.y
        -- Calc for 60fps:
        x = startingPosition.x + n * stepVelocity.x + 0.25 * (n*n+n) * stepGravity.x,
        y = startingPosition.y + n * stepVelocity.y + 0.25 * (n*n+n) * stepGravity.y
    }
end





local speed = 100
local a1, a2, t1, t2 = curve:getLaunchAngles({x=1, y=1}, {x=300, y=1}, 40, speed, true)
if a1 then
    local vx,  vy  = speed * math.cos(a1), speed * math.sin(a1)
    local vx2, vy2 = speed * math.cos(a2), speed * math.sin(a2)
    print(speed.."] angle1="..a1.." timelapse="..t1.." vx="..vx.." vy="..vy)
    print(speed.."] angle2="..a2.." timelapse="..t2.." vx="..vx2.." vy="..vy2)
end


local speed = 500
local a1, a2, t1, t2 = curve:getLaunchAngles({x=1, y=1}, {x=300, y=1}, 40, speed, true)
if a1 then
    local vx,  vy  = speed * math.cos(a1), speed * math.sin(a1)
    local vx2, vy2 = speed * math.cos(a2), speed * math.sin(a2)
    print(speed.."] angle1="..a1.." timelapse="..t1.." vx="..vx.." vy="..vy)
    print(speed.."] angle2="..a2.." timelapse="..t2.." vx="..vx2.." vy="..vy2)
end

local speed = 1000
local a1, a2, t1, t2 = curve:getLaunchAngles({x=1, y=1}, {x=300, y=1}, 40, speed, true)
if a1 then
    local vx,  vy  = speed * math.cos(a1), speed * math.sin(a1)
    local vx2, vy2 = speed * math.cos(a2), speed * math.sin(a2)
    print(speed.."] angle1="..a1.." timelapse="..t1.." vx="..vx.." vy="..vy)
    print(speed.."] angle2="..a2.." timelapse="..t2.." vx="..vx2.." vy="..vy2)
end


-- Computes the launch angles needed to hit a target along a parabolic trajectory. Cf. “Mechanics”, J.P. Den Hartog, pp. 187-9
-- @param point Launch point.
-- @param target Target point.
-- @param gravity Gravity constant.
-- @param v0 Launch speed.
-- @param get_times If true, return times after the angles.
--
-- @return If @e target can be hit, an angle that will yield a hit; otherwise, @b nil.
-- @return If @e target can be hit, another angle that will yield a hit; may be the same angle as the first.
-- @return Time lapse to hit with angle #1.
-- @return Time lapse to hit with angle #2; may differ even with same angles, i.e. when firing straight up.
--
-- Following what Matt wrote, once you’ve got your angle, you can put it together with your launch speed to get the linear velocity as
-- local vx, vy = speed * math.cos(angle), speed * math.sin(angle)
-- proj:setLinearVelocity(vx, vy)
function curve:getLaunchAngles(point, target, gravity, v0, get_times)
    assert(gravity > 0)
    assert(v0 > 0)

    --local dx, dy, y = target[1] - point[1], target[2] - point[2], target[3] - point[3]
    --local x2 = dx * dx + dy * dy
    local dx, y = target.x - point.x, target.y - point.y
    local x2    = dx * dx
    local a1, a2, t1, t2

    -- If the target is above or below, do special vertical case.
    --if x2 1, the sine argument was invalid: the shot will miss.
        -- Wikipedia offers the transformation:
        -- alpha = atan((v^2 +- sqrt(v^4 – g * (g * x^2 + 2 * y * v^2))) / (g * x))
    --else
        local sin_numer = y + gravity * x2 / (v0 * v0)
        local dist = math.sqrt(x2 + y * y)

        if sin_numer <= dist then
            local phi   = math.asin(y / dist)
            local angle = math.asin(sin_numer / dist)

            a1 = (phi + angle) / 2
            a2 = (phi - angle + math.pi) / 2

            -- Get times by solving for t: x(t) = v0 * cos(alpha) * t.
            if get_times then
                local x = math.sqrt(x2)
                t1 = x / (v0 * math.cos(a1))
                t2 = x / (v0 * math.cos(a2))
            end
        end
    --end

    -- Return desired set of results.
    if t1 then
        return a1, a2, t1, t2
    elseif a1 then
        return a1, a2
    else
        return nil
    end
end








function hud:showGearDescription(category, gear)
    --[[hud:removeDescription(category)

    local ypos, color = 50, "green"

    if category == air then 
        ypos, color = 200, "blue"
    elseif category == land then
        ypos, color = 352, "red"
    end

    local title = newText(self.gearPopup, hud.messages["gear"][category][gear][1], 516, ypos, 0.4, color,   "LEFT")
    local desc  = newText(self.gearPopup, hud.messages["gear"][category][gear][2], 520, 0,    0.4, "white", "LEFT", 800)
    local icon  = display.newImage(self.gearPopup, "images/collectables/gear-"..gearNames[category].."-"..gear..".png", 835, ypos-37)
    
    icon:scale(0.7,0.7)
    desc:setReferencePoint(display.TopLeftReferencePoint)
    desc.y = ypos + 20

    hud.descriptionTitles[category]  = title
    hud.descriptionDetails[category] = desc
    hud.descriptionIcons[category]   = icon]]
end


function hud:showNegableDescription(category, gear)
    --[[hud:removeDescription(category)

    local ypos = 50

    if category == air then 
        ypos= 200
    elseif category == land then
        ypos = 352
    end

    local title = newText(self.gearPopup, "negable - "..hud.messages["negable"][category][gear][1], 516, ypos, 0.4, "red",   "LEFT")
    local desc  = newText(self.gearPopup, hud.messages["negable"][category][gear][2], 520, 0,    0.4, "white", "LEFT", 800)
    local icon  = display.newImage(self.gearPopup, "images/collectables/negable-"..gearNames[category].."-"..gear..".png", 835, ypos-37)
    
    icon:scale(0.7,0.7)
    desc:setReferencePoint(display.TopLeftReferencePoint)
    desc.y = ypos + 20

    hud.descriptionTitles[category]  = title
    hud.descriptionDetails[category] = desc
    hud.descriptionIcons[category]   = icon]]
end


function hud:removeDescription(category)
    --[[local title = hud.descriptionTitles[category]
    local desc  = hud.descriptionDetails[category]
    local icon  = hud.descriptionIcons[category]

    if title ~= nil then
        title:removeSelf()
        hud.descriptionTitles[category] = nil
    end

    if desc ~= nil then
        desc:removeSelf()
        hud.descriptionDetails[category] = nil
    end

    if icon ~= nil then
        icon:removeSelf()
        hud.descriptionIcons[category] = nil
    end]]
end




