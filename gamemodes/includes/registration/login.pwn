#include <YSI\y_hooks>

//Character Selection:
#define MAX_CHARSELECT_TEXTDRAW		(15) // +1 if display server logo
#define MAX_CHARSELECT 				(5)

new PlayerText:charSelectTextDraw[MAX_PLAYERS][MAX_CHARSELECT_TEXTDRAW];
new charSelectTextDrawID[MAX_PLAYERS][MAX_CHARSELECT];
new charSelectTextDrawCount[MAX_PLAYERS];
new characterLister[MAX_PLAYERS][5][MAX_PLAYER_NAME + 1]; 


new characterPickTime[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
    characterPickTime[playerid] = 0;
}

forward OnPlayerJoin(playerid);
public OnPlayerJoin(playerid)
{
	new rows;
	cache_get_value_index_int(0, 0, rows);
	if(rows) Auth_Login(playerid);
	else Auth_Register(playerid);
	return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	SendClientMessage(playerid, 0x0033FFFF /*Blue*/, "ขอบคุณสำหรับการลงทะเบียน! คุณสามารถเข้าสู่ระบบได้แล้ว");
    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "เข้าสู่ระบบ", "ขอบคุณสำหรับการลงทะเบียน, %s\n\nป้อนรหัสผ่านด้านล่างนี้เพื่อเข้าใช้งาน:", "เข้าสู่ระบบ", "ออก", ReturnPlayerName(playerid));
	return 1;
}

forward OnPlayerLogin(playerid);
public OnPlayerLogin(playerid)
{
	new pPass[129], unhashed_pass[129];
	GetPVarString(playerid, "Unhashed_Pass",unhashed_pass, 129);
	if(cache_num_rows())
	{
		cache_get_value_index(0, 0, pPass, 129);
		cache_get_value_index_int(0, 1, e_pAccountData[playerid][mDBID]);
        cache_get_value_index(0, 2, e_pAccountData[playerid][mAccName], 60);
		
        if (strequal(unhashed_pass, pPass, true)) {
            DeletePVar(playerid, "Unhashed_Pass");

            cache_get_value_name_int(0, "admin", playerData[playerid][pAdmin]);
            ShowCharacterSelection(playerid);

        }
        else Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "เข้าสู่ระบบ", "รหัสผ่านไม่ถูกต้อง\nโปรดลองใหม่อีกครั้ง", "เข้าสู่ระบบ", "ออก");
  	}
    else {
        printf("ERROR: %s can't log-in", ReturnPlayerName(playerid));
    }
	return 1;
}

Auth_Login(playerid) {
    Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "เข้าสู่ระบบ", "สวัสดี, %s\n\nป้อนรหัสผ่านด้านล่างนี้เพื่อเข้าใช้งาน:", "เข้าสู่ระบบ", "ออก", ReturnPlayerName(playerid));
    return 1;
}

Auth_Register(playerid) {

	#if defined IN_GAME_REGISTER

    	Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "สมัครสมาชิก", "บัญชีนี้ยังไม่มีอยู่ในฐานข้อมูล โปรดลงทะเบียนด้วยการกรอกรหัสผ่านด้านล่างนี้", "ลงทะเบียน", "ออก");

	#else

		SendClientMessageEx(playerid, COLOR_LIGHTRED, "ERROR: "EMBED_WHITE"ไม่พบบัญชีผู้ใช้ชื่อ %s", ReturnPlayerName(playerid));
		SendClientMessage(playerid, COLOR_LIGHTRED, "[ ! ] "EMBED_WHITE"ตรวจสอบให้แน่ใจว่าคุณใช้ชื่อบัญชี(หลัก)ของคุณ ไม่ใช่ชื่อตัวละคร!");
		SendClientMessage(playerid, COLOR_LIGHTRED, "[ ! ] "EMBED_WHITE"ถ้าต้องการสร้างบัญชีผู้ใช้โปรดไปที่ http://omp.sw-rp.com/");
		KickEx(playerid);

	#endif

    return 1;
}

ShowCharacterSelection(playerid) {
    new query[128];
    mysql_format(dbCon, query, sizeof(query), "SELECT * FROM `characters` WHERE master_id = %d", e_pAccountData[playerid][mDBID]);
    mysql_tquery(dbCon, query, "selectCharacter", "d", playerid);

    characterPickTime[playerid] = 1;
}

timer ShowLoginCamera[400](playerid)
{
	if(IsPlayerConnected(playerid) && BitFlag_Get(gPlayerBitFlag[playerid], IS_LOGGED)) {
		SetPlayerVirtualWorld(playerid, playerid + 8000);
		SetPlayerCameraPos(playerid, 2559.6138,-1719.2664,37.2296);
		SetPlayerCameraLookAt(playerid, 2488.2173,-1665.3325,13.3438, CAMERA_CUT);
	}
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
    if (!response)
        Kick(playerid);

    new query[128], buf[129];

    WP_Hash(buf, sizeof (buf), inputtext);
    SetPVarString(playerid, "Unhashed_Pass",buf);

    mysql_format(dbCon, query, sizeof(query), "SELECT password, id, username, admin from `accounts` WHERE username = '%e'", ReturnPlayerName(playerid));
    mysql_tquery(dbCon, query, "OnPlayerLogin", "d", playerid);

    return 1;
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
    if (!response)
        Kick(playerid);

    new
        buf[129];

    WP_Hash(buf, sizeof (buf), inputtext);

    new query[256];
    mysql_format(dbCon, query, sizeof(query), "INSERT INTO `accounts` (username, password) VALUES('%e', '%e')", ReturnPlayerName(playerid), buf);
	mysql_tquery(dbCon, query, "OnPlayerRegister", "d", playerid);

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

				format(string, sizeof(string), "คุณเลือกตัวละคร {145F0B}%s{FFFFFF}", characterLister[playerid][i]);
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

ptask CharacterTimer[1000](playerid) {
    if(characterPickTime[playerid] > 0)
	{
		characterPickTime[playerid]++;
		
		if(characterPickTime[playerid] >= 60)
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "คุณถูกเตะเนื่องจากไม่ได้เลือกตัวละคร");
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
		SendClientMessage(playerid, -1, "[ERROR]: เกิดข้อผิดพลาดในการประมวลผลตัวละครของคุณ กำลังนำคุณกลับไปยังรายการตัวละครของคุณ...");
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

forward Query_LoadCharacter(playerid);
public Query_LoadCharacter(playerid)
{
	cache_get_value_name_int(0, "char_dbid", playerData[playerid][pDBID]);
	cache_get_value_name_int(0, "pLastSkin", playerData[playerid][pLastSkin]);
	cache_get_value_name_int(0, "pLevel", playerData[playerid][pLevel]);

	TogglePlayerSpectating(playerid, false);
	return LoadCharacter(playerid);
}

forward LoadCharacter(playerid);
public LoadCharacter(playerid)
{
	new
		string[128]
	;
	

    BitFlag_On(gPlayerBitFlag[playerid], IS_LOGGED);

	SetPlayerScore(playerid, playerData[playerid][pLevel]);
	SetPlayerColor(playerid, 0xFFFFFFFF);
	
    SetSpawnInfo(playerid, NO_TEAM, 1, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
	
	format(string, sizeof(string), "~w~Welcome~n~~y~ %s", ReturnPlayerName(playerid));
	GameTextForPlayer(playerid, string, 1000, 1);
	
	if (playerData[playerid][pAdmin])
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "SERVER: คุณเข้าสู่ระบบเป็นแอดมินระดับ %i", playerData[playerid][pAdmin]);
	}
    syncAdmin(playerid);

	SetPlayerSkin(playerid, playerData[playerid][pLastSkin]);
	return 1;
}

CreateNewCharacter(playerid) {

	#if defined IN_GAME_CREATE_CHARACTER

		SendClientMessage(playerid, -1, "กระบวนการเหล่านี้จะคอยแนะนำคุณตลอดการสร้างตัวละครของคุณ");
		SendClientMessage(playerid, -1, "โปรดเริ่มต้นด้วยการพิมพ์ชื่อและนามสกุลของตัวละคร ต.ย: {145F0B}Douglas_Hodge");
		SendClientMessage(playerid, -1, "ชื่อตัวละครของคุณต้องอยู่ในรูปแบบ Firstname_Lastname ไม่มีตัวเลขและอักษรพิเศษ");

		characterPickTime[playerid] = 0;

		Dialog_Show(playerid, DIALOG_CREATE_CHARACTER, DIALOG_STYLE_PASSWORD, "ตั้งชื่อตัวละคร", "ชื่อตัวละครของคุณต้องอยู่ในรูปแบบ Firstname_Lastname ไม่มีตัวเลขและอักษรพิเศษ\n\nป้อนชื่อตัวละครด้านล่างนี้:", "ยืนยัน", "ออก");
	
	#else

		SendClientMessage(playerid, COLOR_LIGHTRED, "บัญชีของคุณยังไม่ได้ตั้งค่าไว้ให้ใช้ในเกม (ยังไม่ได้ยื่นใบสมัคร/ตัวละครยังไม่ถูกยืนยัน)");
		SendClientMessage(playerid, COLOR_LIGHTRED, "โปรดเข้าสู่ระบบด้วยบัญชีของคุณบน omp.sw-rp.com และลองใหม่อีกครั้ง");
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
		Dialog_Show(playerid, DIALOG_CREATE_CHARACTER, DIALOG_STYLE_PASSWORD, "ตั้งชื่อตัวละคร", "ชื่อตัวละครไม่ถูกต้องตามรูปแบบ !!\n\nชื่อตัวละครของคุณต้องอยู่ในรูปแบบ Firstname_Lastname ไม่มีตัวเลขและอักษรพิเศษ\n\nป้อนชื่อตัวละครด้านล่างนี้:", "ยืนยัน", "ออก");
	}
	return 1;
}

forward OnCharacterCreated(playerid);
public OnCharacterCreated(playerid) {
	ShowCharacterSelection(playerid);
}