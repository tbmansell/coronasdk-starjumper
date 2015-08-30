local storyboard   = require("storyboard")
local anim         = require("core.animations")
--local spineFactory = require("core.spine-factory")
--local collectables = require("level-objects.collectables")

local play = realPlayer


-- creates the gear icons that show whats selected, instead of the full list, when jumping
local function createSelectedGearTab()
    local xpos  = 410
    local group = display.newGroup()

    hud.gearSelected = {}
    hud.slotsSelectedGroup = group
    hud.group:insert(group)
    group.alpha = 0
    
    for category=jump,land do
        local slot    = hud:makeGearSlot(group, xpos, 560)
        slot.category = category

        hud.gearSelected[category] = slot
        xpos = xpos + 70
    end
end

-- adds thrown negable slot to the selected gear tab
local function addSelectedNegableTab(category)
    local slot    = hud:makeGearSlot(hud.slotsSelectedGroup, 620, 560)
    slot.category = category
    hud.gearSelected[category] = slot
end


local function selectGear(gear, category, isNegable)
    local slot = hud.gearSelected[category]

    if slot.icon and slot.gear == gear then
        return
    elseif slot.icon then
        slot.icon:removeSelf()
    end

    play(sounds.hudClick)

    local xpos = 340 + (category*70)
    local type = "gear"
    if isNegable then type="negable" end

    slot.icon = newImage(hud.slotsSelectedGroup, "collectables/"..type.."-"..gearNames[category].."-"..gear, xpos+30, 590, 0.4)
    slot.gear = gear

    hud.activeGear[category] = gear
end


local function deselectGear(category)
    play(sounds.hudClick)
    
    local slot = hud.gearSelected[category]

    if slot.icon then
        slot.icon:removeSelf()
        slot.icon = nil
        slot.gear = nil
    end

    hud.activeGear[category] = nil
end


local function clearSelectedGear()
    for category=jump,land do
        deselectGear(category)
    end
end


local function setSelectorAlpha(selector)
    if selector.quantity > 1 then 
        selector.alpha, selector.text.alpha = 1, 1
    elseif selector.quantity == 1 then 
        selector.alpha, selector.text.alpha = 1, 0
    else 
        selector.alpha, selector.text.alpha = 0.3, 0
    end
end


-- Handles selecting/unselecting gear
local function gearSelectorTap(self, event)
    if self.quantity > 0 and not self.active then
        -- check that no other gear in this category is active
        local category, num = self.category, #hud.gearSelectors
        
        for i=1,num do
            local selector = hud.gearSelectors[i]
            if selector.category == category and selector.active then
                return true
            end
        end

        if self.selected then
            if not allowPlayerAction("deselect-gear", self.gear) then return true end

            self.selected = false
            hud:deactivateSlot(self.slot)
            deselectGear(category)
            if self.gear == gearJetpack then hud:removeJetpackFuel() end
        else
            if not allowPlayerAction("select-gear", self.gear) then return true end

            -- deselect other gear in this category
            for i=1,num do
                local selector = hud.gearSelectors[i]
                if selector.category == category then
                    selector.selected = false
                    hud:deactivateSlot(selector.slot)
                end
            end
            hud:activateSlot(self.slot)
            self.selected = true
            selectGear(self.gear, category)

            if self.gear == gearJetpack then 
                hud:createJetpackFuel() 
            else 
                hud:removeJetpackFuel() 
            end

            -- check if we should do a throw
            if category == negGood or category == negEnemy then
                hud:prepareThrownNegable()
            end
        end
        -- assign to player and cancel other events
        hud:assignActiveGearToPlayer()
    end
    -- assign to player and cancel other events
    --hud:assignActiveGearToPlayer()
    return true
end


local function fadeObject(name, object, alpha, time)
    local seq = anim:oustSeq(name, object)
    seq:tran({alpha=alpha, time=time})
    seq:start()
end


-- Handles the gear selector switch
local function switchGearSelectors(self, event)
    -- dont allow displaying selector groups while the summary is being shown (jumping)
    if hud.slotsSelectedGroup.alpha == 0 then
        local group1 = hud.slotsGroup
        local group2 = hud.slotsNegaGroup
        local show   = self.show

        if show == "main" and self.negables then
            self.show  = "nega"
            fadeObject("mainSelectors", group1, 0, 150)
            if group2 then fadeObject("negaSelectors", group2, 1, 150) end

        elseif show == "main" or show == "nega" then
            self.show = "none"
            fadeObject("mainSelectors", group1, 0, 150)
            if group2 then fadeObject("negaSelectors", group2, 0, 150) end

        elseif show == "none" then
            self.show = "main"
            fadeObject("mainSelectors", group1, 1, 150)
            if group2 then group2.alpha = 0 end
        end
    end
end


local function createSwitchButton(group)
    local switch = newImage(group, "hud/selector-switch", 55, 590, 0.4)
    switch.show  = "main"
    switch.tap   = switchGearSelectors
    switch:addEventListener("tap", switch)
    switch:addEventListener("touch", function() return true end)
    --hud:negafySlot(switch)
    hud.selectorSwitch = switch
end



-- creates the gear selection icon at the bottom of the hud
function hud:createGearSelectors()
    local xpos        = 100
    local group       = display.newGroup()
    local switchGroup = display.newGroup()
    
    self.gearSelectors       = {}   -- straight 1,2,3 index of slots fo r faster looping
    self.gearSelectorsDirect = {}   -- indexed by gear name for direct referencing
    self.slotsGroup          = group
    self.slotsSwitchGroup    = switchGroup
    self.group:insert(group)
    self.group:insert(switchGroup)

    createSwitchButton(switchGroup)
    
    for category=jump,land do
        local slotGroup = self.slotPositions[category]
        for i=1, #slotGroup do
            local gear     = slotGroup[i]
            local quantity = state:gear(category,gear)
            local slot     = self:makeGearSlot(group, xpos, 560)
            local icon     = newImage(group, "collectables/gear-"..gearNames[category].."-"..gear, xpos+30, 590, 0.4)
            local text     = newText(group, quantity, xpos+55, 610, 0.45, "white", "RIGHT")

            icon.slot     = slot
            icon.text     = text
            icon.category = category
            icon.gear     = gear
            icon.quantity = quantity
            icon.selected = false
            icon.active   = false
            icon.negIcons = {}  -- list of negable icons that can overlay the selector blocking its use

            setSelectorAlpha(icon)

            icon.tap = gearSelectorTap
            icon:addEventListener("tap", icon)
            icon:addEventListener("touch", function() return true end)
            self.gearSelectors[#self.gearSelectors+1] = icon
            self.gearSelectorsDirect[gear] = icon
            xpos = xpos + 65
        end
    end
    -- add negable tab for selected items
    createSelectedGearTab()
end


-- creates the gear selection icon at the bottom of the hud
function hud:createNegableSelectors(category)
    local xpos  = 100
    local group = display.newGroup()

    self.slotsNegaGroup = group
    self.group:insert(group)
    self.selectorSwitch.negables = true
    group.alpha = 0

    local slotGroup = self.slotPositions[category]
    for i=1, #slotGroup do
        local gear     = slotGroup[i]
        local native   = 0

        if characterData[self.player.model].nativeNegable == gear then
            native = 1
        end

        local quantity = state:gear(category, gear) + native
        local slot     = self:makeGearSlot(group, xpos, 560)
        local icon     = newImage(group, "collectables/gear-"..gearNames[category].."-"..gear, xpos-45, 515, 0.4)
        local text     = newText(group, quantity, xpos+55, 610, 0.45, "white", "RIGHT")

        icon.slot     = slot
        icon.text     = text
        icon.category = category
        icon.gear     = gear
        icon.quantity = quantity
        icon.selected = false
        icon.active   = false

        setSelectorAlpha(icon)

        icon.tap = gearSelectorTap
        icon:addEventListener("tap", icon)
        icon:addEventListener("touch", function() return true end)
        self.gearSelectors[#self.gearSelectors+1] = icon
        self.gearSelectorsDirect[gear] = icon
        xpos = xpos + 65
    end
    
    -- create tab for selected items
    addSelectedNegableTab(category)
end



-- removes gear from player inventory and updates the hud selectors
-- @return true if gear should remain active, false if gear should be deselected from player
function hud:deductGearSelectors(gear, quantity)
    local selector = self.gearSelectorsDirect[gear]
    local deselect = false

    selector.active   = false
    selector.quantity = quantity
    selector.text:setText(quantity)

    if quantity < 1 or selector.category == jump then
        selector.selected = false
        hud:deactivateSlot(selector.slot)
        deselectGear(selector.category)
        deselect = true
    end

    setSelectorAlpha(selector)

    return deselect
end


-- Animates hiding / showing the gear selectors
function hud:showGearSummary()
    self:transitionGearDisplays(0, 1)
end

function hud:showGearFull()
    local gameState = state.data.game 

    if gameState ~= levelOverFailed and gameState ~= levelOverComplete then
        self:transitionGearDisplays(1, 0)
    end
end

function hud:hideGear()
    self:transitionGearDisplays(0, 0)
end

function hud:transitionGearDisplays(fullAlpha, selectedAlpha)
    local show = self.selectorSwitch.show
    local seq1 = anim:oustSeq("hideFullSlots", self.slotsSwitchGroup)

    -- only make selector group visible if switch allows it
    if fullAlpha == 0  then
        seq1.target2 = self.slotsGroup
        seq1.target3 = self.slotsNegaGroup
    elseif show == "main" then
        seq1.target2 = self.slotsGroup
    elseif show == "nega" then
        seq1.target2 = self.slotsNegaGroup
    end

    seq1:tran({alpha=fullAlpha, time=250})

    local seq2 = anim:oustSeq("showSummarySlots", self.slotsSelectedGroup)
    seq2:tran({alpha=selectedAlpha, time=250})

    seq1:start()
    seq2:start()
end


function hud:assignActiveGearToPlayer()
    self.player:setGear({
        [jump]     = self.activeGear[jump], 
        [air]      = self.activeGear[air], 
        [land]     = self.activeGear[land],
        [negGood]  = self.activeGear[negGood],
        [negEnemy] = self.activeGear[negEnemy],
    })
end


function hud:markGearInUse(gear)
end


-- called when player collects some gear in-level: adds to their inventory, but does not auto-select it
function hud:assignGear(gear)
    local category = gearSlots[gear]
    local selector = self.gearSelectorsDirect[gear]

    selector.quantity = selector.quantity + 1
    selector.text:setText(selector.quantity)

    setSelectorAlpha(selector)

    if category ~= jump then
        selector.selected = false  -- do this so function always selects it
        gearSelectorTap(selector)
    end
end


function hud:assignNegable(negable)
    local category = negableSlots[negable]
    -- check if this negable (which could be thrown) hijacks a players gear slot for a given category
    if category then
        selectGear(negable, category, true)
        self:assignActiveGearToPlayer()

        -- add a blocker image over all selectors in the category
        for i=1, #self.gearSelectors do
            local selector = self.gearSelectors[i]

            if selector.category == category then
                local x, y    = selector.x, selector.y
                local negIcon = newImage(self.slotsGroup, "collectables/negable-"..gearNames[category].."-"..negable, x, y, 0.4)
                negIcon.x, negIcon.y = x, y

                negIcon:addEventListener("tap",   function() return true end)
                negIcon:addEventListener("touch", function() return true end)

                selector.negIcons[#selector.negIcons+1] = negIcon
                selector.alpha, selector.text.alpha = 0, 0
                selector.selected = false
                self:negafySlot(selector.slot)
            end
        end
    end
end


function hud:useUpGear(gear)
    local category = gearSlots[gear]
    local quantity = state:useGear(category, gear)

    if self:deductGearSelectors(gear, quantity) then
        self.activeGear[category] = nil
        self:assignActiveGearToPlayer()
    end

    if gear == gearJetpack then
        if quantity == nil or quantity < 1 then
            self:removeJetpackFuel()
        else
            self:resetJetpackFuel()
        end
    end

    -- if player has found this gear item in level, remove it there first
    for i=1, #self.gearFoundInLevel do
        if self.gearFoundInLevel[i] == gear then
            table.remove(self.gearFoundInLevel, i)
            break
        end
    end
end


-- deselects all selectors in the category and clears and negables attached to them
function hud:clearSlot(category)
    deselectGear(category)
    self.activeGear[category] = nil
    self:assignActiveGearToPlayer()

    for i=1, #self.gearSelectors do
        local selector = self.gearSelectors[i]

        if selector.category == category then
            selector.selected = false
            self:deactivateSlot(selector.slot)

            local num = #selector.negIcons
            if num > 0 then
                for i=1,num do
                    selector.negIcons[1]:removeSelf()
                    table.remove(selector.negIcons, 1)
                end

                setSelectorAlpha(selector)
            end
        end
    end
end


-- Determines if all player gear found in level that has not been used, should be removed from the player
-- optional @always param overrides other logic
function hud:removeGearFoundInLevel(always)
    local gameType = state.data.gameSelected

    if always or
       state.data.game ~= levelOverComplete or  -- if aborting before completion or replying
       gameType == gameTypeTimeAttack or
       gameType == gameTypeSurvival or
       gameType == gameTypeRace
    then
        for i=1, #self.gearFoundInLevel do
            local gear     = self.gearFoundInLevel[1]
            local category = gearSlots[gear]

            state:useGear(category, gear)
            table.remove(self.gearFoundInLevel, 1)
        end
    end
end


-- creates and animates the jetpack fuel bar
function hud:createJetpackFuel()
    local group      = display.newGroup()
    self.jetpackFuel = group
    self.group:insert(group)

    local barColor  = display.newRect(group,  75, 87, 146, 23)
    local barBorder = display.newImage(group, "images/hud/progress-bar.png", 0,0)

    barBorder:scale(0.3, 0.5)
    barBorder.x, barBorder.y = 100, 110
    --barColor:setReferencePoint(display.CenterLeftReferencePoint)
    barColor.anchorX = 0
    barColor.x, barColor.y = 24, 100
    barColor:setFillColor(1,0,0)

    self.jetpackFuelRemaining = barColor
end

function hud:removeJetpackFuel()
    if self.jetpackFuel then
        self.jetpackFuel:removeSelf()
        self.jetpackFuel = nil
    end
end

function hud:useJetpackFuel()
    if self.jetpackFuel ~= nil then
        local seq = anim:chainSeq("jetpackFuel", self.jetpackFuelRemaining)
        seq:add("progressbar", {loops=33, countStep=-(145 / 100)})
        seq:start()
    end
end

function hud:resetJetpackFuel()
    if self.jetpackFuel ~= nil then
        self.jetpackFuelRemaining.width = 146
        self.jetpackFuelRemaining.x = 24
    end
end


-- Creates the rounded rectangles used to highlight gear selectors
function hud:makeGearSlot(group, x, y)
    local slot = display.newRoundedRect(group, x+30, y+30, 62, 62, 10)
    slot.strokeWidth = 2
    hud:deactivateSlot(slot)
    return slot
end

function hud:activateSlot(slot)
    slot.alpha = 1
    slot.strokeWidth = 10
    slot:setFillColor(1,1,0.5, 0.5)
    slot:setStrokeColor(1,1,0, 0.5)
end

function hud:deactivateSlot(slot)
    slot.strokeWidth = 2
    slot:setFillColor(0.2,0.2,0.2, 0.4)
    slot:setStrokeColor(0.4,0.4,0.4, 0.5)
end

function hud:negafySlot(slot)
    slot.strokeWidth = 10
    slot:setFillColor(1,0.2,0.2, 0.5)
    slot:setStrokeColor(0.8,0.1,0.1, 0.5)
end

function hud:markSlotsInUse(slot1, slot2, category)
    local seq   = anim:oustSeq("usingSlot-"..category, slot1)
    seq.target2 = slot2
    seq:add("glow", {time=250, delay=50, alpha=1})
    seq:start()
end



-- Initiates the player throwing a negable and creates the icon for them to throw
function hud:prepareThrownNegable()
    local self   = hud
    local player = self.player

    -- allow if in playerDrag mode as its easy to get stuck in this when attacking others
    if state.data.game == levelPlaying and (player.mode == playerReady or player.mode == playerDrag) then
        -- This to clear the start buttons
        self:levelStartedSequence()

        local charData = characterData[player.model]
        local category = negGood

        if charData.enemy then category = negEnemy end

        -- create a negable icon to throw and move it with the throwing hand
        local scale    = self.camera.scaleImage
        local negable  = self.activeGear[category]
        local category = gearSlots[negable]
        local icon     = newImage("collectables/gear-"..gearNames[category].."-"..negable, 0, 0, 0.2*scale, 0)
        
        icon.x, icon.y = player:x(), player:y() - (((player.height*scale)/4)*3)
        self.camera:add(icon, 3)

        local tox = icon.x - (50*scale)
        if player.direction == left then tox = icon.x + (50*scale) end

        local seq = anim:oustSeq("prepareNegable-"..player.name, icon)
        seq:wait(100)
        seq:callback(function() icon.alpha=1 end)
        seq:tran({x=tox, time=650})
        seq:start()

        player:prepareThrow(icon, negable, category)
    end
end


function hud:hideGameHud()
    self:hideGear()
    self.textDebugMode.alpha    = 0
    self.textPhysicsMode.alpha  = 0
    self.textScore.alpha        = 0
    self.textTime.alpha         = 0
    self.magnifyIcon.alpha      = 0
    self.textLives.alpha        = 0
    self.iconLives.alpha        = 0
    if self.irunGroup then self.irunGroup.alpha = 0 end
    if self.challengeIcon then self.challengeIcon.alpha = 0 end
end
