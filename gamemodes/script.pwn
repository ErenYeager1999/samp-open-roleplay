#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (100)

// YSI Include : aktah/YSI-Includes
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_va>

#include <streamer>      // maddinat0r/sscanf
#include <sscanf2>      // maddinat0r/sscanf
#include <whirlpool>    // Southclaws/samp-whirlpool
#include <a_mysql>      // pBlueG/SA-MP-MySQL 
#include <PAWN.CMD>     // urShadow/Pawn.CMD
#include <easyDialog>   // aktah/easyDialog
#include <log-plugin>   // maddinat0r/samp-log
#include <strlib>

/*======================================================================================================
										[Macros]
=======================================================================================================*/
DEFINE_HOOK_REPLACEMENT(OnPlayer, OP_);

/*======================================================================================================
										[Declarations]
=======================================================================================================*/

new
    Logger:adminactionlog;

/*======================================================================================================
										[Modules]
=======================================================================================================*/

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
#include "includes/character/character.pwn"

#include "includes/systems/cooldown.pwn"
#include "includes/systems/vehicles.pwn"
#include "includes/systems/car_rental.pwn"
#include "includes/systems/job.pwn"

#include "includes/jobs/farmer.pwn"
#include "includes/jobs/fisher.pwn"

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


    playerData[playerid][pJob] = 0;
    playerData[playerid][pSideJob] = 0;
    playerData[playerid][pCareer] = 0;
    playerData[playerid][pPaycheck] = 0;
    playerData[playerid][pFishes] = 0;
    playerData[playerid][pCash] = 0;
    playerData[playerid][pFaction] = 0;
    playerData[playerid][pLevel] = 0;
    playerData[playerid][pLastSkin] = 264;
    playerData[playerid][pTutorial] = false;

    playerData[playerid][pLastInterior] = 
    playerData[playerid][pLastWorld] = 
    playerData[playerid][pTimeout] = 
    playerData[playerid][pSpawnPoint] = 
    playerData[playerid][pSpawnHouse] = 0;

    playerData[playerid][pHealth] = 100.0;
    playerData[playerid][pArmour] = 
    playerData[playerid][pLastPosX] = 
    playerData[playerid][pLastPosY] = 
    playerData[playerid][pLastPosZ] = 0.0;

    playerData[playerid][pUnscrambleID] = 0;
    playerData[playerid][pUnscrambling] = false;
	playerData[playerid][pScrambleFailed] = 0;
	playerData[playerid][pScrambleSuccess] = 0; 

    playerData[playerid][pDuplicateKey] = 0;
    playerData[playerid][pUnscramblerTime] = 0;

	// vehicles.pwn
	gLastCar[playerid] = 0;
	gPassengerCar[playerid] = 0;

	new query[90];
	mysql_format(dbCon, query, sizeof(query), "SELECT COUNT(acc_name) FROM `masters` WHERE acc_name = '%e'", ReturnPlayerName(playerid));
	mysql_tquery(dbCon, query, "OnPlayerJoin", "d", playerid);

    SendClientMessage(playerid, -1, "ยินดีต้อนรับเข้าสู่ "EMBED_YELLOW"Southwood Roleplay");
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {

    static const szDisconnectReason[3][] = {"หลุด","ออกจากเกมส์","ถูกเตะ"};
    ProxDetector(playerid, 20.0, sprintf("*** %s ออกจากเซิร์ฟเวอร์ (%s)", ReturnPlayerName(playerid), szDisconnectReason[reason]));

    
    // บันทึกว่าหลุด
	if(reason == 0) {
		playerData[playerid][pTimeout] = gettime();
    }

    CharacterSave(playerid);
}

public OnPlayerRequestClass(playerid, classid) {
    TogglePlayerSpectating(playerid, true);
    defer ShowLoginCamera(playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {

	if (!BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED))
		Kick(playerid);

    if (playerData[playerid][pTimeout]) {

        // ตั้งค่าผู้เล่นให้กลับที่เดิมและสถานะบางอย่างเหมือนเดิม

        SetPlayerVirtualWorld(playerid, playerData[playerid][pLastWorld]);
        SetPlayerInterior(playerid, playerData[playerid][pLastInterior]);

        SetPlayerPos(playerid, playerData[playerid][pLastPosX], playerData[playerid][pLastPosY], playerData[playerid][pLastPosZ]);

        SetPlayerHealth(playerid, playerData[playerid][pHealth]);
        SetPlayerArmour(playerid, playerData[playerid][pArmour]);

        playerData[playerid][pTimeout] = 0;

        GameTextForPlayer(playerid, "~r~crashed. ~w~returning to last position", 1000, 1);
        return 1;
    }
    
    switch (playerData[playerid][pSpawnPoint]) {
        case SPAWN_AT_DEFAULT: {
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, DEFAULT_SPAWN_LOCATION_X, DEFAULT_SPAWN_LOCATION_Y, DEFAULT_SPAWN_LOCATION_Z);
            SetPlayerFacingAngle(playerid, DEFAULT_SPAWN_LOCATION_A);
        }
        case SPAWN_AT_FACTION: {
            // to add
        }
        case SPAWN_AT_HOUSE: {
            // to add
        }
    }

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