#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (100)

// YSI Include : aktah/YSI-Includes
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_va>

#include <whirlpool>    // Southclaws/samp-whirlpool
#include <a_mysql>      // pBlueG/SA-MP-MySQL 
#include <easyDialog>   // aktah/easyDialog

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

    return 1;
}

public OnPlayerConnect(playerid) {

    PlayerData[playerid][pAdmin] = CMD_PLAYER;

	new query[90];
	mysql_format(dbCon, query, sizeof(query), "SELECT COUNT(username) FROM `accounts` WHERE username = '%e'", ReturnPlayerName(playerid));
	mysql_tquery(dbCon, query, "OnPlayerJoin", "d", playerid);
    return 1;
}

public OnPlayerRequestClass(playerid, classid) {
    TogglePlayerSpectating(playerid, true);
    defer ShowLoginCamera(playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {

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