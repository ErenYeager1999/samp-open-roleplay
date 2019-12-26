/**
 *  เรียกชื่อ Roleplay จากผู้เล่น ไม่มีขีดเส้นใต้ (Underscore)
 * @param {number} ไอดีผู้เล่น
 */
ReturnRealName(playerid)
{
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, MAX_PLAYER_NAME);

    for (new i = 0, len = strlen(pname); i < len; i ++) if (pname[i] == '_') pname[i] = ' ';

    return pname;
}

/**
 *  ส่งข้อความไปยังผู้เล่นรอบ ๆ ตัวของไอดีผู้เล่นที่ระบุ
 * @param {number} ไอดีผู้เล่น
 * @param {float} ระยะทาง
 * @param {string} ข้อความ
 */
ProxDetector(playerid, Float:radius, const str[])
{
	new Float:posx, Float:posy, Float:posz;
	new Float:oldposx, Float:oldposy, Float:oldposz;
	new Float:tempposx, Float:tempposy, Float:tempposz;

	GetPlayerPos(playerid, oldposx, oldposy, oldposz);

	foreach (new i : Player)
	{
		if(GetPlayerInterior(playerid) == GetPlayerInterior(i) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
		{
			GetPlayerPos(i, posx, posy, posz);
			tempposx = (oldposx -posx);
			tempposy = (oldposy -posy);
			tempposz = (oldposz -posz);

			if (((tempposx < radius/16) && (tempposx > -radius/16)) && ((tempposy < radius/16) && (tempposy > -radius/16)) && ((tempposz < radius/16) && (tempposz > -radius/16)))
			{
				SendClientMessage(i, COLOR_GRAD1, str);
			}
			else if (((tempposx < radius/8) && (tempposx > -radius/8)) && ((tempposy < radius/8) && (tempposy > -radius/8)) && ((tempposz < radius/8) && (tempposz > -radius/8)))
			{
				SendClientMessage(i, COLOR_GRAD2, str);
			}
			else if (((tempposx < radius/4) && (tempposx > -radius/4)) && ((tempposy < radius/4) && (tempposy > -radius/4)) && ((tempposz < radius/4) && (tempposz > -radius/4)))
			{
				SendClientMessage(i, COLOR_GRAD3, str);
			}
			else if (((tempposx < radius/2) && (tempposx > -radius/2)) && ((tempposy < radius/2) && (tempposy > -radius/2)) && ((tempposz < radius/2) && (tempposz > -radius/2)))
			{
				SendClientMessage(i, COLOR_GRAD4, str);
			}
			else if (((tempposx < radius) && (tempposx > -radius)) && ((tempposy < radius) && (tempposy > -radius)) && ((tempposz < radius) && (tempposz > -radius)))
			{
				SendClientMessage(i, COLOR_GRAD5, str);
			}
		}
	}
	return 1;
}

/**
 *  ซิงค์สิทธิ์ผู้ดูแล
 * @param {number} ไอดีผู้เล่น
 */
syncAdmin(playerid) {
	switch(playerData[playerid][pAdmin]) {
		case 1: {
			playerData[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1;
		}
		case 2: {
			playerData[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2;
		}
		case 3: {
			playerData[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3;
		}
		case 4: {
			playerData[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3 | CMD_LEAD_ADMIN;
		}
		case 5: {
			playerData[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3 | CMD_LEAD_ADMIN | CMD_MANAGEMENT;
		}
		case 6: {
			playerData[playerid][pCMDPermission] = CMD_TESTER | CMD_ADM_1 | CMD_ADM_2 | CMD_ADM_3 | CMD_LEAD_ADMIN | CMD_MANAGEMENT | CMD_DEV;
		}
		default: {
			playerData[playerid][pCMDPermission] = CMD_PLAYER;
		}
	}
}

/**
 *  ตรวจสอบสิทธิ์ระหว่าง Flags
 * @param {flags} ที่ต้องการเทียบ
 * @param {flags} ตัวเปรียบเทียบ
 */
stock isFlagged(flags, flagValue) {
    if ((flags & flagValue) == flagValue) {
        return true;
    }
    return false;
}