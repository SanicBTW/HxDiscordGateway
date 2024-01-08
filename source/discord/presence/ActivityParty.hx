package discord.presence;

typedef ActivityParty =
{
    /**
     * ID of the party
     */
    @:optional var id:String;

    /**
     * Used to show the party's current and maximum size
     * 
     * array of two integers (current_size, max_size)
     */
    @:optional var size:Array<Int>;
}