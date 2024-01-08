package discord.presence;

/**
 * Used to build `Activity Objects` with syntactic sugar
 *
 * Some fields may break the whole Activity Object for the presence for some reason
 *
 * It will be fixed in later versions
 */
class PresenceBuilder
{
    private var _activity:ActivityObject;

    public function new(type:ActivityType = GAME)
    {
        @:privateAccess
        // Forced to use the given name through start options or use the default one, this might change on later updates
        var actName:String = Gateway._options != null ? Gateway._options.applicationName : "HxDiscordGateway";
        
        @:privateAccess
        // Forced to use the given id through start options or use the default one, this might change on later updates
        var actID:String = Gateway._options != null ? Gateway._options.applicationID : "1193103722021126195";

        _activity = 
        {
            name: actName,
            application_id: actID,
            created_at: Std.int(Date.now().getTime() / 1000),
            type: type
        };
    }

    /**
     * Stream URL, is validated when type is STREAMING.
     */
    public function addURL(url:String):PresenceBuilder
    {
        if (_activity.type == STREAMING)
            _activity.url = url;

        return this;
    }

    /**
     * Unix timestamps for start and/or end of the game
     */
    public function addTimestamps(startTime:Float = 0, endTime:Float = 0):PresenceBuilder
    {
        _activity.timestamps =
        {
            start: (startTime > 0) ? Std.int(startTime / 1000) : null,
            end: (endTime > 0) ? Std.int(endTime / 1000) : null
        };

        return this;
    }

    /**
     * What the player is currently doing
     */
    public function addDetails(details:String):PresenceBuilder
    {
        _activity.details = details;

        return this;
    }

    /**
     * User's current party status, or text used for a custom status
     */
    public function addState(state:String):PresenceBuilder
    {
        _activity.state = state;

        return this;
    }

    // Usually only name is needed
    /**
     * Emoji used for a custom status
     */
    public function addEmoji(name:String, ?id:String, ?animated:Bool):PresenceBuilder
    {
        if (_activity.type == CUSTOM)
        {
            _activity.emoji =
            {
                name: name,
                id: id,
                animated: animated
            };
        }

        return this;
    }

    /**
     * Information for the current party of the player
     */
    public function setParty(id:String, currentSize:Int, maxSize:Int):PresenceBuilder
    {
        _activity.party =
        {
            id: id,
            size: [currentSize, maxSize]
        };

        return this;
    }

    /**
     * The large image for the presence and its hover text
     *
     * Must be called before `addSmallAsset`
     */
    public function addLargeAsset(?image:String, ?text:String):PresenceBuilder
    {
        _activity.assets =
        {
            large_image: (image != null && Presence.assets.exists(image)) ? Presence.assets[image].id : null,
            large_text: (text != null && text.length > 1) ? text : null
        }

        return this;
    }

    /**
     * The small image for the presence and its hover text
     *
     * Must be called after `addLargeAsset`
     */
    public function addSmallAsset(?image:String, ?text:String):PresenceBuilder
    {
        if (_activity.assets == null)
            return this;

        _activity.assets.small_image = (image != null && Presence.assets.exists(image)) ? Presence.assets[image].id : null;
        _activity.assets.small_text = (text != null && text.length > 1) ? text : null;

        return this;
    }

    /**
     * Secret for joining a party
     */
    public function addJoinSecret(secret:String):PresenceBuilder
    {
        if (_activity.secrets == null)
            _activity.secrets = {};

        _activity.secrets.join = secret;

        return this;
    }

    /**
     * Secret for spectating a game
     */
    public function addSpectateSecret(secret:String):PresenceBuilder
    {
        if (_activity.secrets == null)
            _activity.secrets = {};

        _activity.secrets.spectate = secret;

        return this;
    }

    /**
     * Secret for a specific instanced match
     */
    public function addMatchSecret(secret:String):PresenceBuilder
    {
        if (_activity.secrets == null)
            _activity.secrets = {};

        _activity.secrets.match = secret;

        return this;
    }

    /**
     * Whether or not the activity is an instanced game session
     */
    public function setInstance(state:Bool):PresenceBuilder
    {
        _activity.instance = state;

        return this;
    }

    /**
     * Activity flags OR d together, describes what the payload includes
     */
    public function setFlags(flags:ActivityFlags):PresenceBuilder
    {
        _activity.flags = flags;

        return this;
    }

    /**
     * Custom buttons shown in the Rich Presence (max 2)
     */
    public function setButtons(first:ActivityButtons, ?second:ActivityButtons):PresenceBuilder
    {
        if (_activity.buttons == null)
            _activity.buttons = [];

        _activity.buttons[0] = first;

        if (second != null)
            _activity.buttons[1] = second;

        return this;
    }

    /**
     * Finishes the build and sends the built `ActivityObject` into the Presence
     */
    public function send()
    {
        Presence.sendPresence(_activity);
    }
}