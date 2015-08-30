--[[
Project: Perspective
Author: Caleb P
Version: 1.4.2

A library for easily and smoothly integrating a virtual camera into your game.

Changes for v1.4.2
	Fixes/Updates -
		- Fixed a problem with damping and parallax
		- Added "setParallax" function
		- Converted damping algorithm from division to multiplication
		- Moved all the view's "special" values to a single table
	Notes - 
		- I converted the damping algorithm from division to multiplication because multiplication is faster. The new approach is entirely internal; you don't need to change anything.
		- Please do not edit the values inside the camera's "CONF" table, on pain of possible unexpected results!
--]]

-- These are static and should not be changed
local XAxisLimit = 250
local YAxisLimit = 50
-- These are flexible and change to keep the user in the screen
local leftRightLimit = XAxisLimit
local upDownLimit    = YAxisLimit

local leftBoundary=nil
local rightBoundary=nil
local bottomBoundary=nil
local topBoundary=nil
local bound1=nil
local bound2=nil

local abs	= math.abs
local inf	= math.huge
local ng	= display.newGroup
local ccx	= display.contentCenterX - leftRightLimit   -- Assume left start
local ccy	= display.contentCenterY + upDownLimit
local cw	= display.contentWidth
local ch	= display.contentHeight
local drm	= display.remove


--[[local camlab1=display.newText("", 230, 130)
local camlab2=display.newText("", 130, 150)
local camlab3=display.newText("", 195, 170)
local camlab4=display.newText("", 220, 190)
local camlab5=display.newText("", 240, 210)]]


local Perspective={
	version="1.4.2",
	author="Caleb P - Gymbyl Coding"
}

function Perspective.createView(numLayers)
	bound1 = nil
	bound2 = nil

	--Localize variables
	local applyConstraints = true
	local applyBounds      = true
	local limitXaxis       = false
	local limitYaxis       = false
	local counter          = 0
	--Check for manual layer count
	local numLayers=(type(numLayers)=="number" and numLayers) or 8
	--Variables
	local isTracking=false -- Local so that you can't change it and mess up the view's inner workings
	local layer={}

	--Create the camera view
	local view = display.newGroup()

	-- public view properties that can be played with
	view.damping       = 10
	view.scaling       = false
	view.scaleMode     = false
	view.scaleImage    = 1
	view.scalePosition = 1
	view.scaleVelocity = 1

	view.CONF = {
		x1 = 0,
		x2 = cw,
		y1 = 0,
		y2 = ch,
		prevDamping = 10,
		damping = 0.1
	}

	--Create the layers
	for i=numLayers, 1, -1 do
		layer[i]=ng()
		layer[i].parallaxRatio=1 -- Parallax
		layer[i]._isPerspectiveLayer=true -- Just a flag for future updates, not sure what I'm going to do with it
		view:insert(layer[i])
	end

	
	--Function to add objects to camera
	function view:add(obj, l, isFocus, constrainBottom, constrainTop, fixXAxis)
		local isFocus = isFocus or false
		local l = l or 4

		obj.layer           = l
        obj.constrainBottom = constrainBottom or false
        obj.constrainTop    = constrainTop or false
        obj.fixXAxis        = fixXAxis or false
		
		layer[l]:insert(obj)

        if constrainBottom then
            obj.limitBottom = math.abs(obj.y)
        end

        if constrainTop then
            obj.limitTop = obj.y
        end

		if isFocus==true then
			view:setFocus(obj)
		end

		-- This is for objects that area created when game scaled out, so they are resized back in correctly
	    if self.scaleMode then
	        obj.scaleFactor = 1/self.scaleImage
	    end
		
		--Moves an object to a layer
		function obj:toLayer(newLayer)
			if layer[newLayer] then
				layer[newLayer]:insert(obj)
				obj._perspectiveLayer=newLayer
			end
		end
		
		--Moves an object back a layer
		function obj:back()
			if layer[obj._perspectiveLayer+1] then
				layer[obj._perspectiveLayer+1]:insert(obj)
				obj._perspectiveLayer=obj.layer+1
			end
		end
			
		--Moves an object forwards a layer
		function obj:forward()
			if layer[obj._perspectiveLayer-1] then
				layer[obj._perspectiveLayer-1]:insert(obj)
				obj._perspectiveLayer=obj.layer-1
			end
		end
		
		--Moves an object to the very front of the camera
		function obj:toCameraFront()
			layer[1]:insert(obj)
			obj._perspectiveLayer=1
			obj:toFront()
		end

		--Moves an object to the very back of the camera
		function obj:toCameraBack()
			layer[numLayers]:insert(obj)
			obj._perspectiveLayer=numLayers
			obj:toBack()
		end
	end


	--View's tracking function
	function view.trackFocus()
		local conf      = view.CONF
		local confFocus = conf.focus

		if confFocus then
			local forcing = false

			if applyBounds then
				limitXaxis, limitYaxis = view:hitBounds()
				counter = counter + 1

				if limitXaxis or limitYaxis then
					forcing = view:forceWithinBoundaries()
				elseif counter >= 100 then
					view:forceGridSize()
				end

				--[[if limitXaxis and limitYaxis and not forcing then
					return
				end]]
			end

			if forcing then
				view.trackFocusForcing(conf, confFocus)
			else
				view.trackFocusNormal(conf, confFocus)
			end
		end
	end


	function view.trackFocusForcing(conf, confFocus)
		local focusX, focusY = nil, nil
		local confX, confY   = -confFocus.x + ccx, -confFocus.y + ccy

--		print("trackFocusForcing confY="..confY)

        for i=1,numLayers do
            local g = layer[i]
            local parallaxRatio = g.parallaxRatio
            local gx, gy, gnum  = g.x, g.y, g.numChildren

            for x=1,gnum do
                local item  = g[x]
            	local xdiff = (gx - (gx - confX * parallaxRatio))
        		local ydiff = (gy - (gy - confY * parallaxRatio))
        		local newx  = item.x + xdiff
        		local newy  = item.y + ydiff

                --if item.isFocus then focusX = newx else	item.x = newx end
                --if item.isFocus then focusY = newy else	item.y = newy end
                if item.fixXAxis ~= true then 
                	item.x = newx
                end
                
                item.y = newy

                -- some items are constrained to an edge so you cant see past that edge (eg background images)
                if applyConstraints then
                    if item.constrainBottom and newy < item.limitBottom then
                        newy = item.limitBottom
                    end

                    if item.constrainTop and newy > item.limitTop then
                        newy = item.limitTop
                    end
                end
            end
		end
	end


	function view.trackFocusNormal(conf, confFocus)
		local damping = view.damping
		if conf.prevDamping ~= damping then
			conf.prevDamping = damping
			conf.damping = 1 / damping -- Set up multiplication damping
		end
		damping = conf.damping

		local focusX, focusY = nil, nil
		local confX, confY   = -confFocus.x + ccx, -confFocus.y + ccy

        for i=1,numLayers do
            local g = layer[i]
            local parallaxRatio = g.parallaxRatio
            local gx, gy, gnum  = g.x, g.y, g.numChildren

            for x=1,gnum do
                local item = g[x]

            	if not limitXaxis then
            		if item.fixXAxis ~= true then
	            		local xdiff = (gx - (gx - confX * parallaxRatio) * damping)
	            		local newx  = item.x + xdiff
	            		-- dont move focused object now, only at end
	            		if item.isFocus then focusX = newx else	item.x = newx end
	            	end
            	end

            	if not limitYaxis then
            		local ydiff = (gy - (gy - confY * parallaxRatio) * damping)
                    local newy = item.y + ydiff

                    -- some items are constrained to an edge so youcant see past that edge (eg background images)
                    if applyConstraints then
                        if item.constrainBottom and newy < item.limitBottom then
                            newy = item.limitBottom
                        end

                        if item.constrainTop and newy > item.limitTop then
                            newy = item.limitTop
                        end
                    end
                    -- dont move focused object now, only at end
                    if item.isFocus then focusY = newy else	item.y = newy end
                end
            end
		end

		-- move player after everything else otherwise shit gets screwed up
		if focusX then confFocus.x = focusX end
		if focusY then confFocus.y = focusY end
	end
	

	--Start tracking
	function view:track()
		if not isTracking then
			isTracking = true
			Runtime:addEventListener("enterFrame", view.trackFocus)
		end
		--[[camlab1:toFront()
		camlab2:toFront()
		camlab3:toFront()
		camlab4:toFront()
		camlab5:toFront()]]
	end
	

	--Stop tracking
	function view:cancel()
		if isTracking then
			Runtime:removeEventListener("enterFrame", view.trackFocus)
			isTracking = false
		end
    end


    -- Check if tracking on or off
    function view:on()
        return isTracking
    end


    function view:setConstraints(value)
        applyConstraints = value
        if value == false then
			limitXaxis = false
			limitYaxis = false
		end
    end
	

	--Set bounding box dimensions
	function view:setBounds(x1, x2, y1, y2)
		applyBounds    = true
		leftBoundary   = x1
		rightBoundary  = x2
		bottomBoundary = y1
		topBoundary    = y2

		-- Setup the bounding objects
		bound1 = display.newCircle(leftBoundary,  bottomBoundary, 55)
		bound2 = display.newCircle(rightBoundary, topBoundary,    55)
		--bound1.alpha, bound2.alpha = 0, 0
		bound1.alpha, bound2.alpha = 0.5, 0.5

		bound1:setFillColor(1,0,0)
		bound2:setFillColor(1,0,0)
		
		layer[2]:insert(1, bound1)
		layer[2]:insert(2, bound2)
		-- NOTE: in layer1 these work better when scaled out - but they need to be in layer 2 or they are unreliably positioned
	end

	function view:increaseLeftBoundary(to)
		if bound1 and to < bound1.x then
			bound1.x = to
		end
	end

	function view:increaseRightBoundary(to)
		if bound2 and to > bound2.x then
			bound2.x = to
		end
	end

	function view:increaseTopBoundary(to)
		if bound2 and to < bound2.y then
			bound2.y = to
		end
	end

	function view:increaseBottomBoundary(to)
		if bound1 and to > bound1.y then
			bound1.y = to
		end
	end


	function view:applyBounds(on)
		applyBounds = on
	end


	function view:outsideBounds(item)
		local x, y = item.x, item.y
		local width, height = item.width/2, item.height/2

		return x+width < bound1.x or x-width > bound2.x or y-height > bound1.y or y+height < bound2.y
	end


	-- Determine if we hit X or Y boundary and should not adjust that axis any further
	function view:hitBounds()
		local g 	 = layer[1]
		local xdiff  = (g.x - (g.x - (-view.CONF.focus.x + ccx) * g.parallaxRatio) * view.CONF.damping)
		local ydiff  = (g.y - (g.y - (-view.CONF.focus.y + ccy) * g.parallaxRatio) * view.CONF.damping)

		--[[local mr = math.round
		local b1, b2, b3, b4 = bound1.x, bound1.y, bound1.x+xdiff, bound1.y+ydiff
		local b5, b6, b7, b8 = bound2.x, bound2.y, bound2.x+xdiff, bound2.y+ydiff
		camlab1.text = "level bounds (x,x,y,y): "..leftBoundary..", "..rightBoundary..", "..bottomBoundary..", "..topBoundary
		camlab2.text = "ccx="..mr(ccx).." ccy="..mr(ccy)
		camlab3.text = "leftRightLimit="..mr(leftRightLimit).." upDownLimit="..mr(upDownLimit)
		camlab4.text = "bound1 actual="..mr(b1)..", "..mr(b2).." moved="..mr(b3)..", "..mr(b4)
		camlab5.text = "bound2 actual="..mr(b5)..", "..mr(b6).." moved="..mr(b7)..", "..mr(b8)]]

		local hitLeft   = (bound1.x + xdiff > 0)
		local hitBottom = (bound1.y + ydiff < ch)
		local hitRight  = (bound2.x + xdiff < cw)
		local hitTop    = (bound2.y + ydiff > 0)

		--if hitLeft  or hitBottom then camlab4:setFillColor(1,0,0) else camlab4:setFillColor(1,1,1) end
		--if hitRight or hitTop    then camlab5:setFillColor(1,0,0) else camlab5:setFillColor(1,1,1) end

        return (hitLeft or hitRight), (hitBottom or hitTop)
	end


	function view:forceWithinBoundaries()
		local offsetX = XAxisLimit
		local offsetY = YAxisLimit
		local x1, y1  = bound1.x, bound1.y
		local x2, y2  = bound2.x, bound2.y
		local force   = false

		if x1 > 0 then
			force = true
			offsetX = leftRightLimit + x1
--			print("force left: "..offsetX.." leftRightLimit="..leftRightLimit.." x1="..x1)
		elseif x2 < cw then
			force = true
			offsetX = leftRightLimit - (cw - x2)
--			print("force right: "..offsetX)
		end

		if y1 < ch then
			force = true
			offsetY = upDownLimit + (ch - y1)
			--if offsetY < 80 then offsetY = 80 end
--			print("force bottom: offsetY="..offsetY.." upDownLimit="..upDownLimit.." y1="..y1)
		elseif y2 > 0 then
			force = true
			offsetY = upDownLimit - y2
--			print("force top: "..offsetY)
		end


		self:setFocusOffset(offsetX, offsetY)
		return force
	end


	function view:forceGridSize()
		local offsetX = leftRightLimit
		local offsetY = upDownLimit
		
		if offsetY > 80 then
--			print("Forcing offsetY to 80")
			self:setFocusOffset(offsetX, 80)
		end		
	end


	--Move camera to an (x,y) point
	function view:toPoint(x, y)
		local x=x or ccx
		local y=y or ccy
		local tempFocus={x=x, y=y}
		
		view:cancel()
		view:setFocus(tempFocus)
		view:track()

		return tempFocus
	end
	

	function view:setFocus(obj)
		-- unset previous focus from being the focus
		if view.CONF.focus then
			view.CONF.focus.isFocus = false
		end
		view.CONF.focus = obj
		obj.isFocus = true
	end


	function view:restoreFocus(item)
		view:applyBounds(false)
		view:setFocus(item)
		after(200, function() view:applyBounds(true) end)
	end


    function view:getXPosition()
        return ccx
    end


    function view:setXPosition(changeX)
        local newX = ccx + changeX

        if newX < display.contentCenterX + leftRightLimit and 
           newX > display.contentCenterX - leftRightLimit
        then
            ccx = newX
        end
    end


	function view:setFocusOffset(x, y)
		leftRightLimit = x
		upDownLimit    = y
		ccx	= display.contentCenterX - x
		ccy	= display.contentCenterY + y
	end
	

	--Get a layer
	function view:layer(t)
		return layer[t]
	end


	--Set parallax easily for each layer
	function view:setParallax(...)
		for i=1, #arg do 
			layer[i].parallaxRatio = arg[i]
		end
	end


	--Remove an object from the camera
	function view:remove(obj)
		if obj~=nil and layer[obj._perspectiveLayer]~=nil then
			layer[obj._perspectiveLayer]:remove(obj)
    	end
  	end
	

	function view:destroy()
		for n=1, numLayers do
			for i=1, #layer[n] do
				layer[n]:remove(layer[n][i])
			end
		end
		
		if isTracking then
			Runtime:removeEventListener("enterFrame", view.trackFocus)
		end

		drm(view)
		view = nil
    end


    function view:setAlpha(alpha)
	    for i=1, numLayers do
	    	layer[i].alpha = alpha
	    end
	end


    function view:transitionAlpha(alpha, time)
	    for i=1, numLayers do
	    	transition.to(layer[i], {alpha=alpha, time=time})
	    end
	end


	function view:scale(scaleHandler)
	    if not self.scaling then
	        self.scaling = true
	        self:cancel()

	        local bound1 = layer[2][1]
			local bound2 = layer[2][2]

	        if self.scaleMode then
	            self.scaleMode     = false
	            self.scaleImage    = 1
	            self.scalePosition = 1/0.6
	            self.scaleVelocity = 1
	            -- restore original speeds rather than recalc them and leave them slightly off each time
	            setMovementStyleSpeeds()
	        else
	            self.scaleMode     = true
	            self.scaleImage    = 0.6
	            self.scalePosition = 0.6
	            self.scaleVelocity = 0.75
	            -- scale movement pattern speeds
	            scaleMovement(self.scalePosition)
	        end
	        
	        -- scale boundaries
	        bound1.x = bound1.x * self.scalePosition
			bound1.y = bound1.y * self.scalePosition
			bound2.x = bound2.x * self.scalePosition
			bound2.y = bound2.y * self.scalePosition

	        scaleHandler()
			
	        self.scaling = false
	        self:track()
	    end
	end


	return view
end


return Perspective