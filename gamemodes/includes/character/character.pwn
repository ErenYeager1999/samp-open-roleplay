#include <YSI_Coding\y_hooks>

//Character Selection:
#define MAX_CHARSELECT_TEXTDRAW		(20) // +1 if display server logo, +5 for New Character button
#define MAX_CHARSELECT 				(5)

new PlayerText:charSelectTextDraw[MAX_PLAYERS][MAX_CHARSELECT_TEXTDRAW];
new charSelectTextDrawID[MAX_PLAYERS][MAX_CHARSELECT];
new charSelectTextDrawCount[MAX_PLAYERS];
new characterLister[MAX_PLAYERS][5][MAX_PLAYER_NAME + 1]; 


new characterPickTime[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
    characterPickTime[playerid] = 0;
	return 1;
}

forward selectCharacter(playerid);
public selectCharacter(playerid) {
	
    if(!cache_num_rows())
	{
		CreateNewCharacter(playerid);
		return 1;
	}
	
	new rows;
	cache_get_row_count(rows);
	
	if(rows)
	{
		new playerLevel, playerLastSkin;

		#if defined IN_GAME_CREATE_CHARACTER
			new Float:td_posX= 318.0 - (85.0 * float((rows > 3 ? 3 : rows) - ((rows < 3) ? 0 : 1))) + (5.0 * float((rows > 3 ? 3 : rows) - ((rows < 3) ? 0 : 1)));
		#else
			new Float:td_posX= 318.0 - (85.0 * float((rows > 3 ? 3 : rows) - 1)) + (5.0 * float((rows > 3 ? 3 : rows) - 1));
		#endif

		new Float:td_posY= 121.0;
		for (new i = 0; i < rows; i ++)
		{
			cache_get_value_name(i, "char_name", characterLister[playerid][i], 128);
			cache_get_value_name_int(i, "pLevel", playerLevel);
			cache_get_value_name_int(i, "pLastSkin", playerLastSkin);

			charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, td_posX, td_posY, "_");
			PlayerTextDrawFont(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawLetterSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0.595833, 16.450000);
			PlayerTextDrawTextSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255.500000, 148.500000);
			PlayerTextDrawSetOutline(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetShadow(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawAlignment(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 2);
			PlayerTextDrawColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -1);
			PlayerTextDrawBackgroundColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255);
			PlayerTextDrawBoxColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 70);
			PlayerTextDrawUseBox(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetProportional(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetSelectable(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]++], 0);

            new str[128];
            format(str, sizeof(str), "%s~n~Level %d", characterLister[playerid][i], playerLevel);
			charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, td_posX - 73.0, td_posY, str);
			PlayerTextDrawFont(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawLetterSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0.183329, 0.849995);
			PlayerTextDrawTextSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], td_posX + 82.0, 17.000000);
			PlayerTextDrawSetOutline(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetShadow(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawAlignment(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -1);
			PlayerTextDrawBackgroundColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255);
			PlayerTextDrawBoxColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 50);
			PlayerTextDrawUseBox(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetProportional(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetSelectable(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]++], 0);

			charSelectTextDrawID[playerid][i] = charSelectTextDrawCount[playerid];
			charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, td_posX - 83.0, td_posY + 13.0, "Preview_Model");
			PlayerTextDrawFont(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 5);
			PlayerTextDrawLetterSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0.600000, 2.000000);
			PlayerTextDrawTextSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 166.500000, 140.500000);
			PlayerTextDrawSetOutline(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetShadow(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawAlignment(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -1);
			PlayerTextDrawBackgroundColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawBoxColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255);
			PlayerTextDrawUseBox(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetProportional(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetSelectable(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetPreviewModel(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], playerLastSkin);
			PlayerTextDrawSetPreviewRot(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -8.000000, 0.000000, -1.000000, 0.979999);
			PlayerTextDrawSetPreviewVehCol(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]++], 1, 1);

			td_posX += 160.0;

			if (i != 0 && i%2 == 0) {
				td_posY += 164;
				#if defined IN_GAME_CREATE_CHARACTER
					td_posX= 318.0 - (65.0 * float(rows - 3) - ((rows < 3) ? 0 : 1)) + (5.0 * float(rows - 3) - ((rows < 3) ? 0 : 1));
				#else
					td_posX= 318.0 - (65.0 * float(rows - 3) - 1) + (5.0 * float(rows - 3) - 1);
				#endif
			}
		}

		#if defined IN_GAME_CREATE_CHARACTER
		if (rows < 3) {
			new i  = rows + 1;
			format(characterLister[playerid][i], MAX_PLAYER_NAME + 1, "New Character");
			charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, td_posX, td_posY, "_");
			PlayerTextDrawFont(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawLetterSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0.595833, 16.450000);
			PlayerTextDrawTextSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255.500000, 148.500000);
			PlayerTextDrawSetOutline(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetShadow(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawAlignment(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 2);
			PlayerTextDrawColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -1);
			PlayerTextDrawBackgroundColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255);
			PlayerTextDrawBoxColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 70);
			PlayerTextDrawUseBox(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetProportional(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetSelectable(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]++], 0);

			charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, td_posX - 73.0, td_posY, "NEW CHARACTER");
			PlayerTextDrawFont(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawLetterSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0.183329, 0.849995);
			PlayerTextDrawTextSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], td_posX + 82.0, 17.000000);
			PlayerTextDrawSetOutline(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetShadow(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawAlignment(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -1);
			PlayerTextDrawBackgroundColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255);
			PlayerTextDrawBoxColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 50);
			PlayerTextDrawUseBox(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetProportional(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetSelectable(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]++], 0);

			charSelectTextDrawID[playerid][i] = charSelectTextDrawCount[playerid];
			charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]] = CreatePlayerTextDraw(playerid, td_posX - 83.0, td_posY + 13.0, "Preview_Model");
			PlayerTextDrawFont(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 5);
			PlayerTextDrawLetterSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0.600000, 2.000000);
			PlayerTextDrawTextSize(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 166.500000, 140.500000);
			PlayerTextDrawSetOutline(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetShadow(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawAlignment(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -1);
			PlayerTextDrawBackgroundColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawBoxColor(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 255);
			PlayerTextDrawUseBox(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 0);
			PlayerTextDrawSetProportional(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetSelectable(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 1);
			PlayerTextDrawSetPreviewModel(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], 264);
			PlayerTextDrawSetPreviewRot(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]], -8.000000, 0.000000, -1.000000, 0.979999);
			PlayerTextDrawSetPreviewVehCol(playerid, charSelectTextDraw[playerid][charSelectTextDrawCount[playerid]++], 1, 1);

			td_posX += 160.0;

			if (i != 0 && i%2 == 0) {
				td_posY += 164;
				td_posX= 318.0 - (65.0 * float(rows - 3)) + (5.0 * float(rows - 3));
			}
		}
		#endif

		for (new i; i < charSelectTextDrawCount[playerid]; i++)
			PlayerTextDrawShow(playerid, charSelectTextDraw[playerid][i]);

		SelectTextDraw(playerid, 0xFFFFFF95);
	}
    return 1;
}

hook OP_ClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(characterPickTime[playerid] > 0) 
	{
		for (new i; i != MAX_CHARSELECT; i++)
		{
			if (playertextid == charSelectTextDraw[playerid][charSelectTextDrawID[playerid][i]])
			{

				CancelSelectTextDraw(playerid);
				
				for (new x; x < charSelectTextDrawCount[playerid]; x++)
					PlayerTextDrawDestroy(playerid, charSelectTextDraw[playerid][x]);

				charSelectTextDrawCount[playerid]=0;
				
				if (strequal(characterLister[playerid][i], "New Character", true)) {
					CreateNewCharacter(playerid);
					return 1;
				}

				new 
					string[128], thread[128]
				;
				
				characterPickTime[playerid] = 0;

				format(string, sizeof(string), "�س���͡����Ф� {145F0B}%s{FFFFFF}", characterLister[playerid][i]);
				SendClientMessage(playerid, -1, string);
				
				SetPlayerName(playerid, characterLister[playerid][i]); 
				
				mysql_format(dbCon, thread, sizeof(thread), "SELECT * FROM characters WHERE char_name = '%e' LIMIT 1", characterLister[playerid][i]);
				mysql_tquery(dbCon, thread, "Query_SelectCharacter", "i", playerid); 
				return 1;
			}
		}
		SelectTextDraw(playerid, 0xFFFFFF95);
	}
    return 1;
}

ShowCharacterSelection(playerid) {
    new query[128];
    mysql_format(dbCon, query, sizeof(query), "SELECT * FROM `characters` WHERE master_id = %d", e_pAccountData[playerid][mDBID]);
    mysql_tquery(dbCon, query, "selectCharacter", "d", playerid);

    characterPickTime[playerid] = 1;
}

CharacterSave(playerid, force = false, thread = MYSQL_TYPE_THREAD)
{
	if(BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED) || force)
	{
		new query[MAX_STRING];

		mysql_init("characters", "char_dbid", playerData[playerid][pDBID], thread); 

		mysql_int(query, "pLastSkin",playerData[playerid][pLastSkin]);
		mysql_bool(query, "pTutorial",playerData[playerid][pTutorial]);
		mysql_int(query, "pFaction",playerData[playerid][pFaction]);
 	    mysql_int(query, "pCash",playerData[playerid][pCash]);
		mysql_int(query, "pLevel",playerData[playerid][pLevel]);
 	   	mysql_int(query, "pSpawnPoint", playerData[playerid][pSpawnPoint]);
		mysql_int(query, "pSpawnHouse", playerData[playerid][pSpawnHouse]);

		if (playerData[playerid][pTimeout]) {
			/* 
				�ѹ�֡�����ŷ���ͧ����ѧ�ҡ�����
			*/
			GetPlayerHealth(playerid, playerData[playerid][pHealth]);
			GetPlayerArmour(playerid, playerData[playerid][pArmour]);

			mysql_flo(query, "pHealth", playerData[playerid][pHealth]);
			mysql_flo(query, "pArmour", playerData[playerid][pArmour]);

			GetPlayerPos(playerid, playerData[playerid][pLastPosX], playerData[playerid][pLastPosY], playerData[playerid][pLastPosZ]);

			mysql_flo(query, "pLastPosX", playerData[playerid][pLastPosX]);
			mysql_flo(query, "pLastPosY", playerData[playerid][pLastPosY]);
			mysql_flo(query, "pLastPosZ", playerData[playerid][pLastPosZ]);

			playerData[playerid][pLastInterior] = GetPlayerInterior(playerid);
			playerData[playerid][pLastWorld] = GetPlayerVirtualWorld(playerid);

			mysql_int(query, "pLastInterior",playerData[playerid][pLastInterior]);
			mysql_int(query, "pLastWorld",playerData[playerid][pLastWorld]);
			
			printf("[%d] %s: save last data", playerid, ReturnPlayerName(playerid));
		}
		mysql_int(query, "pTimeout", playerData[playerid][pTimeout]);
		
		mysql_int(query, "pJob", playerData[playerid][pJob]);
		mysql_int(query, "pSideJob", playerData[playerid][pSideJob]);
		mysql_int(query, "pCareer", playerData[playerid][pCareer]);
		mysql_int(query, "pPaycheck", playerData[playerid][pPaycheck]);
		mysql_int(query, "pFishes", playerData[playerid][pFishes]);

		mysql_finish(query);
	}
	return 1;
}

forward Query_LoadCharacter(playerid);
public Query_LoadCharacter(playerid)
{
	cache_get_value_name_int(0, "char_dbid", playerData[playerid][pDBID]);
	cache_get_value_name_int(0, "pLastSkin", playerData[playerid][pLastSkin]);
	cache_get_value_name_bool(0, "pTutorial", playerData[playerid][pTutorial]);
	cache_get_value_name_int(0, "pFaction", playerData[playerid][pFaction]);
	cache_get_value_name_int(0, "pCash", playerData[playerid][pCash]);
	cache_get_value_name_int(0, "pLevel", playerData[playerid][pLevel]);

	cache_get_value_name_int(0, "pTimeout", playerData[playerid][pTimeout]);

	new diff = gettime() - playerData[playerid][pTimeout];

	if (diff > 0 && diff <= 60 * TIMEOUT_CRASH_TIME) // diff = now - savetime
	{
		/* 
			��Ŵ�����ŷ���ͧ��͹��ش
		*/	
		cache_get_value_name_float(0, "pHealth", playerData[playerid][pHealth]);
		cache_get_value_name_float(0, "pArmour", playerData[playerid][pArmour]);

		cache_get_value_name_float(0, "pLastPosX", playerData[playerid][pLastPosX]);
		cache_get_value_name_float(0, "pLastPosY", playerData[playerid][pLastPosY]);
		cache_get_value_name_float(0, "pLastPosZ", playerData[playerid][pLastPosZ]);

		cache_get_value_name_int(0, "pLastInterior", playerData[playerid][pLastInterior]);
		cache_get_value_name_int(0, "pLastWorld", playerData[playerid][pLastWorld]);

	} else playerData[playerid][pTimeout] = 0;

	cache_get_value_name_int(0, "pSpawnPoint", playerData[playerid][pSpawnPoint]);
	cache_get_value_name_int(0, "pSpawnHouse", playerData[playerid][pSpawnHouse]);

	cache_get_value_name_int(0, "pJob", playerData[playerid][pJob]);
	cache_get_value_name_int(0, "pSideJob", playerData[playerid][pSideJob]);
	cache_get_value_name_int(0, "pCareer", playerData[playerid][pCareer]);
	cache_get_value_name_int(0, "pPaycheck", playerData[playerid][pPaycheck]);
	cache_get_value_name_int(0, "pFishes", playerData[playerid][pFishes]);

	return LoadCharacter(playerid);
}

forward LoadCharacter(playerid);
public LoadCharacter(playerid)
{
	new
		string[128]
	;
	
	ResetPlayerMoney(playerid);

	if (!playerData[playerid][pTutorial]) {
		// �ѧ����ҹ�����¹ / ����Ф�����
		playerData[playerid][pLevel] = 1;
		playerData[playerid][pCash] = DEFAULT_PLAYER_CASH;
		
		playerData[playerid][pTutorial] = true;
	}
    BitFlag_On(gPlayerBitFlag[playerid], IS_LOGGED);

	SetPlayerScore(playerid, playerData[playerid][pLevel]);
	SetPlayerColor(playerid, 0xFFFFFFFF);
	
    SetSpawnInfo(playerid, NO_TEAM, 1, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
    TogglePlayerSpectating(playerid, false);
	
	if (!playerData[playerid][pTimeout]) {
		format(string, sizeof(string), "~w~Welcome~n~~y~ %s", ReturnPlayerName(playerid));
		GameTextForPlayer(playerid, string, 1000, 1);
	}

	if (playerData[playerid][pAdmin])
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "SERVER: �س�������к����ʹ�Թ�дѺ %i", playerData[playerid][pAdmin]);
	}
	syncPrivateCar(playerid);
    syncAdmin(playerid);
	GivePlayerMoney(playerid, playerData[playerid][pCash]);

	SetPlayerSkin(playerid, playerData[playerid][pLastSkin]);
	return 1;
}

CreateNewCharacter(playerid) {

	#if defined IN_GAME_CREATE_CHARACTER

		SendClientMessage(playerid, -1, "��кǹ�������ҹ��Ф���йӤس��ʹ������ҧ����Фâͧ�س");
		SendClientMessage(playerid, -1, "�ô������鹴��¡�þ���������й��ʡ�Ţͧ����Ф� �.�: {145F0B}Douglas_Hodge");
		SendClientMessage(playerid, -1, "���͵���Фâͧ�س��ͧ������ٻẺ Firstname_Lastname ����յ���Ţ����ѡ�þ����");

		characterPickTime[playerid] = 0;

		Dialog_Show(playerid, DIALOG_CREATE_CHARACTER, DIALOG_STYLE_INPUT, "��駪��͵���Ф�", "���͵���Фâͧ�س��ͧ������ٻẺ Firstname_Lastname ����յ���Ţ����ѡ�þ����\n\n��͹���͵���Фô�ҹ��ҧ���:", "�׹�ѹ", "�͡");
	
	#else

		SendClientMessage(playerid, COLOR_LIGHTRED, "�ѭ�բͧ�س�ѧ������駤������������� (�ѧ�����������Ѥ�/����Ф��ѧ���١�׹�ѹ)");
		SendClientMessage(playerid, COLOR_LIGHTRED, "�ô�������к����ºѭ�բͧ�س�� yoursite.com ����ͧ�����ա����");
		KickEx(playerid);

	#endif
}

Dialog:DIALOG_CREATE_CHARACTER(playerid, response, listitem, inputtext[])
{
	if (!response) {
		Kick(playerid);
	}

	if (IsValidRoleplayName(inputtext)) {
		new query[256];
		mysql_format(dbCon, query, sizeof(query), "INSERT INTO `characters` (char_name, master_id) VALUES('%e', %d)", inputtext, e_pAccountData[playerid][mDBID]);
		mysql_tquery(dbCon, query, "OnCharacterCreated", "d", playerid);
	}
	else {
		Dialog_Show(playerid, DIALOG_CREATE_CHARACTER, DIALOG_STYLE_INPUT, "��駪��͵���Ф�", "���͵���Ф����١��ͧ����ٻẺ !!\n\n���͵���Фâͧ�س��ͧ������ٻẺ Firstname_Lastname ����յ���Ţ����ѡ�þ����\n\n��͹���͵���Фô�ҹ��ҧ���:", "�׹�ѹ", "�͡");
	}
	return 1;
}

forward OnCharacterCreated(playerid);
public OnCharacterCreated(playerid) {
	ShowCharacterSelection(playerid);
}

ptask CharacterTimer[1000](playerid) {
    if(characterPickTime[playerid] > 0)
	{
		characterPickTime[playerid]++;
		
		if(characterPickTime[playerid] >= 60)
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "�س�١�����ͧ�ҡ��������͡����Ф�");
			KickEx(playerid);
		}
	}
    return 1;
}

forward Query_SelectCharacter(playerid);
public Query_SelectCharacter(playerid)
{
	if (!cache_num_rows())
	{
		SendClientMessage(playerid, -1, "[ERROR]: �Դ��ͼԴ��Ҵ㹡�û����żŵ���Фâͧ�س ���ѧ�Ӥس��Ѻ��ѧ��¡�õ���Фâͧ�س...");
		ShowCharacterSelection(playerid);
		return 1;
	}
	
	new rows, thread[128]; 
	cache_get_row_count(rows); 
	
	if(rows)
	{
		mysql_format(dbCon, thread, sizeof(thread), "SELECT * FROM characters WHERE char_name = '%e'", ReturnPlayerName(playerid));
		mysql_tquery(dbCon, thread, "Query_LoadCharacter", "i", playerid);
	}
	
	return 1;
}

stock GiveMoney(playerid, amount)
{
	playerData[playerid][pCash] += amount;
	GivePlayerMoney(playerid, amount);
	
	/*new string[128]; 
	
	if(amount < 0) {
		format(string, sizeof(string), "~r~$%d", amount);
		GameTextForPlayer(playerid, string, 2000, 1);
	}
	else{
		format(string, sizeof(string), "~g~$%d", amount);
		GameTextForPlayer(playerid, string, 2000, 1);
	}*/
	return 1;
}