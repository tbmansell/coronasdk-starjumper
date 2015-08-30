/**
 * NoobHub node.js server
 * Opensource multiplayer and network messaging for CoronaSDK, Moai, Gideros & LÖVE
 *
 * @usage node node.js
 * configure port number and buffer size
 * according to your needs
 *
 * @authors
 * Igor Korsakov
 * Sergii Tsegelnyk
 *
 * @license WTFPL
 * https://github.com/Overtorment/NoobHub
 */

var server = require('net').createServer()
    , sockets = {}  // this is where we store all current client socket connections
    , cfg = {
        port: 1337,
        buffer_size: 1024*8, // buffer is allocated per each socket client
        verbose: true
    }
    , _log = function(){
        if (cfg.verbose) console.log.apply(console, arguments);
    };

var playerNames = [];
var playerCount = 0;

// black magic
process.on('uncaughtException', function(err){
    _log('Exception: ' + err);
});


// Get a socket from the connection pool
function getSocket(channel, playerName) {
    for (var prop in sockets[channel]) {
        if (sockets[channel].hasOwnProperty(prop) && sockets[channel][prop].playerName == playerName) {
            return sockets[channel][prop];
        }
    }
}


// write this message to all sockets with the same channel
function broadcast(channel, json) {
    _log("broadcasting: "+json);

    for (var prop in sockets[channel]) {
        if (sockets[channel].hasOwnProperty(prop)) {
            sockets[channel][prop].write("__JSON__START__" + json + "__JSON__END__");
        }
    }
}


// write a message to a single socket
/*function signal(socket, action, data) {
    socket.write('__JSON__START__{"id":"08e94e96f1444001c97e4035124fbdaf", "timestamp":100, "action":"'+action+'", "data":"'+data+'"}__JSON__END__');
}*/


// write a message to a single socket
function signalJson(socket, receiver, json) {
    _log('signalling '+receiver+': '+json);

    socket.write("__JSON__START__" + json + "__JSON__END__");
}


function signalSubscriptionList() {
    // Build subscribers list (CSV)
    var subscribers = "";
    for (var prop in sockets[socket.channel]) {
        if (sockets[socket.channel].hasOwnProperty(prop)) {
            var curSocket = sockets[socket.channel][prop];

            if (curSocket.connection_id != socket.connection_id) {
                if (subscribers.length>0) subscribers += ',';
                subscribers += curSocket.connection_id;
            }
        }
    }

    // reply to subscriber with subscription list
    signal(socket, "subscribers", subscribers);
}



server.on('connection', function(socket) {
    socket.setNoDelay(true);
    socket.connection_id = require('crypto').createHash('sha1').update( 'noobhub'  + Date.now() + Math.random() ).digest('hex') ; // unique sha1 hash generation
    socket.channel = '';
    socket.buffer = new Buffer(cfg.buffer_size);
    socket.buffer.len = 0; // due to Buffer's nature we have to keep track of buffer contents ourself

    _log('New client: ' + socket.remoteAddress +':'+ socket.remotePort);

    socket.on('data', function(data_raw) { // data_raw is an instance of Buffer as well
        if (data_raw.length > (cfg.buffer_size - socket.buffer.len)) {
            _log("Message doesn't fit the buffer. Adjust the buffer size in configuration");
            socket.buffer.len = 0; // trimming buffer
            return false;
        }

        socket.buffer.len +=  data_raw.copy(socket.buffer, socket.buffer.len); // keeping track of how much data we have in buffer

        var str, start, end, conn_id = socket.connection_id;
        str = socket.buffer.slice(0,socket.buffer.len).toString();

        if ( (start = str.indexOf("__SUBSCRIBE__")) !=  -1   &&   (end = str.indexOf("__ENDSUBSCRIBE__"))  !=  -1) {
            socket.channel = str.substr( start+13,  end-(start+13) );
            socket.write('Hello. Noobhub online. \r\n');
            _log("Client subscribes for channel: " + socket.channel);

            str = str.substr(end + 16);  // cut the message and remove the precedant part of the buffer since it can't be processed
            socket.buffer.len = socket.buffer.write(str, 0);
            sockets[socket.channel] = sockets[socket.channel] || {}; // hashmap of sockets  subscribed to the same channel
            sockets[socket.channel][conn_id] = socket;

            playerCount++;
            socket.playerName = 'Player '+playerCount;
            playerNames[conn_id] = socket.playerName;
        }

        var time_to_exit = true;
        do{  // this is for a case when several messages arrived in buffer
            if ( (start = str.indexOf("__JSON__START__")) !=  -1   &&  (end = str.indexOf("__JSON__END__"))  !=  -1 ) {
                var json       = str.substr( start+15,  end-(start+15) );
                var message    = JSON.parse(json);
                var messageId  = message['id'];
                var timestamp  = message['timestamp'];
                var action     = message['action'];
                var receiver   = message['receiver'];
                var playerName = socket.playerName;

                //_log("Client "+conn_id+" posts json:  " + json);
                _log(playerName+': action='+action+' receiver='+receiver);

                str = str.substr(end + 13);  // cut the message and remove the precedant part of the buffer since it can't be processed
                socket.buffer.len = socket.buffer.write(str, 0);

                // BROADCAST: New subscriber
                if (action == "game-start") {
                    // When subscribing, announce to everyone and receive a list of current subscribers (excluding self)
                    broadcast(socket.channel, '{"id":"'+messageId+'", "timestamp":'+timestamp+', "action":"subscribed", "data":"'+playerName+'"}');
                }
                // Private Message Forwarders:
                else if (receiver) {
                    // Forward request to another specific client to play
                    var notice = '{"id":"'+messageId+'", "timestamp":'+timestamp+', "action":"'+action+'", "data":"'+message["data"]+'", "from":"'+playerName+'"}';

                    signalJson(getSocket(socket.channel, receiver), receiver, notice);
                }

                time_to_exit = false;
            } else {  time_to_exit = true; } // if no json data found in buffer - then it is time to exit this loop
        } while ( !time_to_exit );
    }); // end of  socket.on 'data'

    socket.on('close', function(){  // we need to cut out closed socket from array of client socket connections
        if  (!socket.channel   ||   !sockets[socket.channel])  return;
        delete sockets[socket.channel][socket.connection_id];
        _log(socket.connection_id + " has been disconnected from channel " + socket.channel);

        broadcast(socket.channel, '{"id":"0", "timestamp":0, "action":"unsubscribed", "data":"'+socket.playerName+'"}');
    }); // end of socket.on 'close'

}); //  end of server.on 'connection'

server.on('listening', function(){ console.log('NoobHub on ' + server.address().address +':'+ server.address().port); });
server.listen(cfg.port);