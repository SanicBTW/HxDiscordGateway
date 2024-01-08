package discord.presence;

enum abstract ActivityType(Int) to Int from Int
{
    /**
     * Playing {name}
     */
    final GAME = 0;

    /**
     * Streaming {details}
     */
    final STREAMING = 1;

    /**
     * Listening to {name}
     */
    final LISTENING = 2;

    /**
     * Watching {name}
     */
    final WATCHING = 3;

    /**
     * {emoji} {state}
     */
    final CUSTOM = 4;

    /**
     * Competing in {name}
     */
    final COMPETING = 5;
}