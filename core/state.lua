local json = require("json")

local state = {
    -- filename for autosaved game
    autosave_filename = "autosave.dat",

    -- change this to redirect to a different scene after the current cutscene is completed
    sceneAfterCutScene = "scenes.select-zone",

    -- marks which story script to run when mothership custene is run
    cutsceneStory = "cutscene-game-intro",
    -- marks a new characters intro for a cutscene
    cutsceneCharacter = nil,

    -- mark as true when starting an infinite runner game
    infiniteRunner = false,

    -- a stack used to remember nested scenes navigation route, use state:newScene() and state:backScene() to traverse
    --[[ E.g. sceneHistory = {
        When player is in shop from zone select:     "title", "select-planet", "select-zone", "shop", 
        When player is in story zone:                "title", "select-planet", "select-zone", "play-zone",
        When player is in shop from story zone:      "title", "select-planet", "select-zone", "play-zone", "shop"
        When player is in timeAttack zone:           "title", "select-planet-simple", "select-zone-simple", "play-zone",
        When player is in charselect from race zone: "title", "select-planet-simple", "select-zone-simple", "play-zone", "select-player"
    }, ]]
    sceneHistory = {},

    -- when using backScene() recorsd the one you was in before going back
    prevScene = nil,

    -- mark as true to allow music in current scene to cotinue playing in next scene
    musicSceneContinue = false,
    -- used as a global way to determine what inapp purchase is being requested or bought
    inappPurchaseType  = nil,
    
    -- Race mode only: used when moving from zone select to play-zone to set which player is in which position
    racePositions = {},

    -- Used for when loading a demo game: a table of actions that need to be performed in sequence
    demoActions = nil,

    -- This table contains all the app state that needs saving to file
    data = {
        buildVersion   = globalBuildVersion,  -- used to determine data transforms for later versions
        playerModel    = nil,   -- int const for the player selected: eg characterNewton 
        playerSkin     = nil,   -- name of the playerModel's selected skin
        gameSelected   = nil,   -- int const game to be played
        planetSelected = nil,   -- int number of current planet loaded
        zoneSelected   = nil,   -- int number of current zone loaded
        game           = nil,   -- used for in game state (level...)
        score          = 0,     -- players total game score
        holocubes      = 0,     -- players total number cubes
        multiplayer    = false, -- true if in multiplayer mode
        zoneHudAwards  = false, -- used for zone select scene: false to show zone rank, true to show zone awards

        -- list of game settings that can be changed in the settings page
        gameSettings = {
            backgrounds = true, -- make backgrounds move in levels: turn off for fixed backgrounds to speed game up
            music       = true, -- play music in menu and game scenes: turn off for no music
            adverts     = true, -- show adverts: can only be turned off by purchasing a pack
        },

        -- complete level progress for game,  in this format:
        --[[]
        levelProgress  = {
            [1] = {  -- planet 
                [gameTypeStory] = {  -- game type
                    [1] = {  --zone
                        plays     = 0,      -- number of times player has *completed* a zone, used to modify scoring
                        completed = false,  -- player has completed the zone in the current game mode
                        jumpScore = 0,      -- player jump score
                        timeScore = 0,      -- player time bonus
                        ranking   = 0,      -- ranking received on completion
                        topStage  = 0,      -- for infinite runs: tells highest stage player has reached
                        topLedge  = 0,      -- for infinite runs: tells highest ledge # player has reached
                        awards    = {       -- list of awards player won
                            awardNumber, ...
                        },
                        fuzzies   = {       -- list of fuzzies collected by key
                            fuzzyKey = {color=color, kinetic=kinetic, direction=direction}, ...
                        },
                        jumpScores = {       -- list of scores for each ledge
                            ledgeId = score, ...
                        },
                        completedAs = {      -- list of playerModels the zone has been completed as
                            characterNewton, ...
                        },
                    },
                }
            }
        },]]
        levelProgress = {},

        -- Gear players currently owns:
        --[[
        playerGear = {
            [jump] = {
                ["item"] = quantity,
            },
            [air] = {
                ["item"] = quantity,
            },
            [land] = {
                ["item"] = quantity,
            }
        }]]
        playerGear = {
            [jump]     = {},
            [air]      = {},
            [land]     = {},
            [negGood]  = {},
            [negEnemy] = {},
        },
        -- Negables player currently owns - same structure as for playerGear:
        playerNegables = {
            [jump] = {},
            [air]  = {},
            [land] = {}
        },

        -- Simple list of storyIds that the player has seen and tapped OK to ensure they dont play again
        storiesAcknowledged   = {},
        -- Simple list of tutorialIds that the player has seen and tapped OK to ensure they dont play again
        tutorialsAcknowledged = {},

        -- Structure which holds all items that player has unlocked. Anything that does not appear in here is automatically locked
        -- This is the starting structure when nothing is unlocked.
        unlocked = {
            -- list of characters unlocked
            --characters = { characterNewton },
            characters = { characterNewton, characterSkyanna, characterKranio, characterHammer, characterReneGrey, characterRobocop },
            -- list of gear that is unlocked
            --gear = {},
            gear = { gearJetpack, gearParachute, gearGlider, gearReverseJump, gearTrajectory, gearSpringShoes, gearShield, gearFreezeTime, gearGloves, gearGrappleHook },
            -- list of planets that are unlocked
            planets = {
                [1] = {
                    -- list of zones in planet that are unlocked
                    --zones = { 1 },
                    zones = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21},
                    -- list of game modes for planet that are unlocked
                    --games = { gameTypeStory }
                    games = { gameTypeStory, gameTypeSurvival, gameTypeTimeAttack, gameTypeTimeRunner, gameTypeClimbChase }
                },

                [2] = {
                    -- list of zones in planet that are unlocked
                    --zones = { 1 },
                    zones = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21},
                    -- list of game modes for planet that are unlocked
                    --games = { gameTypeStory }
                    games = { gameTypeStory, gameTypeSurvival, gameTypeTimeAttack, gameTypeTimeRunner, gameTypeClimbChase }
                },
            }
        }
    }
}


---------- MANAGE SCENE CHANGE ----------


-- Adds a new scene name to the scene list, if it is not the current scene (so avoids sequential dups)
function state:newScene(name)
    local num = #self.sceneHistory
    if self.sceneHistory[num] ~= name then
        self.sceneHistory[num+1] = name
    end
end


-- Removes the last name from the scene list and returns the new currentScene
function state:backScene()
    self.prevScene = self.sceneHistory[#self.sceneHistory]

    table.remove(self.sceneHistory)

    if #self.sceneHistory == 0 then
        return "scenes.title"
    else
        return "scenes."..self.sceneHistory[#self.sceneHistory]
    end
end


-- Gets the last scene from the list (current scene)
function state:currentScene()
    return "scenes."..self.sceneHistory[#self.sceneHistory]
end


-- Checks if a story should be shown (in story mode and has not been seen yet)
function state:showStory(storyId)
    -- Only show story in story mode
    if self.data.gameSelected ~= gameTypeStory then
        return false
    end

    if self.data.storiesAcknowledged and self.data.storiesAcknowledged[storyId] then
        return false
    end

    return true
end


-- Checks if a tutorial should be shown
function state:showTutorial(tutorialId)
    return (self.data.tutorialsAcknowledged and not self.data.tutorialsAcknowledged[tutorialId])
end


-- Updates the saved data to mark this story has been viewed
function state:saveStoryViewed(storyId)
    if string.sub(storyId, 1, 9) ~= "cutscene-" then
        if self.data.storiesAcknowledged == nil then 
            self.data.storiesAcknowledged = {}
        end

        self.data.storiesAcknowledged[storyId] = true
        self:saveGame()
    end
end


---------- MANAGE HOLOCUBES / GEAR -----------


-- Adds a number of holocubes to the players total
function state:addHolocubes(amount)
    if amount > 0  then
        state.data.holocubes = state.data.holocubes + amount
    end
end


-- Adds a peice of player gear to the global state structure so it can be saved
function state:addGear(category, gear)
    local exists = self.data.playerGear[category][gear]

    if exists ~= nil then
        local quantity = self.data.playerGear[category][gear]
        self.data.playerGear[category][gear] = quantity + 1
    else
        self.data.playerGear[category][gear] = 1
    end
end


-- Removes a peice of gear from the global state, as happens when it is has been used up
function state:useGear(category, gear)
    if self.data.playerGear[category] then
        local quantity = self.data.playerGear[category][gear]

        if quantity ~= nil and quantity > 0 then
            quantity = quantity - 1
            self.data.playerGear[category][gear] = quantity
            return quantity
        end
    end
    return 0
end


-- returns the number of a peice of gear the player owns
function state:gear(category, gear)
    if self.data.playerGear[category] == nil then
        return 0
    end
    return self.data.playerGear[category][gear] or 0
end


-- Adds a negable to the player
function state:addNegable(category, gear)
    local negs = self.data.playerNegables

    if negs[category] then
        local exists = negs[category][gear]

        if exists ~=nil then
            --local quantity = exists --self.data.playerNegables[category][gear]
            self.data.playerNegables[category][gear] = exists + 1
        else
            self.data.playerNegables[category][gear] = 1
        end
    end
end


-- Removes a used negable from the player
function state:useNegable(category, gear)
    local exists = table.indexOf(self.data.playerNegables[category], gear)

    if exists then
        local quantity = self.data.playerNegables[category][gear]
        if quantity > 0  then
            self.data.playerNegables[category][gear] = quantity - 1
        end
    else
        print("Warning: there was no negable to use: "..category.." "..gear)
    end
end


-- returns the quantity of a negable
function state:negable(category, gear)
    local quantity = self.data.playerNegables[category][gear]
    if quantity == nil then
        return 0
    else
        return quantity
    end
end


---------- PLANETS / ZONES - GET DATA  ----------


-- returns the list of zones for a planet/game
function state:getZones(planetNumber, gameType)
    local planet = planetNumber or self.data.planetSelected
    local game   = gameType     or self.data.gameSelected

    return self.data.levelProgress[planet][game]
end


-- returns a single zones state
function state:zoneState(zoneNumber, planetNumber, gameType)
    local planet = planetNumber or self.data.planetSelected
    local game   = gameType     or self.data.gameSelected

    if self.data.levelProgress[planet][game][zoneNumber] == nil then
        return nil
    else
        return self.data.levelProgress[planet][game][zoneNumber]
    end
end


-- returns a single zone based on current state.data settings
function state:currentZone()
    return state:zoneState(state.data.zoneSelected, state.data.planetSelected, state.data.gameSelected)
end


-- gets number of zones in a planet
function state:numberZones(planetNumber, gameType)
    local planet = planetNumber or self.planetSelected
    local game   = gameType     or self.data.gameSelected

    return #self.data.levelProgress[planet][game]
end


-- returns the highest zone the player is allowed to play in the current planet
function state:numberZonesPlayable(planetNumber)
    local planet   = planetNumber or self.data.planetSelected
    local zones    = self.data.unlocked.planets[planet]

    if zones == nil then
        return 0
    end

    zones = zones.zones
    local playable = 0

    if zones then
        for _,zoneNumber in pairs(zones) do
            if zoneNumber > playable then
                playable = zoneNumber
            end
        end
    end

    return playable
end


-- returns number zones player has completed (= # playable -1)
function state:numberZonesCompleted(planetNumber, gameType)
    local planet    = planetNumber or self.data.planetSelected
    local game      = gameType     or self.data.gameSelected
    local zones     = self:getZones(planet, game)
    local completed = 0

    if zones then
        local num = #zones
        for i=1, num do
            local zone = zones[i]

            if zone and zone.completed then
                completed = completed + 1
            end
        end
    end

    return completed
end


-- returns the total zones completed accross planets for story mode - used for gear unlocks
function state:totalStoryZonesCompleted()
    local completed = 0

    for i=1, #planetData do
        if self:planetUnlocked(i) then
            completed = completed + self:numberZonesCompleted(i, gameTypeStory)
        end
    end

    return completed
end


-- returns number zones player has completed (= # playable -1)
function state:numberZonesCompletedAs(planetNumber, gameType, player)
    local planet    = planetNumber or self.data.planetSelected
    local game      = gameType     or self.data.gameSelected
    local zones     = self:getZones(planet, game)
    local completed = 0

    if zones then
        local num = #zones
        for i=1, num do
            local zone = zones[i]

            if zone and zone.completedAs and table.indexOf(zone.completedAs, player) ~= nil then
                completed = completed + 1
            end
        end
    end

    return completed
end


-- returns the player with the highest # zones completed and how many they completed
function state:highestZonesCompleted(planetNumber, gameType)
    local planet    = planetNumber or self.data.planetSelected
    local completed = 0
    local character = nil

    for char,_ in pairs(characterData) do
        local info = characterData[char]

        if info.playable and self:characterUnlocked(char) then
            local num = self:numberZonesCompletedAs(planet, gameType, char)

            if num >= completed then 
                character, completed = char, num
            end
        end
    end
    return character, completed
end


-- returns the number of fuzzies the player has collected for a planet, in story mode
function state:numberFuzziesCollected(planetNumber)
    local planet    = planetNumber or self.data.planetSelected
    local zones     = self:getZones(planet, gameTypeStory)
    local collected = 0

    if zones then
        local num = #zones
        for i=1, num do
            local zone = zones[i]
            -- have to loop as indexed by fuzzy key
            if zone.fuzzies then
                for _,_ in pairs(zone.fuzzies) do
                    collected = collected + 1
                end
            end
        end
    end

    return collected
end


-- returns the number of fuzzies the player has collected for a planet, in story mode
function state:numberAwardsCollected(planetNumber, gameType)
    local planet    = planetNumber or self.data.planetSelected
    local game      = gameType     or self.data.gameSelected
    local zones     = self:getZones(planet, game)
    local collected = 0

    if zones then
        local num = #zones
        for i=1, num do
            local zone = zones[i]
            -- have to loop as indexed by fuzzy key
            if zone.awards then
                for _,_ in pairs(zone.awards) do
                    collected = collected + 1
                end
            end
        end
    end

    return collected
end


-- return total number of stars player has earned for a planet / game mode
function state:planetStarRanking(planetNumber, gameType)
    local planet    = planetNumber or self.data.planetSelected
    local game      = gameType     or self.data.gameSelected
    local zones = self:getZones(planet, game)
    local stars = 0

    if zones then
        local num = #zones
        for i=1, num do
            stars = stars + zones[i].ranking
        end
    end

    return stars
end


---------- PLANETS / ZONES - SET DATA  ----------


-- when a player completes a level, records their result and makes next zone playable
-- data is only updated if it is better than the previous - so if someone plays the same level again
-- their highest score/rank is kept and awards are only added, not replaced
function state:completeZone(zoneNumber, levelScore, ranking, awards, fuzzies, ledges, racePositions, infiniteStage, infiniteLedge)
    local player = self.data.playerModel
    local planet = self.data.planetSelected
    local game   = self.data.gameSelected
    local zone   = self.data.levelProgress[planet][game][zoneNumber]

    if zone then
        zone.plays     = zone.plays + 1
        zone.completed = true
        zone.playable  = true

        if zone.score and zone.score < levelScore then
            zone.score = levelScore
        end

        if zone.ranking and zone.ranking < ranking then
            zone.ranking = ranking
        end

        if zone.awards      == nil then zone.awards      = {} end
        if zone.fuzzies     == nil then zone.fuzzies     = {} end
        if zone.jumpScores  == nil then zone.jumpScores  = {} end
        if zone.completedAs == nil then zone.completedAs = {} end

        for _,award in pairs(awards) do
            if zone.awards[award.id] == nil then
                zone.awards[award.id] = award
            end
        end

        zone.numberAwards = 0
        for i in pairs(zone.awards) do
            zone.numberAwards = zone.numberAwards + 1
        end

        for key,data in pairs(fuzzies) do
            if zone.fuzzies[key] == nil then
                zone.fuzzies[key] = data
            end
        end

        for id,score in pairs(ledges) do
            if zone.jumpScores[id] == nil or zone.jumpScores[id] < score then
                zone.jumpScores[id] = score
            end
        end

        if zone.topStage == nil or zone.topStage < infiniteStage then
            zone.topStage = infiniteStage
        end

        if zone.topLedge == nil or zone.topLedge < infiniteLedge then
            zone.topLedge = infiniteLedge
        end

        -- Race - set completedAs to racePositions
        if game == gameTypeRace then
            zone.completedAs = racePositions
        -- Other - add current payer to list of zones completed as
        elseif table.indexOf(zone.completedAs, player) == nil then
            zone.completedAs[#zone.completedAs+1] = player
        end

        -- increment global score regardless of replaying a zone
        state.data.score = state.data.score + math.floor(levelScore / zone.plays)
    end
end


-- This is only called when completing a zone in story mode - to see what is unlocked
-- Returns the unlocked items as a list, for the end of level sequence
function state:completeZoneUnlockCheck(zoneNumber, gameUnlocks, friendlyCharacter)
    local unlocks           = {}
    local planet            = self.data.planetSelected
    local normalZones       = planetData[planet].normalZones
    local zonesCompleted    = self:numberZonesCompleted(planet, gameTypeStory)
    local allZonesCompleted = self:totalStoryZonesCompleted()

    -- 1. unlock next zone (unless this is the last normal in the planet)
    local nextZone = zoneNumber + 1

    if nextZone < normalZones and not self:zoneUnlocked(planet, nextZone) then
        self:unlockZone(planet, nextZone)
        unlocks[#unlocks+1] = {"zone", nextZone}
    end

    -- 2. check to unlock next planet
    if planet < #planetData then
        local nextPlanet = planet + 1

        if not self:planetUnlocked(nextPlanet) and zonesCompleted >= 5 then
            self:unlockPlanet(nextPlanet)
            unlocks[#unlocks+1] = {"planet", nextPlanet}
        end
    end

    -- 3. check to unlock gear: loop through from 1 just in-case there was a bug and one was not unlocked - otherwise it would never be unlockable
    for gear,rules in pairs(gearUnlocks) do
        if not rules.buyOnly and not self:gearUnlocked(gear) and allZonesCompleted >= rules.unlockAfter then
            self:unlockGear(gear)
            unlocks[#unlocks+1] = {"gear", gear}
        end
    end

    -- 4. check to unlock friendly character - ensure they have completed all normal zones and def the last normal zone
    if friendlyCharacter and not self:characterUnlocked(friendlyCharacter) and zonesCompleted >= normalZones and self:zoneUnlocked(planet, normalZones) then
        self:unlockCharacter(friendlyCharacter)
        unlocks[#unlocks+1] = {"character", friendlyCharacter}
    end

    -- 5. check to see if any challenge game modes have been unlocked
    local fuzzies = self:numberFuzziesCollected(planet)
    local ranking = self:planetStarRanking(planet, gameTypeStory)

    for game,_ in pairs(gameTypeData) do
        if not self:gameUnlocked(planet, game) then
            if challengeGameType[game] and fuzzies >= gameUnlocks[game].fuzzies then
                self:unlockGame(planet, game)
                unlocks[#unlocks+1] = {"game", game}

            elseif infiniteGameType[game] and ranking >= gameUnlocks[game].stars then
                self:unlockGame(planet, game)
                unlocks[#unlocks+1] = {"game", game}
            end
        end
    end

    return unlocks
end


-- when a player plays a race and fails to win, we still save the rae positions for the leaderboard scoring
function state:saveZoneFailedRace(zoneNumber, racePositions)
    local player = self.data.playerModel
    local planet = self.data.planetSelected
    local game   = self.data.gameSelected
    local zone   = self.data.levelProgress[planet][game][zoneNumber]

    if zone ~= nil then
        zone.completed   = false
        zone.score       = nil
        zone.ranking     = nil
        zone.awards      = nil
        zone.fuzzies     = nil
        zone.jumpScores  = nil
        zone.completedAs = racePositions
    end
end


function state:updateZoneRacePositions(zoneNumber, racePositions)
    local planet = self.data.planetSelected
    local game   = self.data.gameSelected
    local zone   = self.data.levelProgress[planet][game][zoneNumber]

    if zone ~= nil then
        zone.completedAs = racePositions
    end
end


---------- UNLOCK CHECKS ----------


-- Returns true if player has unlocked the character passed
function state:characterUnlocked(character)
    return (table.indexOf(self.data.unlocked.characters, character) ~= nil)
end


-- Returns true if player has unlocked the gear item passed
function state:gearUnlocked(gear)
    return (table.indexOf(self.data.unlocked.gear, gear) ~= nil)
end


-- Returns true if player has unlocked the planet passed
function state:planetUnlocked(planetNumber)
    return (self.data.unlocked.planets[planetNumber] ~= nil)
end


-- Returns true if player has unlocked the planet's zone passed
function state:zoneUnlocked(planetNumber, zoneNumber)
    if self:planetUnlocked(planetNumber) then
        return (table.indexOf(self.data.unlocked.planets[planetNumber].zones, zoneNumber) ~= nil)
    end
    return false
end


-- Returns true if player has unlocked the planet's game mode passed
function state:gameUnlocked(planetNumber, gameType)
    if self:planetUnlocked(planetNumber) then
        return (table.indexOf(self.data.unlocked.planets[planetNumber].games, gameType) ~= nil)
    end
    return false
end


---------- UNLOCK SOMETHING  ----------


-- unlocks a character (if not unlocked already) by adding them to the unlock list
function state:unlockCharacter(character)
    if characterData[character] and not self:characterUnlocked(character) then
        table.insert(self.data.unlocked.characters, character)
    end
end


-- unlocks a gear (if not unlocked already) by adding them to the unlock list
function state:unlockGear(gear)
    if gearSlots[gear] and not self:gearUnlocked(gear) then
        table.insert(self.data.unlocked.gear, gear)
    end
end


-- unlocks a new planet (if not unlocked already) by adding them to the unlock list
function state:unlockPlanet(planetNumber)
    if planetData[planetNumber] and planetNumber > 1 and not self:planetUnlocked(planetNumber) then
        self.data.unlocked.planets[planetNumber] = {
            zones = { 1 },
            games = { gameTypeStory }
        }
    end
end


-- Unlocks a zone for a planet
function state:unlockZone(planetNumber, zoneNumber)
    if zoneNumber > 0 and not self:zoneUnlocked(planetNumber, zoneNumber) then
        table.insert(self.data.unlocked.planets[planetNumber].zones, zoneNumber)
    end
end


-- Unlocks a game mode for a planet
function state:unlockGame(planetNumber, gameType)
    if gameTypeData[gameType] and not self:gameUnlocked(planetNumber, gameType) then
        table.insert(self.data.unlocked.planets[planetNumber].games, gameType)
    end
end


---------- MANAGE SAVE DATA ----------


-- This sets the game state to a new game, as if the player had never played before
-- This is called before any state:loadData() attempt to ensure the game is playable
function state:initialiseData()
    self.data.playerSkin     = "Green Space Man"
    self.data.playerModel    = characterNewton
    self.data.gameSelected   = gameTypeStory
    self.data.planetSelected = 1
    self.data.zoneSelected   = 0
    self.data.hudIcon        = "player_head_male"
    self.data.game           = nil
    self.data.score          = 0
    self.data.holocubes      = 0
    self.data.multiplayer    = false
    self.data.levelProgress  = {}
    self.data.storiesAcknowledged   = {}
    self.data.tutorialsAcknowledged = {}
    
    for i=1, #planetData do
        self:setupNewPlanet(i, planetData[i].normalZones + planetData[i].secretZones)
    end
end


-- creates the zone structure for a planet: if not locked then player can play the first zone, otherwise it needs unlocking
-- NOTE: this will cancel if planet zone data already exists, to avoid overwriting and losing player state
function state:setupNewPlanet(planetNumber, numberZones)
    if self.data.levelProgress[planetNumber] ~= nil then
        print("Warning: attempt to overwrite existing planet state")
        return
    end

    self.data.levelProgress[planetNumber] = {}

    for g=1, #gameTypeData do
        self.data.levelProgress[planetNumber][g] = {}

        for z=1, numberZones do
            local zone = {
                plays       = 0,
                completed   = false,
                jumpScore   = 0,
                timeScore   = 0,
                ranking     = 0,
                awards      = nil,
                fuzzies     = nil,
                jumpScores  = nil,
                completedAs = nil,
                topStage    = nil,
                topLedge    = nil,
            }

            self.data.levelProgress[planetNumber][g][z] = zone
        end
    end
end


-- Gets the full filename for the autosave file
function state:autoSaveFile()
    return system.pathForFile(self.autosave_filename, system.DocumentsDirectory)
end


-- Returns true if a saved game has been created, false if no game has been saved before
function state:checkForSavedGame()
    local filePath = self:autoSaveFile()

    -- filePath will be 'nil' if file doesn't exist and the path is 'system.ResourceDirectory'
    if filePath then filePath = io.open(filePath, "r") end

    if filePath then
        filePath:close()
        filePath = nil
        return true
    end

    return false
end


-- Saves the current self.data table into the autosave file replacing its current contents
function state:saveGame()
    local data = json.encode(self.data)
    local file = io.open(self:autoSaveFile(), "w")

    file:write(data)
    io.close(file)
    file = nil
end


-- Loads the autosave file and replaces self.data with the contents
function state:loadSavedGame()
    local file = io.open(self:autoSaveFile(), "r")
    local savedData = file:read("*a")

    if savedData then
        local decodedData = json.decode(savedData, 1, nil)
        -- TODO: validate
        if decodedData then
            self.data = decodedData
        end
    end

    io.close(file)
    file = nil
end


-- Resets the following:
--     1. level progress
--     2. context settings
--     3. global points, cubes
--     4. stories acknowledged
-- Leaves the following intact:
--     1. Everything that is unlocked (as cant imagine anyone would want to lose anything unlocked, plus some stuff has to be bought)
--     2. Player gear and negables    (as they could have bought these)
--     3. game settings
----
function state:resetSavedGame()
    -- mark that the saved game data is in this builds version
    self.data.buildVersion = globalBuildVersion
    -- rebuild structure for level progress and reset context settings (cubes, score, etc)
    self:initialiseData()
    -- save over the game (should we store the original so this can be undone?)
    self:saveGame()
end


-- Checks if the current save data format (on the device) is older than the code requires and tranforms or eraes it
function state:validateSavedGame()
    --[[if not self.data or self.data.buildVersion == nil or self.data.buildVersion ~= "0.7.2" then
        local saveVersion = "unknown"
        if self.data and self.data.buildVersion then saveVersion = self.data.buildVersion end

        print("Warning: saved game data version "..saveVersion.." is old version - replacing with new empty data")
        self:removeSavedGame()
        self:initialiseData()
        self:initialisePlayerGear()
        state:saveGame()
    else
        print("Validate save data: "..self.data.buildVersion)
    end]]
end


return state