# HxDiscordGateway

Library to communicate with the Discord Gateway through WebSockets.

---

This library only works on the following targets:
```
C++: HXCPP_M64 may break the connection (only happens on SSL)
HTML5
HahsLink
Android: Not tested but most likely to work
```

---

## Installation
```
haxelib install HxDiscordGateway
```

or with git for the latest potentially unstable updates.

```
haxelib git HxDiscordGateway https://github.com/SanicBTW/HxDiscordGateway.git
```

## Usage

First you must meet some requirements:
- You must need the RPC Application ID and Name
- YOUR Discord User Token (Without this you can't authenticate in the Gateway!)

If you already meet these requirements, you can install the library and import it.

### Initialization

To connect to the Gateway you must call `Gateway.Initialize`

And the function requires some important arguments:
```
applicationID:String => The ID of the RPC Application.

applicationName:String => The name of the RPC Application (now requied due to changes to the Discord API).

onTokenRequest:Void->String => This function gets called when the client tries to authenticate on the Gateway, the user must return a string.
```

Here is a useful snippet

```haxe
import discord.Gateway;

Gateway.Initialize({
    applicationID: "YOUR_APP_ID",
    applicationName: "YOUR_APP_NAME",
    onTokenRequest: () -> { return "YOUR_TOKEN"; }
});
```

In case you want to make it dynamic for the user on HTML5 you can do this:

```haxe
Gateway.Initialize({
    applicationID: "YOUR_APP_ID",
    applicationName: "YOUR_APP_NAME",
    onTokenRequest: () -> { return js.Browser.window.prompt("Please input your Discord Account Token"); }
});
```

It might seem sketchy for the user but it's optional anyways, when the token test fails, it won't continue asking for the token.

You have some more callbacks when initializing the Gateway, useful for states and stuff, you choose!

Note: When initializing the connection to the Gateway, the code makes a request to the Discord API to fetch the RPC Application assets, thats why the ID is required.

### Updating the presence

Once you've authenticated in the Gateway, you are ready to send presences.

I wanted to replicate the Discord.js API a little bit so making presences have never been easier than this:

```haxe
import discord.presence.PresenceBuilder;

new PresenceBuilder()
    .addDetails("Hello")
    .addState("world!")
    .send();
```

Easy like that, behind the scenes there isn't much happening, just adding data to an object and when calling `send();` it sends the freshly built presence into the Gateway.

Of course you have more functions to add data in but some of them are broken for now, on later versions they will be fixed.

### Caveats

However, there's always issues.

As mentioned before `HXCPP_M64` flag makes the colyseus-websocket (the websocket backend) to crash when trying to allocate 1MB of memory.

Rate limits, *sigh this one sucks*, Discord Docs say that the client must only send 5 presence updates per 20 seconds, there's nothing I can do about that.

### Debugging

The library provides internal flags for debugging different parts of the library:
- GATEWAY_LOOP_DEBUG: Prints info about the Loop process.
- GATEWAY_DEBUG: Prints info about the websocket client.

## Finishing

That's pretty much everything you have to know about this library, the purpose of this library is just to update the user presence, if you want to make a Discord Bot with haxe, check [hxdiscord](https://github.com/FurretDev/hxdiscord).

You don't have to worry about draining data or anything, the library does that by itself, by using `junge` and calling `haxe.Timer.delay` recursively it creates a loop that runs every ms or every tick and processes the data alongside some other stuff.

If you want to use this with [linc_discord-rpc](https://github.com/Aidan63/linc_discord-rpc) the only thing that's implemented is the processing and in future updates it will be possible to use the PresenceBuilder with it too.

I'm trying to improve the code every update, feel free to contribute anytime!

## Licensing
`HxDiscordGateway` is made available via the [MIT](https://github.com/SanicBTW/HxDiscordGateway/blob/master/LICENSE) license