package discord;

import junge.Timer;
import discord.gateway.Payload;
import discord.presence.*;
import discord.gateway.RPCAsset;
import haxe.ds.DynamicMap;

// TODO: append the current activity to the visible ones on the user
// a queue that clears every 4 seconds (20 / 5 = 4 seconds we can last without sending an update to the presence)
@:allow(discord.Gateway)
@:allow(discord.presence.PresenceBuilder)
class Presence
{
    // Flag set by the Gateway to tell the Presence Manager that it can Send Updates to the User Presence
    private static var _canSend:Bool = false;

    // Activity management

    // Saves the last activity object sent to the Gateway, so it can be sent again after resuming the connection
    private static var _lastActivity:ActivityObject;

    // Asset caching

    // So apparently, changing the assets through the Gateway require the asset ID than the asset Name so we just caching it
    private static var assets:DynamicMap<String, RPCAsset> = new DynamicMap();

    // Saves the images endpoints, ex: https://cdn.discordapp.com/app-assets/1089328716154404885/1133112292276449312.png
    private static var assetURLS:DynamicMap<String, String> = new DynamicMap();

    private static function resumed()
    {
        // Send the last presence
        sendPresence(_lastActivity);
    }

    private static function sendPresence(activity:ActivityObject)
    {
        if (!_canSend)
            return;

        var payload:Payload = 
        {
            op: PRESENCE_UPDATE,
            d:
            {
                since: null,
                activities: [activity],
                status: "dnd",
                afk: false
            }
        };

        Gateway.send(payload.toString());

        _lastActivity = activity;
    }
}