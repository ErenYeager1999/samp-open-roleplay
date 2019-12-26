#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (100)

// YSI Include : aktah/YSI-Includes
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_va>

#include <whirlpool>    // Southclaws/samp-whirlpool
#include <a_mysql>      // pBlueG/SA-MP-MySQL 
#include <PAWN.CMD>     // urShadow/Pawn.CMD
#include <easyDialog>   // aktah/easyDialog
#include <log-plugin>   // maddinat0r/samp-log


/*======================================================================================================
										[Declarations]
=======================================================================================================*/

new
    Logger:adminactionlog;

//========================[ Modules ]========================

// ตั้งค่า
#include "includes/configuration/general.pwn"
#include "includes/configuration/database.pwn" // สร้างไฟล์ database.pwn ด้วยตัวเองในไดเรกทอรี่ gamemodes/includes/configuration/..

// อรรถประโยชน์
#include "includes/utility/colour.pwn"
#include "includes/utility/utils.pwn"

// เอกลักษณ์
#include "includes/entities/entities.pwn"

// ตัวหลัก
#include "includes/define.pwn"
#include "includes/enums.pwn"
#include "includes/variables.pwn"
#include "includes/function.pwn"
#include "includes/mysql/database.pwn"

#include "includes/registration/login.pwn"

#include "includes/commands/general.pwn"
#include "includes/commands/admin.pwn"
#include "includes/commands/roleplay.pwn"

main()
{
    print("\n----------------------------------");
    print(" ผู้เขียน: https://github.com/aktah/");
    print(" ลิขสิทธิ์: GNU GENERAL PUBLIC LICENSE v3");
    print(" การใช้ซอฟต์แวร์นี้เป็นโหมดเกมของคุณแสดงว่าคุณยอมรับสิ่งต่อไปนี้: โลโก้บนหน้าจอขณะรันเซิร์ฟเวอร์หรือลายน้ำต้องไม่ลบออก");
    print(" ข้อมูลนี้ต้องถูกเสนอและต้องไม่ถูกแก้ไข การสร้างรายได้ของโหมดเกมนี้ถูกห้ามอย่างเคร่งครัด");
    print(" ไม่ว่าคุณจะสร้างรายได้ในรูปแบบใด ๆ ก็ตาม \r\n");
    print(" หากคุณมีปัญหาใด ๆ กับเงื่อนไขเหล่านี้; ติดต่อ Leaks ทันที");
    print("----------------------------------\n");
}

public OnGameModeInit() {

    SendRconCommand("hostname "GM_HOST_NAME"");
    SetGameModeText(GM_VERSION);

    SetNameTagDrawDistance(NAME_TAG_DISTANCE);
	
    // ใช้การควบคุมเครื่องยนต์ด้วยสคริปต์แทน
	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);

    adminactionlog = CreateLog("server/admin_action");

    return 1;
}

public OnGameModeExit() {
    DestroyLog(adminactionlog);

    return 1;
}

public OnPlayerConnect(playerid) {

    // เคลียร์ตัวแปรผู้เล่น
    gPlayerBitFlag[playerid] = PlayerFlags:0;

    playerData[playerid][pCMDPermission] = CMD_PLAYER;
    playerData[playerid][pAdmin] = CMD_PLAYER;

	new query[90];
	mysql_format(dbCon, query, sizeof(query), "SELECT COUNT(username) FROM `accounts` WHERE username = '%e'", ReturnPlayerName(playerid));
	mysql_tquery(dbCon, query, "OnPlayerJoin", "d", playerid);

    SendClientMessage(playerid, -1, "ยินดีต้อนรับเข้าสู่ "EMBED_YELLOW"O:RP");
    return 1;
}

public OnPlayerRequestClass(playerid, classid) {
    TogglePlayerSpectating(playerid, true);
    defer ShowLoginCamera(playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {

	if (!BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED))
		Kick(playerid);

    TogglePlayerSpectating(playerid, false);
    
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetPlayerPos(playerid, 198.4090,-107.6075,1.5504);
    SetPlayerFacingAngle(playerid, 86.0094);

    return 1;
}

public OnPlayerText(playerid, text[]) {

    new str[144];

    format(str, sizeof(str), "%s พูดว่า: %s", ReturnRealName(playerid), text);
    ProxDetector(playerid, 20.0, str);

	printf("[%d]%s: %s", playerid, ReturnPlayerName(playerid), text);

	return 0;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(!BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED)) {
		SendClientMessage(playerid, COLOR_LIGHTRED, "ACCESS DENIED: {FFFFFF}คุณต้องเข้าสู่ระบบก่อนที่จะใช้คำสั่ง");
		return 0;
	}
    else if (!(flags & playerData[playerid][pCMDPermission]) && flags)
    {
        SendClientMessage(playerid, COLOR_LIGHTRED, "ACCESS DENIED: {FFFFFF}คุณไม่ได้รับอนุญาตให้ใช้คำสั่งนี้");
        return 0;
    }

    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if(result == -1)
    {
        SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: {FFFFFF}เกิดข้อผิดพลาดในการใช้คำสั่ง");
        return 0;
    }

	if(flags) { // Permission CMD
		if (flags & playerData[playerid][pCMDPermission])
		{
			Log(adminactionlog, INFO, "%s: /%s %s", ReturnPlayerName(playerid), cmd, params);
		}
	}
    return 1;
}