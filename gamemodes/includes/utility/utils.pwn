stock SendClientMessageToAllEx(colour, const fmat[], va_args<>)
{
	new
		str[145];
	va_format(str, sizeof (str), fmat, va_start<2>);
	return SendClientMessageToAll(colour, str);
}

stock SendClientMessageEx(playerid, colour, const fmat[],  va_args<>)
{
	new
		str[145];
	va_format(str, sizeof (str), fmat, va_start<3>);
	return SendClientMessage(playerid, colour, str);
}

stock SendNearbyMessage(playerid, Float:radius, color, const fmat[], {Float,_}:...)
{
	new
		str[145];
	va_format(str, sizeof (str), fmat, va_start<4>);

	foreach (new i : Player)
	{
		if (IsPlayerNearPlayer(i, playerid, radius)) {
			SendClientMessage(i, color, str);
		}
	}

	return 1;
}

stock IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid)) {
		return 0;
	}

	static
		Float:fX,
		Float:fY,
		Float:fZ;

	GetPlayerPos(targetid, fX, fY, fZ);

	return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}