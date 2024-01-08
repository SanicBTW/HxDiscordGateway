package discord.presence;

typedef ActivityTimestamps = 
{
    /**
     * Unix time (in milliseconds) of when the activity started
     */
    @:optional var start:Int;

    /**
     * Unix time (in milliseconds) of when the activity ends
     */
    @:optional var end:Int;
}