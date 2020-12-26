#include <YSI_Coding\y_hooks> // pawn-lang/YSI-Includes

#define MAX_PRIVATE_CAR_PAGE    2
#define MAX_PLAYER_PRIVATE_CAR  20
// #define PLAYER_PRIVATE_SPAWN_LIMIT  1

enum E_PLAYER_PRIVATE_CAR
{
    pPId,
    pPModelid,
    pPColor1,
    pPColor2,

    // Local
    pPCar
};

new PlayerPrivateCar[MAX_PLAYERS][MAX_PLAYER_PRIVATE_CAR][E_PLAYER_PRIVATE_CAR];
new PlayerPrivateSpawn[MAX_PLAYERS] = { INVALID_VEHICLE_ID, ...};

syncPrivateCar(playerid)
{
    new query[70];
    mysql_format(dbCon, query, sizeof query, "SELECT * FROM `private_car` WHERE player_id = %d", playerData[playerid][pDBID]);
    mysql_tquery(dbCon, query, "Load_PlayerPrivateCar", "i", playerid);
}

forward Load_PlayerPrivateCar(playerid);
public Load_PlayerPrivateCar(playerid)
{
    new rows = cache_num_rows();
    for(new row = 0; row != rows; row ++) if (row < MAX_PLAYER_PRIVATE_CAR)
    {
        cache_get_value_name_int(row, "id", PlayerPrivateCar[playerid][row][pPId]);
        cache_get_value_name_int(row, "modelid", PlayerPrivateCar[playerid][row][pPModelid]);
        cache_get_value_name_int(row, "color1", PlayerPrivateCar[playerid][row][pPColor1]);
        cache_get_value_name_int(row, "color2", PlayerPrivateCar[playerid][row][pPColor2]);

        printf("player %d loaded car id %d", playerid, PlayerPrivateCar[playerid][row][pPId]);
    }
}

hook OnPlayerConnect(playerid)
{
    PlayerPrivateSpawn[playerid] = INVALID_VEHICLE_ID;
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    if (PlayerPrivateSpawn[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(PlayerPrivateSpawn[playerid]);
        PlayerPrivateSpawn[playerid] = INVALID_VEHICLE_ID;
    }

    for(new row = 0; row != MAX_PLAYER_PRIVATE_CAR; row ++)
    {
        PlayerPrivateCar[playerid][row][pPCar] = 0;
        PlayerPrivateCar[playerid][row][pPId] = 0;
    }
}

CMD:mycar(playerid, params[])
{
    new 
        dialog_output[MAX_PRIVATE_CAR_PAGE * 24 + 10],
        orderString[16],
        count = 0
    ;
    
    for(new row = 0; row != MAX_PLAYER_PRIVATE_CAR; row ++)
    {
        if (count >= MAX_PRIVATE_CAR_PAGE)
        {
            format(dialog_output, sizeof dialog_output, "%s\n>>", dialog_output);
            break;
        }

        if (PlayerPrivateCar[playerid][row][pPId])
        {

            format(orderString, sizeof orderString, "spawnOrder%d", count);
            SetPVarInt(playerid, orderString, row);
            count++;
            
            if (dialog_output[0] == '\0')
            {
                format(dialog_output, sizeof dialog_output, "%s%s", 
                    ReturnVehicleModelName(PlayerPrivateCar[playerid][row][pPModelid]), 
                    (PlayerPrivateCar[playerid][row][pPCar] == PlayerPrivateSpawn[playerid]) ? (" �Դ����") : ("")
                );
                continue;
            }
    
            format(dialog_output, sizeof dialog_output, "%s\n%s%s", 
                dialog_output,
                ReturnVehicleModelName(PlayerPrivateCar[playerid][row][pPModelid]), 
                (PlayerPrivateCar[playerid][row][pPCar] == PlayerPrivateSpawn[playerid]) ? (" �Դ����") : ("")
            );
        }
    }

    SetPVarInt(playerid, "spawnPage", 1);
    Dialog_Show(playerid, D_SpawnCar, DIALOG_STYLE_LIST, "ö��ǹ��Ǣͧ�ѹ", dialog_output, "���¡", "�Դ");
    return 1;
}

Dialog:D_SpawnCar(playerid, response, listitem, inputtext[])
{
    if (!response)
        return 1; 

    new orderString[16];
    format(orderString, sizeof orderString, "spawnOrder%d", listitem);

    new 
        row = GetPVarInt(playerid, orderString),
        page = GetPVarInt(playerid, "spawnPage")
    ;

    if (listitem > MAX_PRIVATE_CAR_PAGE - 1)
    {
        new 
            skip = MAX_PRIVATE_CAR_PAGE * page,
            dialog_output[MAX_PRIVATE_CAR_PAGE * 24 + 10], 
            count = 0
        ;

        for(row = 0; row != MAX_PLAYER_PRIVATE_CAR; row ++)
        {
            if (skip) {
                skip--;
                continue;
            }

            if (count >= MAX_PRIVATE_CAR_PAGE)
            {
                format(dialog_output, sizeof dialog_output, "%s\n>>", dialog_output);
                break;
            }
            
            if (PlayerPrivateCar[playerid][row][pPId])
            {
                format(orderString, sizeof orderString, "spawnOrder%d", count);
                SetPVarInt(playerid, orderString, row);
                count++;
                
                if (dialog_output[0] == '\0')
                {
                    format(dialog_output, sizeof dialog_output, "%s%s", 
                        ReturnVehicleModelName(PlayerPrivateCar[playerid][row][pPModelid]), 
                        (PlayerPrivateCar[playerid][row][pPCar] == PlayerPrivateSpawn[playerid]) ? (" �Դ����") : ("")
                    );
                    continue;
                }
        
                format(dialog_output, sizeof dialog_output, "%s\n%s%s", 
                    dialog_output,
                    ReturnVehicleModelName(PlayerPrivateCar[playerid][row][pPModelid]), 
                    (PlayerPrivateCar[playerid][row][pPCar] == PlayerPrivateSpawn[playerid]) ? (" �Դ����") : ("")
                );
            }
        }
        SetPVarInt(playerid, "spawnPage", ++page);
        return Dialog_Show(playerid, D_SpawnCar, DIALOG_STYLE_LIST, "ö��ǹ��Ǣͧ�ѹ", dialog_output, "���¡", "�Դ");
    }

    if (PlayerPrivateCar[playerid][row][pPId])
    {
        if (PlayerPrivateSpawn[playerid] != INVALID_VEHICLE_ID)
        {
            for(new x = 0; x != MAX_PLAYER_PRIVATE_CAR; x ++)
            {
                if (PlayerPrivateSpawn[playerid] == PlayerPrivateCar[playerid][x][pPCar])
                {
                    PlayerPrivateCar[playerid][x][pPCar] = 0;
                    break;
                }
            }

            DestroyVehicle(PlayerPrivateSpawn[playerid]);
        }

        new Float:pX, Float:pY, Float:pZ, Float:pA;
        GetPlayerPos(playerid, pX, pY, pZ);
        GetPlayerFacingAngle(playerid, pA);

        PlayerPrivateSpawn[playerid] = CreateVehicle(PlayerPrivateCar[playerid][row][pPModelid], pX, pY, pZ, pA, PlayerPrivateCar[playerid][row][pPColor1], PlayerPrivateCar[playerid][row][pPColor2], -1);
        PlayerPrivateCar[playerid][row][pPCar] = PlayerPrivateSpawn[playerid];

        ToggleVehicleEngine(PlayerPrivateSpawn[playerid], true); vehicleData[PlayerPrivateSpawn[playerid]][eVehicleEngineStatus] = true;
    }

    return 1;
}

AddPrivateCarToPlayer(playerid, modelid)
{
    new query[128];
    mysql_format(dbCon, query, sizeof query, "INSERT INTO `private_car` (modelid, player_id) VALUES (%d, %d)", modelid, playerData[playerid][pDBID]);
    mysql_tquery(dbCon, query, "Give_PlayerCar", "ii", playerid, modelid);
}

forward Give_PlayerCar(playerid, modelid);
public Give_PlayerCar(playerid, modelid)
{
    new insertid = cache_insert_id();
    if (insertid)
    {
        for(new row = 0; row != MAX_PLAYER_PRIVATE_CAR; row ++)
        {
            if (!PlayerPrivateCar[playerid][row][pPId])
            {
                PlayerPrivateCar[playerid][row][pPId] = insertid;
                PlayerPrivateCar[playerid][row][pPModelid] = modelid;
                return 1;
            }
        }

        new query[128];
        mysql_format(dbCon, query, sizeof query, "DELETE FROM `private_car` WHERE id = %d", insertid);
        mysql_tquery(dbCon, query);
    }
    return 1;
}

CMD:giveplayercar(playerid, params[])
{
    new 
        targetid = INVALID_PLAYER_ID, 
        modelid = 0
    ;

    if (sscanf(params, "ud", targetid, modelid)) {
        SendClientMessage(playerid, -1, "/giveplayercar [playerid/partofname] [modelid]");
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID)
        return 1;

    if (modelid < 400 || modelid > 611)
	    return 1;

    AddPrivateCarToPlayer(targetid, modelid);
    return 1;
}

PrivateVehicle_FindIndex(playerid, vehicleid)
{
    for(new x = 0; x != MAX_PLAYER_PRIVATE_CAR; x ++)
    {
        if (vehicleid == PlayerPrivateCar[playerid][x][pPCar])
        {
            return x;
        }
    }

    return -1;
}

CMD:changecolor(playerid, params[])
{
    if (PlayerPrivateSpawn[playerid] == INVALID_VEHICLE_ID)
       return SendClientMessage(playerid, COLOR_LIGHTRED, "�س�ѧ��������¡ö¹����ǹ���");

    new color1, color2;

    if (sscanf(params, "dd", color1, color2))
        return SendClientMessage(playerid, COLOR_GRAD2, "/changecolor [c1] [c2]");

    if (color1 < 0 || color1 > 255 || color2 < 0 || color2 > 255)
        return SendClientMessage(playerid, COLOR_GRAD2, "color 0-255 only !");
    
    new id = PrivateVehicle_FindIndex(playerid, PlayerPrivateSpawn[playerid]);
    if (id == -1) return SendClientMessage(playerid, COLOR_LIGHTRED, "�س�ѧ��������¡ö¹����ǹ���");

    PlayerPrivateCar[playerid][id][pPColor1] = color1;
    PlayerPrivateCar[playerid][id][pPColor2] = color2;
    
    ChangeVehicleColor(PlayerPrivateSpawn[playerid], color1, color2);

    return 1;
}
CMD:savecar(playerid, params[])
{
    if (PlayerPrivateSpawn[playerid] == INVALID_VEHICLE_ID)
        return SendClientMessage(playerid, COLOR_LIGHTRED, "�س�ѧ��������¡ö¹����ǹ���");
    
    new id = PrivateVehicle_FindIndex(playerid, PlayerPrivateSpawn[playerid]);
    if (id == -1) return SendClientMessage(playerid, COLOR_LIGHTRED, "�س�ѧ��������¡ö¹����ǹ���");

    new query[128];
    mysql_format(dbCon, query, sizeof query, "UPDATE `private_car` SET color1 = %d, color2 = %d WHERE id = %d", PlayerPrivateCar[playerid][id][pPColor1], PlayerPrivateCar[playerid][id][pPColor2], PlayerPrivateCar[playerid][id][pPId]);
    mysql_tquery(dbCon, query); 

    return 1;
}

CMD:sellcar(playerid, params[])
{
    if (PlayerPrivateSpawn[playerid] == INVALID_VEHICLE_ID)
        return SendClientMessage(playerid, COLOR_LIGHTRED, "�س�ѧ��������¡ö¹����ǹ���");

    new id = PrivateVehicle_FindIndex(playerid, PlayerPrivateSpawn[playerid]);
    if (id == -1) return SendClientMessage(playerid, COLOR_LIGHTRED, "�س�ѧ��������¡ö¹����ǹ���");

    new query[128];
    mysql_format(dbCon, query, sizeof query, "DELETE FROM `private_car` WHERE id = %d", PlayerPrivateCar[playerid][id][pPId]);
    mysql_tquery(dbCon, query, "Query_DeleteCar", "ii", playerid, id);
    return 1;
}

forward Query_DeleteCar(playerid, id);
public Query_DeleteCar(playerid, id)
{
    if (cache_affected_rows())
    {
        if (PlayerPrivateSpawn[playerid] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(PlayerPrivateSpawn[playerid]);
            PlayerPrivateSpawn[playerid] = INVALID_VEHICLE_ID;
        }

        PlayerPrivateCar[playerid][id][pPCar] = 0;
        PlayerPrivateCar[playerid][id][pPId] = 0;
    }
}