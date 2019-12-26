
#include <YSI\y_hooks> 

hook OnGameModeInit() {

    //‡ª‘¥‚À¡¥ DEBUG 
    mysql_log(ERROR | WARNING);

	dbCon = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
	if (mysql_errno(dbCon)) {
		print("[SQL] Connection failed! Please check the connection settings...\a");
		SendRconCommand("exit");
		return 1;
	}
	else print("[SQL] Connection passed!");
	return 1;
}

hook OnGameModeExit() {
    if(dbCon)
    mysql_close(dbCon);
	return 1;
}