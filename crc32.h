/* crc32.h */

#define crc(a,b) (~crc32((a),(b),CRC_POLY1))

#define CRC_POLY1 0x04c11db7UL
#define CRC_POLY2 0x23a55379UL
#define CRC_POLY3 0x049f21c7UL
#define CRC_POLY4 0x1c632927UL
#define CRC_POLY5 0xA3139383UL

uint32 crc32 (byte *cp, int nsize, uint32 polynomial);

/* crc32.h */
