package discord.tools;

// Basic Loop, uses Timer.delay and recursive functionality to call itself each tick, useful to update junge timer pool and etc
class Loop
{
    private static var _started:Bool = false;

    private static function tick()
    {
        if (!_started)
            return;

        haxe.Timer.delay(() ->
        {
            // Provide built in support for linc_discord-rpc
            #if !html5

            #if discord_rpc
            discord_rpc.DiscordRpc.process();
            #else
            @:privateAccess
            {
                if (Gateway.gateway.readyState != Closing || Gateway.gateway.readyState != Closed)
                    Gateway.gateway.process();
            }
            #end

            #end
            junge.Timer.updateDefaultPool(haxe.Timer.stamp());
            tick();
        }, 1);
    }

    // Starts the tick loop to update junge timer pool
    public static function start()
    {
        if (_started)
            return;

        #if GATEWAY_LOOP_DEBUG
        trace("Starting loop");
        #end
        _started = true;
        tick();
    }

    // Stops the loop
    public static function stop()
    {
        if (!_started)
            return;

        #if GATEWAY_LOOP_DEBUG
        trace("Stopping loop");
        #end

        // Clean the timers pool
        for (_ in junge.Timer.defaultPool.data)
        {
            junge.Timer.defaultPool.dequeue();
        }

        _started = false;
    }

    // Junge timers use seconds instead of milliseconds
    public static function toMS(s:Int):Float
        return (s / 1000);
}