#define SendSyntaxMessage(%0,%1) \
	SendClientMessageEx(%0, COLOR_LIGHTRED, "การใช้:"EMBED_WHITE" "%1)

// ใช้มาโคร BitFlag
#define BitFlag_Get(%0,%1)   		((%0) & (%1))   // ส่งค่ากลับ 0 (เท็จ)หากยังไม่ได้ตั้งค่าให้มัน
#define BitFlag_On(%0,%1)    		((%0) |= (%1))  // ปรับค่าเป็น เปิด
#define BitFlag_Off(%0,%1)   		((%0) &= ~(%1)) // ปรับค่าเป็น ปิด
#define BitFlag_Toggle(%0,%1)		((%0) ^= (%1))  // สลับค่า (สลับ จริง/เท็จ)

#define	MAX_STRING					255