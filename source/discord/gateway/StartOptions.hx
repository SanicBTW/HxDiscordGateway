package discord.gateway;

typedef StartOptions =
{
    // Metadata

    /**
     * The ID of the RPC Application.
     */
    var applicationID:String;

    /**
     * The name of the RPC Application;
     *
     * WARNING: Due to recent changes to the Discord API the code
     *
     * can't access the Applications API even when requesting it with the User Token
     *
     * so you now have to explicitly set the Application Name.
     */
    var applicationName:String;

    /**
     * Fired when the WebSocket client asks for the user token
     *
     * in order to authenticate in the Gateway.
     */
    var onTokenRequest:Void->String;

    // WebSocket client listeners

    /**
     * Fired when the WebSocket client is connected to the Gateway.
     */
    @:optional var onConnected:Void->Void;

    /**
     * Fired when the WebSocket client is disconnected from the Gateway.
     */
    @:optional var onDisconnected:Null<Dynamic>->Void;

    /**
     * Fired when the WebSocket client had an internal error.
     */
    @:optional var onError:String->Void;

    // Gateway listeners

    /**
     * Fired when the user is authenticated in the Gateway.
     */
    @:optional var onReady:Void->Void;

    /**
     * Fired when the user resumes connection to the Gateway.
     */
    @:optional var onResume:Void->Void;
}