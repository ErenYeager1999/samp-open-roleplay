

CMD:help(playerid, params[])
{
	SendClientMessage(playerid, COLOR_DARKGREEN, "______________________________________________");
	
	SendClientMessage(playerid, COLOR_GRAD2,"[CHAT] (/s)hout (/l)ocal /me /ame /do /low");
	SendClientMessage(playerid, COLOR_GRAD1,"[HELP] /jobhelp /fishhelp");
	SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
    SendClientMessage(playerid, COLOR_GRAD1,"โปรดศึกษาคำสั่งในเซิร์ฟเวอร์เพิ่มเติมในฟอรั่มหรือ /helpme เพื่อขอความช่วยเหลือ");
	return 1; 
}

CMD:jobhelp(playerid, params[])
{
    SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
	SendClientMessage(playerid, COLOR_GRAD3,"อาชีพในปัจจุบันของคุณ:");
	SendClientMessageEx(playerid,COLOR_GRAD3,"%s", GetJobName(playerData[playerid][pCareer], playerData[playerid][pJob]));

	if(playerData[playerid][pSideJob]) {
		SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
		SendClientMessage(playerid, COLOR_GRAD3,"อาชีพเสริม:");
		SendClientMessageEx(playerid,COLOR_GRAD3,"%s", GetJobName(playerData[playerid][pCareer], playerData[playerid][pSideJob]));
	}

	// อาชีพเสริม
	

	// อาชีพหลัก
	if(playerData[playerid][pJob] == JOB_FARMER) {
	    SendClientMessage(playerid,COLOR_LIGHTRED,"คำสั่งของชาวไร่:");
		SendClientMessage(playerid,COLOR_WHITE,"/harvest");
		SendClientMessage(playerid,COLOR_WHITE,"/stopharvest");
	}


	return 1;
}