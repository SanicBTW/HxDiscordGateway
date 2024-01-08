package discord.presence;

typedef ActivitySecrets = 
{
    /**
     * Secret for joining a party
     */
    @:optional var join:String;

    /**
     * Secret for spectating a game
     */
    @:optional var spectate:String;

    /**
     * Secret for a specific instanced match
     */
    @:optional var match:String;
}