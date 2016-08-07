local composer    = require("composer")
local anim        = require("core.animations")
local soundEngine = require("core.sound-engine")
local builder     = require("level-objects.builders.builder")
local spineStore  = require("level-objects.collections.spine-store")

-- Local vars:
local scene           = composer.newScene()
local spineCollection = nil
local lastTime        = 0

-- Aliases:
local play = globalSoundPlayer


-- Things that need to happen as fast as possible (every frame e.g 60 loops per second)
local function sceneEnterFrameEvent(event)
    globalFPS = globalFPS + 1
    spineCollection:animateEach(event)
end


-- Treat phone back button same as back game button
local function sceneKeyEvent(event)
    if event.keyName == "back" and event.phase == "up" then
        scene:exitFruitMachine()
        return true
    end
end


-- Called when the scene's view does not exist:
function scene:create(event)
    spineCollection = builder:newSpineCollection()
    spineStore:load(spineCollection)

    newBackground(self.view, "shop/bgr")
end


-- Called immediately after scene has moved onscreen:
function scene:show(event)
    if event.phase == "did" then
        self:init()

        play(sounds.zoneSummary)
        Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:addEventListener("key", sceneKeyEvent)

        self:createElements()
    end
end


function scene:init()
    logAnalyticsStart()
    state:newScene("fruit-machine")
end


function scene:createElements()
    newText(self.view, "select a randomizer",     centerX, 60,  1, "white", "CENTER")
    newText(self.view, "to collect your reward!", centerX, 120, 1, "red",   "CENTER")

    self.box1 = builder:newSpineObject({key="randomizer1"}, {jsonName="item-randomizer", imagePath="collectables", scale=1.5, animation="Standard"})
    self.box2 = builder:newSpineObject({key="randomizer2"}, {jsonName="item-randomizer", imagePath="collectables", scale=1.5, animation="Standard"})
    self.box3 = builder:newSpineObject({key="randomizer3"}, {jsonName="item-randomizer", imagePath="collectables", scale=1.5, animation="Standard"})

    self.box1:moveTo(centerX-300, 400)
    self.box2:moveTo(centerX,     400)
    self.box3:moveTo(centerX+300, 400)

    spineCollection:add(self.box1)
    spineCollection:add(self.box2)
    spineCollection:add(self.box3)

    self.box1.image:addEventListener("tap", function() scene:selectRandomizer(self.box1) end)
    self.box2.image:addEventListener("tap", function() scene:selectRandomizer(self.box2) end)
    self.box3.image:addEventListener("tap", function() scene:selectRandomizer(self.box3) end)
end


function scene:selectRandomizer(item)
    if not scene.rewardSelected then
        scene.rewardSelected = true

        play(sounds.checkpoint)
        item:animate("Activated")

        self.rewardColor = math.random(3)
        self.ring = spineStore:showRing(item:x(), item:y()-75, self.rewardColor, 2.5)

        local seq = anim:chainSeq("randomizer", item.image)
        seq:callback(function() 
            local seq2 = anim:chainSeq("ring", self.ring.image)
            seq2:tran({y=self.ring:y()-200, time=500, transition=easing.outCirc,   playSound=soundEngine:getRandomRing() })
            seq2:tran({y=self.ring:y(),     time=500, transition=easing.outBounce, playSound=sounds.awardStar})
            seq2.onComplete = scene.complete
            seq2:start()
        end)
        seq:tran({time=1000, alpha=0, delay=0})
        seq:start()
    end
end


function scene:complete()
    local self = scene

    if self.rewardColor >= 1 and self.rewardColor <= 3 then
        state:addHolocubes(self.rewardColor)
        state:saveGame()
    end

    self:exitFruitMachine()
end


function scene:exitFruitMachine()
    after(1000, function() composer.gotoScene(state:backScene()) end)
end


-- Called when scene is about to move offscreen:
function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:removeEventListener("key", sceneKeyEvent)

        track:cancelEventHandles()
        anim:destroy()
        spineStore:destroy()
        logAnalyticsEnd()

        self.box1:destroy()
        self.box2:destroy()
        self.box3:destroy()
        self.ring:destroy()
        self.box1, self.box2, self.box3, self.ring = nil, nil, nil, nil

    elseif event.phase == "did" then
        composer.removeScene("scenes.fruit-machine")
    end
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroy(event)
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener("create",  scene)
scene:addEventListener("show",    scene)
scene:addEventListener("hide",    scene)
scene:addEventListener("destroy", scene)

return scene