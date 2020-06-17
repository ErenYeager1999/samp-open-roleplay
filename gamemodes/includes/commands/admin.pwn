
flags:jetpack(CMD_DEV)
CMD:jetpack(playerid, params[]) {
    new bool:sJetPack;
    if (!sJetPack) {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
    }
    else {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    }
    sJetPack = !sJetPack;
    return 1;
}