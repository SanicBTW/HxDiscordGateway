package discord.presence;

// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image coming up soon :eyes:
typedef ActivityAssets =
{
    @:optional var large_image:String;
    @:optional var large_text:String;
    @:optional var small_image:String;
    @:optional var small_text:String;
}