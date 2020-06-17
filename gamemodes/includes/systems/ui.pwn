#include <YSI\y_hooks> // pawn-lang/YSI-Includes

#if defined USE_EXP_BAR

new isShowEXPBAR[MAX_PLAYERS char];
new Text:EXPBAR_BG[2];
new PlayerText:EXPBAR_TEXT[MAX_PLAYERS][2];
new PlayerBar:EXPBAR_BAR[MAX_PLAYERS];

#endif

hook OnGameModeInit() {

    #if defined USE_EXP_BAR

    EXPBAR_BG[0] = TextDrawCreate(113.000000, 397.000000, "_");
    TextDrawFont(EXPBAR_BG[0], 3);
    TextDrawLetterSize(EXPBAR_BG[0], 0.600000, 1.600002);
    TextDrawTextSize(EXPBAR_BG[0], 281.000000, 378.000000);
    TextDrawSetOutline(EXPBAR_BG[0], 1);
    TextDrawSetShadow(EXPBAR_BG[0], 0);
    TextDrawAlignment(EXPBAR_BG[0], 1);
    TextDrawColor(EXPBAR_BG[0], -1);
    TextDrawBackgroundColor(EXPBAR_BG[0], 255);
    TextDrawBoxColor(EXPBAR_BG[0], 135);
    TextDrawUseBox(EXPBAR_BG[0], 1);
    TextDrawSetProportional(EXPBAR_BG[0], 1);
    TextDrawSetSelectable(EXPBAR_BG[0], 0);

    EXPBAR_BG[1] = TextDrawCreate(262.000000, 397.000000, "EXP");
    TextDrawFont(EXPBAR_BG[1], 3);
    TextDrawLetterSize(EXPBAR_BG[1], 0.325000, 1.450000);
    TextDrawTextSize(EXPBAR_BG[1], 400.000000, 17.000000);
    TextDrawSetOutline(EXPBAR_BG[1], 0);
    TextDrawSetShadow(EXPBAR_BG[1], 0);
    TextDrawAlignment(EXPBAR_BG[1], 1);
    TextDrawColor(EXPBAR_BG[1], -1);
    TextDrawBackgroundColor(EXPBAR_BG[1], 255);
    TextDrawBoxColor(EXPBAR_BG[1], 50);
    TextDrawUseBox(EXPBAR_BG[1], 0);
    TextDrawSetProportional(EXPBAR_BG[1], 1);
    TextDrawSetSelectable(EXPBAR_BG[1], 0);
    
    #endif
}

hook OnPlayerConnect(playerid) {

    #if defined USE_EXP_BAR

    EXPBAR_TEXT[playerid][0] = CreatePlayerTextDraw(playerid, 119.000000, 378.000000, "Level: ~r~N/A");
    PlayerTextDrawFont(playerid, EXPBAR_TEXT[playerid][0], 3);
    PlayerTextDrawLetterSize(playerid, EXPBAR_TEXT[playerid][0], 0.337500, 1.600002);
    PlayerTextDrawTextSize(playerid, EXPBAR_TEXT[playerid][0], 203.000000, 85.500000);
    PlayerTextDrawSetOutline(playerid, EXPBAR_TEXT[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, EXPBAR_TEXT[playerid][0], 0);
    PlayerTextDrawAlignment(playerid, EXPBAR_TEXT[playerid][0], 1);
    PlayerTextDrawColor(playerid, EXPBAR_TEXT[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, EXPBAR_TEXT[playerid][0], 255);
    PlayerTextDrawBoxColor(playerid, EXPBAR_TEXT[playerid][0], 135);
    PlayerTextDrawUseBox(playerid, EXPBAR_TEXT[playerid][0], 0);
    PlayerTextDrawSetProportional(playerid, EXPBAR_TEXT[playerid][0], 1);
    PlayerTextDrawSetSelectable(playerid, EXPBAR_TEXT[playerid][0], 0);

    EXPBAR_TEXT[playerid][1] = CreatePlayerTextDraw(playerid, 186.000000, 411.000000, "N/A/N/A");
    PlayerTextDrawFont(playerid, EXPBAR_TEXT[playerid][1], 0);
    PlayerTextDrawLetterSize(playerid, EXPBAR_TEXT[playerid][1], 0.225000, 1.150000);
    PlayerTextDrawTextSize(playerid, EXPBAR_TEXT[playerid][1], 400.000000, 17.000000);
    PlayerTextDrawSetOutline(playerid, EXPBAR_TEXT[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, EXPBAR_TEXT[playerid][1], 0);
    PlayerTextDrawAlignment(playerid, EXPBAR_TEXT[playerid][1], 2);
    PlayerTextDrawColor(playerid, EXPBAR_TEXT[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, EXPBAR_TEXT[playerid][1], 255);
    PlayerTextDrawBoxColor(playerid, EXPBAR_TEXT[playerid][1], 50);
    PlayerTextDrawUseBox(playerid, EXPBAR_TEXT[playerid][1], 0);
    PlayerTextDrawSetProportional(playerid, EXPBAR_TEXT[playerid][1], 1);
    PlayerTextDrawSetSelectable(playerid, EXPBAR_TEXT[playerid][1], 0);

    EXPBAR_BAR[playerid] = CreatePlayerProgressBar(playerid, 261.000000, 402.000000, 145.500000, 7.500000, -1378294017, 100.000000, 1);
    SetPlayerProgressBarValue(playerid, EXPBAR_BAR[playerid], 0.000000);

    HidePlayerEXPBar(playerid);

    #endif

    return 1;
}

hook OnPlayerSpawn(playerid) {
    #if defined USE_EXP_BAR
    ShowPlayerEXPBar(playerid);
    #endif
    return 1;
}



// EXP BAR

#if defined USE_EXP_BAR

ShowPlayerEXPBar(playerid) {
    isShowEXPBAR{playerid} = true;

    TextDrawShowForPlayer(playerid, EXPBAR_BG[0]);
    TextDrawShowForPlayer(playerid, EXPBAR_BG[1]);
    
	PlayerTextDrawShow(playerid, EXPBAR_TEXT[playerid][0]);
	PlayerTextDrawShow(playerid, EXPBAR_TEXT[playerid][1]);

	ShowPlayerProgressBar(playerid, EXPBAR_BAR[playerid]);

    UpdatePlayerEXPBar(playerid);
    return 1;
}


HidePlayerEXPBar(playerid) {
    isShowEXPBAR{playerid} = false;

	TextDrawHideForPlayer(playerid, EXPBAR_BG[0]);
    TextDrawHideForPlayer(playerid, EXPBAR_BG[1]);
    
	PlayerTextDrawHide(playerid, EXPBAR_TEXT[playerid][0]);
	PlayerTextDrawHide(playerid, EXPBAR_TEXT[playerid][1]);

	HidePlayerProgressBar(playerid, EXPBAR_BAR[playerid]);
    return 1;
}

stock UpdatePlayerEXPBar(playerid) {
    if (isShowEXPBAR{playerid}) {
		new str[64];

		format(str, sizeof str, "Level: ~r~%d", playerData[playerid][pLevel]);
		PlayerTextDrawSetString(playerid, EXPBAR_TEXT[playerid][0], str);

		new maxxp = GetPlayerMaxEXP(playerid);
		format(str, sizeof str, "%d/%d", playerData[playerid][pExp], maxxp);
		PlayerTextDrawSetString(playerid, EXPBAR_TEXT[playerid][1], str);


		new Float:xp_percent = float(playerData[playerid][pExp]) / maxxp * 100.0;
		SetPlayerProgressBarValue(playerid, EXPBAR_BAR[playerid], xp_percent);

    }
    return 1;
}

#endif