#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (100)

// YSI Include : pawn-lang/YSI-Includes
#define YSI_NO_HEAP_MALLOC
#include <YSI_Coding\y_timers>
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_va>

#include <streamer>     // maddinat0r/sscanf
#include <sscanf2>      // maddinat0r/sscanf
#include <whirlpool>    // Southclaws/samp-whirlpool
#include <a_mysql>      // pBlueG/SA-MP-MySQL 
#include <Pawn.CMD>     // katursis/Pawn.CMD
#include <Pawn.RakNet>  // katursis/Pawn.RakNet
#include <io>           // aktah/io
#define cec_auto
#include <cec>          // aktah/cec
#include <easyDialog>   // aktah/easyDialog
#include <log-plugin>   // maddinat0r/samp-log
// #include <samp_bcrypt>  // Sreyas-Sreelal/samp-bcrypt
#include <strlib>

#include "config.inc"

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

// ��駤��
#include "includes/configuration/database.pwn" // ���ҧ��� database.pwn ���µ���ͧ���á����� gamemodes/includes/configuration/..

// ��ö����ª��
#include "includes/utility/colour.pwn"
#include "includes/utility/utils.pwn"

// �͡�ѡɳ�
#include "includes/entities/entities.pwn"

// �����ѡ
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
    print(" �����¹: https://github.com/aktah/");
    print(" �Ԣ�Է���: GNU GENERAL PUBLIC LICENSE v3");
    print(" �����Ϳ�����������������ͧ�س�ʴ���Ҥس����Ѻ��觵��仹��: ���麹˹�Ҩ͢���ѹ���������������¹�ӵ�ͧ���ź�͡");
    print(" �����Ź���ͧ�١�ʹ���е�ͧ���١��� ������ҧ�����ͧ���������١�������ҧ��觤�Ѵ");
    print(" �����Ҥس�����ҧ�������ٻẺ� � ���� \r\n");
    print(" �ҡ�س�ջѭ��� � �Ѻ���͹�����ҹ��; �Դ��� Leaks �ѹ��");
    print("----------------------------------\n");
}

public OnGameModeInit() {

    SendRconCommand("hostname "GM_HOST_NAME"");
    SetGameModeText(GM_VERSION);

    SetNameTagDrawDistance(NAME_TAG_DISTANCE);
	
    // ���äǺ�������ͧ¹�����ʤ�Ի��᷹
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

    // ���������ü�����
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
    playerData[playerid][pExp] = 0;
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

    SendClientMessage(playerid, -1, "�Թ�յ�͹�Ѻ������ "EMBED_YELLOW"Southwood Roleplay");
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {

    static const szDisconnectReason[3][] = {"��ش","�͡�ҡ����","�١��"};
    ProxDetector(playerid, 20.0, sprintf("*** %s �͡�ҡ��������� (%s)", ReturnPlayerName(playerid), szDisconnectReason[reason]));

    
    // �ѹ�֡�����ش
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

        // ��駤�Ҽ���������Ѻ���������ʶҹкҧ���ҧ����͹���

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

    format(str, sizeof(str), "%s �ٴ���: %s", ReturnRealName(playerid), text);
    ProxDetector(playerid, 20.0, str);

	printf("[%d]%s: %s", playerid, ReturnPlayerName(playerid), text);

	return 0;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(!BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED)) {
		SendClientMessage(playerid, COLOR_LIGHTRED, "ACCESS DENIED: {FFFFFF}�س��ͧ�������к���͹����������");
		return 0;
	}
    else if (!(flags & playerData[playerid][pCMDPermission]) && flags)
    {
        SendClientMessage(playerid, COLOR_LIGHTRED, "ACCESS DENIED: {FFFFFF}�س������Ѻ͹حҵ��������觹��");
        return 0;
    }

    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if(result == -1)
    {
        SendClientMessage(playerid, COLOR_LIGHTRED, "ERROR: {FFFFFF}�Դ��ͼԴ��Ҵ㹡��������");
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