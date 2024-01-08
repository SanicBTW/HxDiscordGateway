package discord.presence;

enum abstract ActivityFlags(Int) to Int from Int
{
    final INSTANCE = (1 << 0);
    final JOIN = (1 << 1);
    final SPECTATE = (1 << 2);
    final JOIN_REQUEST = (1 << 3);
    final SYNC = (1 << 4);
    final PLAY = (1 << 5);
    final PARTY_PRIVACY_FRIENDS = (1 << 6);
    final PARTY_PRIVACY_VOICE_CHANNEL = (1 << 7);
    final EMBEDDED = (1 << 8);
}