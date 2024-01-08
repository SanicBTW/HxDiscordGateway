package discord.presence;

import discord.presence.*;

typedef ActivityObject =
{
    /**
     * Activity's name
     */
    var name:String;

    /**
     * Activity type.
     */
    var type:ActivityType;

    /**
     * Stream URL, is validated when type is 1.
     */
    @:optional var url:String;

    /**
     * Unix timestamp (in milliseconds) of when the activity was added to the user's session
     */
    var created_at:Int;

    /**
     * Unix timestamps for start and/or end of the game
     */
    @:optional var timestamps:ActivityTimestamps;

    /**
     * Application ID for the game
     */
    @:optional var application_id:String; // Snowflake

    /**
     * What the player is currently doing
     */
    @:optional var details:String;

    /**
     * User's current party status, or text used for a custom status
     */
    @:optional var state:String;

    /**
     * Emoji used for a custom status
     */
    @:optional var emoji:ActivityEmoji;

    /**
     * Information for the current party of the player
     */
    @:optional var party:ActivityParty;

    /**
     * Images for the presence and their hover texts
     */
    @:optional var assets:ActivityAssets;

    /**
     * Secrets for Rich Presence joining and spectating
     */
    @:optional var secrets:ActivitySecrets;

    /**
     * Whether or not the activity is an instanced game session
     */
    @:optional var instance:Bool;

    /**
     * Activity flags OR d together, describes what the payload includes
     */
    @:optional var flags:ActivityFlags;

    /**
     * Custom buttons shown in the Rich Presence (max 2)
     */
    @:optional var buttons:Array<ActivityButtons>;
}