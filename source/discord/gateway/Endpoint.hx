package discord.gateway;

// I literally don't understand how these work lol
abstract Endpoint(String)
{
    public static inline final OAUTH2:String = "https://discord.com/api/v10/oauth2/applications/";
    public static inline final APPLICATIONS:String = "https://discord.com/api/v10/applications/";
    public static inline final APP_ASSETS:String = "https://cdn.discordapp.com/app-assets/";

    public static function make(endpoint:String, id:String, onData:Dynamic->Void, onError:(Dynamic, String)->Void, ?onBytes:haxe.io.Bytes->Void, extraURL:String = "")
    {
        final nameReq:haxe.Http = new haxe.Http('$endpoint$id/$extraURL');

        nameReq.onData = function(data)
        {
            onData(haxe.Json.parse(data));
        }

        if (onBytes != null)
        {
            nameReq.onBytes = (bytes:haxe.io.Bytes) ->
            {
                onBytes(bytes);
            }
        }

        nameReq.onError = function(msg)
        {
            onError(msg, nameReq.url);
        }

        nameReq.request();
    }
}