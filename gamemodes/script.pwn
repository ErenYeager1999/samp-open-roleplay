#include <a_samp>

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

public OnGameModeInit()
{
    SetGameModeText("O:RP");
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnGameModeExit()
{
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
    return 1;
}