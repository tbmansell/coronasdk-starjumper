crypto = require("crypto")

require("networking.net-hud")
require("networking.noobhub")


hubLoader = {}

function hubLoader:createHub()

    hub = noobhub.new({ server="92.234.12.41"; port=1337; });

    hub.subscribedMessageId = nil
    hub.playerName          = nil
    hub.opponent            = nil
    hub.otherConnections    = {}


    function hub:split(s, delimiter)
        result = {};
        for match in (s..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match);
        end
        return result;
    end


    function hub:createPublicMessage(action, data)
        local id = crypto.digest(crypto.md5, system.getTimer() .. math.random())

        if action == "game-start" then
            self.subscribedMessageId = id
        end

        return {
            message = {
                action    = action,
                data      = data,
                id        = id,
                timestamp = system.getTimer()
            }
        }
    end


    function hub:createPrivateMessage(action, data, client)
        return {
            message = {
                action     = action,
                data       = data,
                receiver   = client,
                id         = crypto.digest(crypto.md5, system.getTimer() .. math.random()),
                timestamp  = system.getTimer()
            }
        }
    end


    function hub:publicMessage(action, data)
        self:publish(self:createPublicMessage(action, data))
    end


    function hub:privateMessage(action, data, clientId)
        local otherId = clientId or hub.opponent

        if otherId then
            self:publish(self:createPrivateMessage(action, data, otherId))
        end
    end


    function hub:print(message)
        --print("message received  = "..json.encode(message));
        local msg = "Message: action="..message.action.." data="..message.data

        if message.sender ~= nil then
            msg = msg.." sender="..message.sender
        end

        print(msg)
    end


    function hub:join()
        self:subscribe({
            channel = "ping-channel";

            callback = function(message)
                local action = message.action
                local data   = message.data
                local sender = message.from
                local lag    = math.abs(system.getTimer() - message.timestamp)

                hub:print(message)

                if action == "subscribed" then
                    -- check if this was clients own subscribed message by matching message ids
                    if message.id == hub.subscribedMessageId then
                        hub.playerName = data
                        netHud:status("I am "..hub.playerName)
                    else
                        netHud:status(data.." connected")
                        table.insert(hub.otherConnections, data)

                        if not hub.opponent then
                            -- If not currently linked to a player, then try to connect to them
                            netHud:status("Sending play request to "..data)
                            hub:privateMessage("play-request", "act1:scene1", data)
                        end
                    end

                elseif action == "unsubscribed" then
                    if data == hub.opponent then
                        hub.opponent = nil
                        removeRemotePlayer()
                        netHud:status(data.." disconnected, now playing alone")
                    else
                        netHud:status(data.." disconnected")
                    end

                elseif action == "subscribers" then
                    -- split string and aod each client id into otherConnections

                elseif action == "play-request" then
                    if not hub.opponent then
                        -- send confirmation
                        netHud:status("Accepted Play request from "..sender.." data="..data)
                        hub.opponent = sender
                        hub:privateMessage("play-accepted")
                        -- load other player into level:
                        remotePlayerConnected()
                    else
                        netHud:status("Rejected Play request from "..sender)
                    end

                elseif action == "play-accepted" then
                    hub.opponent = sender
                    netHud:status("Play request accepted by "..sender)
                    -- load other player into level:
                    remotePlayerConnected()
                    -- Now update the new other player as to where I am since I'm already in the level
                    player:positionNotify()
                    player:setGearNotify()

                elseif action == "player-position" then
                    netHud:status(sender.." new position: "..data..", "..lag)
                    local ledgeId, x, direction = nil, nil, nil

                    for i,v in pairs(self:split(data,"&")) do
                        local pos1, pos2 = string.find(v,"=")
                        local key,  val  = string.sub(v, 1, pos1-1), string.sub(v, pos2+1)

                        if key == "ledge" then ledgeId   = tonumber(val) end
                        if key == "x"     then x         = tonumber(val) end
                        if key == "dir"   then direction = tonumber(val) end
                    end

                    if ledgeId ~= nil --[[and xoffset ~= nil]] and direction ~= nil then
                        positionRemotePlayer(ledgeId, x, direction)
                    end

                elseif action == "player-gear" then
                    netHud:status(sender.." set gear: "..data..", "..lag)
                    local gear = {}

                    for i,v in pairs(self:split(data,"&")) do
                        local pos1, pos2 = string.find(v,"=")
                        local key,  val  = string.sub(v, 1, pos1-1), string.sub(v, pos2+1)

                        if val == "0" then val = nil end
                        gear[tonumber(key)] = val

                    end

                    remotePlayer:setGear(gear)

                elseif action == "player-walk" then
                    netHud:status(sender.." walked: "..data..", "..lag)
                    local xpos = nil

                    for i,v in pairs(self:split(data,"&")) do
                        local pos1, pos2 = string.find(v,"=")
                        local key,  val  = string.sub(v, 1, pos1-1), string.sub(v, pos2+1)

                        if key == "x" then xpos = tonumber(val) end
                    end

                    if xpos ~= nil then
                        remotePlayer:moveOnLedge(xpos)
                    end                    

                elseif action == "player-readyJump" then
                    netHud:status(sender.." readyJump: "..data..", "..lag)
                    remotePlayer:readyJump()

                elseif action == "player-cancelJump" then
                    netHud:status(sender.." cancelJump: "..data..", "..lag)
                    remotePlayer:cancelJump()

                elseif action == "player-direction" then
                    netHud:status(sender.." direction: "..data..", "..lag)
                    local direction = nil

                    for i,v in pairs(self:split(data,"&")) do
                        local pos1, pos2 = string.find(v,"=")
                        local key,  val  = string.sub(v, 1, pos1-1), string.sub(v, pos2+1)

                        if key == "dir" then direction = tonumber(val) end
                    end

                    if direction == left or direction == right then
                        remotePlayer:changeDirection(direction)
                    end 

                elseif action == "player-jump" then
                    --hub:privateMessage("player-jump", "ledge="..self.attachedLedge.id..",xvel="..self.xVelocity..",yvel="..self.yVelocity)
                    netHud:status(sender.." jumped: "..data..", "..lag)
                    local xvel, yvel = nil, nil

                    for i,v in pairs(self:split(data,"&")) do
                        local pos1, pos2 = string.find(v,"=")
                        local key,  val  = string.sub(v, 1, pos1-1), string.sub(v, pos2+1)

                        if     key == "xvel" then xvel = tonumber(val)
                        elseif key == "yvel" then yvel = tonumber(val) end
                    end

                    if xvel ~= nil and yvel ~= nil then
                        remotePlayer:runup(xvel, yvel)
                    end

                end

            end;
        })
    end


    return hub
end



--[[if (message.action == "ping")   then
    print ("pong sent");
    hub:publish({
        message = {
            action  =  "pong",
            id = message.id,
            original_timestamp = message.timestamp,
            timestamp = system.getTimer()
        }
    });
end;

if (message.action == "pong"  )   then
    print ("pong id "..message.id.." received on "..system.getTimer().."; summary:   latency=" .. (system.getTimer() - message.original_timestamp)   );
    table.insert( latencies,  ( (system.getTimer() - message.original_timestamp)   )     );

    local sum = 0;
    local count = 0;
    for i,lat in ipairs(latencies) do
        sum = sum + lat;
        count =  count+1;
    end

    print("---------- "..count..') average =  '..(sum/count)  );
end;]]

--[[timer.performWithDelay( 5000, function()
    print("ping sent");
    hub:publish({
        message = {
            action  =  "ping",
            id = crypto.digest( crypto.md5, system.getTimer()  ..  math.random()   ),
            timestamp = system.getTimer()
        }
    });
end, 0 );]]
