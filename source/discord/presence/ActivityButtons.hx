package discord.presence;

typedef ActivityButtons = 
{
    /**
     * Text shown on the button (1-32 characters)
     */
    var label:String;

    /**
     * URL opened when clicking the button (1-512 characters)
     */
    var url:String;
}