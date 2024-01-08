package discord.presence;

typedef ActivityEmoji = 
{
    /**
     * Name of the emoji
     */
    var name:String;

    /**
     * ID of the emoji
     */
    @:optional var id:String; // Snowflake

    /**
     * Whether the emoji is animated
     */
    @:optional var animated:Bool;
}