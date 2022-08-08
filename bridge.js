const PORT = 9240;

const { WebSocketServer } = require('ws');

const wss = new WebSocketServer({ port: PORT });

console.log("CompanionBridge started as: ", PORT);

wss.tally = [undefined, undefined];

function heartbeat() {
    console.log("heartbeat for", this.ip);
    this.isAlive = true;
}

function toJson(str) {
    try {
        var json = JSON.parse(str.toString('utf8'));
    } catch (e) {
        var json = str.toString('utf8');
    }
    return json;
    //return { "message": json };
}

function asString(json) {
    if (!json) {
        return 'BAD MESSAGE';
    }
    return json;
    return JSON.stringify(json).trim();
}
wss.on('open', function message(data) {
    console.log('received: %s', data);
});

wss.on('connection', function connection(ws, req) {
    //
    ws.isAlive = true;
    ws.on('pong', heartbeat);
    //
    ws.ip = req.socket.remoteAddress;

    ws.client_uuid = req.headers['sec-websocket-key'];

    ws.on('message', function message(data) {

        //JOIN MESSAGES
        data = data.toString().trim();

        if (data.includes("JOIN ")) {
            ws.client_hostname = data.split(' ')[1];
            data = "JOINED " + ws.client_hostname;
        }

        return multicast(wss, ws, data);
    });
});

async function broadcast(wss, data) {
    console.log('Broadcasting: ', data);
    wss.clients.forEach(function each(client) {
        if (client.readyState === 1) {
            client.send(asString(data), false);
        }
    });
}

async function multicast(wss, ws, data) {
    console.log('Broadcasting: ', data);
    wss.clients.forEach(function each(client) {
        if (client !== ws && client.readyState === 1) {
            client.send(asString(data), false);
        }
    });
}

const interval = setInterval(function ping() {
    wss.clients.forEach(function each(ws) {
        if (ws.isAlive === false) return ws.terminate();

        ws.isAlive = false;
        ws.ping();
    });
}, 15000);

wss.on('close', function close() {
    clearInterval(interval);
});