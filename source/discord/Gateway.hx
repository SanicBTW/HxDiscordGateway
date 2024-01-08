package discord;

import discord.gateway.*;
import discord.gateway.Payload;
import discord.tools.Loop;
import haxe.Json;
import haxe.ds.DynamicMap;
import haxe.net.WebSocket;
import junge.Timer;

// TODO: Order variables
@:allow(discord.Presence)
class Gateway
{
    // Used to connect to the Gateway
    private static var gateway:WebSocket;

    // To avoid connecting to the gateway again by accident
    private static var Initialized:Bool = false;

    // Callbacks store
    private static var _options:StartOptions;

    // Keep-Alive
    private static var heartRate:Int = 0; // MS

    // Resuming (HTML5)
    #if html5
    private static var blacklistedErrors:Array<Int> = [4004, 4010, 4011, 4012, 4013, 4014];
    #end

    // For saving data without making a bunch of variables
    private static var _cache:DynamicMap<String, String> = new DynamicMap();

    public static function Initialize(options:StartOptions)
    {
        if (Initialized)
            return;

        #if sys
        // This pretty much fixes everything related to secure connections lmfao
		// https://github.com/yupswing/akifox-asynchttp/issues/43#issuecomment-343213637
		sys.ssl.Socket.DEFAULT_VERIFY_CERT = false;
        #end

        // Start the loop before creating the Gateway
        Loop.start();

        // Save them callbacks for other functions
        _options = options;

        // Preload assets from the RPC Application
        Endpoint.make(Endpoint.OAUTH2, _options.applicationID,
        (data) -> 
        {
            var netAssets:Array<RPCAsset> = cast data;
            for (asset in netAssets)
            {
                Presence.assets[asset.name] = asset;
                Presence.assetURLS[asset.name] = '${Endpoint.APP_ASSETS}${_options.applicationID}/${asset.id}.png';
            }
        },
        (err, url) -> 
        {
            #if GATEWAY_DEBUG
            trace("Failed to preload RPC Application assets: " + err + ' ($url)');
            #end
        }, null, "assets");

        gateway = WebSocket.create("wss://gateway.discord.gg/?v=10&encoding=json");
        addListeners();
    }

    // Fully closes the Gateway connection and clears all the cache
    public static function Shutdown()
    {
        _cache.clear();
        Presence.assets.clear();
        Presence.assetURLS.clear();

        _cache["noResume"] = "";

        gateway.close();
    }

    // Login to the Gateway
    private static function identify()
    {
        var userToken:String = _cache["token"];
        // Only run if the token is null or not matching the minimun length (variable already stores the value so no need to re-enter the token)
        if (userToken == null || userToken.length < 17)
            _cache["token"] = userToken = _options.onTokenRequest();

        var payload:IdentifyPayload = new IdentifyPayload(userToken);

        // Another check, if the provided token is still null or doesn't match the length close the connection
        if (userToken == null || userToken.length < 17)
        {
            gateway.close();
            if (_options.onDisconnected != null)
                _options.onDisconnected("Invalid token");
            return;
        }

        // Can't access https://discord.com/api/v10/applications/ no more even with the auth token, Discord pls fix this

        send(payload.toString());
    }

    // Keep-Alive
    private static function heartbeat()
    {
        var payload:HeartbeatPayload = new HeartbeatPayload(Std.parseInt(_cache["lastSeq"]));

        if (gateway.readyState == Closing || gateway.readyState == Closed)
        {
            #if GATEWAY_DEBUG
            trace('Failed to HeartBeat: Gateway is closed!');
            #end
            Loop.stop();
            return;
        }

        send(payload.toString());
    }

    // Reconnect / Resume the connection to the gateway in case we get disconnected from it
    private static function reconnect()
    {
        #if GATEWAY_DEBUG
        trace('Trying to reconnect to ${_cache["resumeURL"]}');
        #end

        // Re-run the loop
        Loop.start();

        gateway = WebSocket.create('${_cache["resumeURL"]}/?v=10&encoding=json');
        addListeners();

        Presence._canSend = true;
        Presence.resumed();

        if (_options.onResume != null)
            _options.onResume();
    }

    // Try reconnecting to the gateway
    private static function tryReconnection(?e:Dynamic)
    {
        try 
        {
            #if html5
            // On HTML5 the argument is a CloseEvent 
            var e:js.html.CloseEvent = cast e;
    
            // run if it isnt blacklisted or if the exit was NOT clean
            if (!blacklistedErrors.contains(e.code) || !e.wasClean)
            {
                // re-initialize the gateway if the resume gateway url is null
                if (_cache["resumeURL"] == null)
                    Gateway.Initialize(_options);
                else
                    reconnect(); // try reconncting
            }
            #else
    
            #if GATEWAY_DEBUG
            trace(e);
            #end
    
            // seems like if e aint null then something bad happened internally
            if (e != null)
                return;
    
            // e is still unknown on other targets so we just going to ignore it lol
            if (_cache["resumeURL"] == null)
                Gateway.Initialize(_options);
            else
                reconnect(); // try reconncting
            #end
        }
        catch (ex)
        {
            #if GATEWAY_DEBUG
            trace(ex);
            trace("Cannot reconnect");
            Shutdown();
            #end
        }
    }

    // This should be executed everytime the gateway is re-assigned
    private static function addListeners()
    {
        #if GATEWAY_DEBUG
        trace("Adding listeners to the new WebSocket client");
        #end

        // Listeners for start options
        gateway.onopen = () ->
        {
            Initialized = true;
            if (_options.onConnected != null)
                _options.onConnected();
        }

        gateway.onerror = (msg:String) ->
        {
            // We CANNOT recover from this
            if (_options.onError != null)
                _options.onError(msg);
        }

        gateway.onclose = (?e:Dynamic) ->
        {
            Loop.stop();
            Initialized = Presence._canSend = false;

            if (_options.onDisconnected != null)
                _options.onDisconnected(e);

            // Force close the client just in case
            gateway.close();

            // Quick flag
            if (_cache["noResume"] != null)
                return;

            tryReconnection(e);
        }

        // Listen to messages
        gateway.onmessageString = (msg:String) ->
        {
            final json:Dynamic = Json.parse(msg);

            final data:Payload =
            {
                op: json.op,
                d: json.d,
                s: json.s,
                t: json.t
            };

            switch(data.op)
            {
                case HELLO:
                    if (_cache["resumeURL"] == null)
                        identify();
                    else
                    {
                        #if GATEWAY_DEBUG
                        trace("Trying to reconnect from previous session");
                        #end
                        var payload:ResumePayload = new ResumePayload(_cache["token"], _cache["sessionID"], Std.parseInt(_cache["lastSeq"]));
                        send(payload.toString());
                    }

                    heartRate = data.d.heartbeat_interval;
                    heartbeat();
                    Timer.dcall((_) ->
                    {
                        #if GATEWAY_LOOP_DEBUG
                        trace("Heartbeat!");
                        #end
                        heartbeat();
                    }, Loop.toMS(heartRate - 10), -1);

                case HEARTBEAT_ACK:
                    // the reason we set this into GATEWAY_LOOP_DEBUG is cuz its related to timer and shit
                    #if GATEWAY_LOOP_DEBUG
                    trace('ack!');
                    #end

                case INVALID_SESSION:
                    // Look into this properly
                    // Because we have some cache we can straight up call the identify function, this only happens when trying to resume the previous session so we shouln't have a problem now
                    #if GATEWAY_DEBUG
                    trace("Re-identifying due to invalid session, probably thrown by the resume handler");
                    #end
                    identify();

                case RECONNECT:
                    #if GATEWAY_DEBUG
                    trace("Gateway wants to reconnect, trying to reconnect");
                    #end
                    tryReconnection();

                case DISPATCH:
                    // apparently i only need to set the seq on this type of opcode
                    _cache["lastSeq"] = Std.string(data.s);

                    switch (data.t) // t is the event, i should make an enum for it but there isnt a page for them and we only choosing some events
                    {
                        case "READY":
                            _cache["sessionID"] = data.d.session_id;
                            _cache["resumeURL"] = data.d.resume_gateway_url;

                            Presence._canSend = true;

                            if (_options.onReady != null)
                                _options.onReady();

                        default:
                            return;
                    }

                default:
                    trace(data);
                    return;
            }
        }
    }

    private static function send(data:String)
    {
        if (!Initialized)
            return;

        gateway.sendString(data);
    }
}