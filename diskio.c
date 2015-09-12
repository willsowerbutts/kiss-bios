/* 2015-09-12 WRS */

#include "ffconf.h"
#include "diskio.h"     /* FatFs lower layer API */
#include "bioscall.h"   /* N8VEM 68K BIOS API */

DSTATUS drive_status[_VOLUMES] = { [ 0 ... _VOLUMES-1 ] = STA_NOINIT };

static long bios_drive_number(BYTE pdrv)
{
    return pdrv+2;
}

DSTATUS disk_status (BYTE pdrv)
{
    if(pdrv >= _VOLUMES)
        return STA_NOINIT;
    return drive_status[pdrv];
}

DSTATUS disk_initialize (BYTE pdrv)
{
    struct REGS reg;

    if(pdrv >= _VOLUMES)
        return STA_NOINIT;

    reg.D0 = 10; /* Disk_Reset */
    reg.D1 = bios_drive_number(pdrv);
    bios_call(&reg, &reg);
    
    if(reg.D0){
        /* error */
        drive_status[pdrv] = STA_NOINIT;
    }else{
        /* success */
        drive_status[pdrv] = 0;
    }

    return drive_status[pdrv];
}

DRESULT disk_read (
    BYTE pdrv,      /* Physical drive nmuber to identify the drive */
    BYTE *buff,     /* Data buffer to store read data */
    DWORD sector,   /* Sector address in LBA */
    UINT count      /* Number of sectors to read */
)
{
    struct REGS reg;

    if(pdrv >= _VOLUMES)
        return RES_PARERR;
    if(drive_status[pdrv] & (STA_NOINIT | STA_NODISK))
        return RES_NOTRDY;

    while(count > 0){
        reg.D0 = 12; /* Disk_Read */
        reg.D1 = bios_drive_number(pdrv);
        reg.D2 = sector;
        reg.D3 = 1; /* BIOS supports single sector transfers only at present */
        reg.A0 = buff;
        bios_call(&reg, &reg);

        if(reg.D0)
            return RES_ERROR;

        sector++;
        count--;
        buff+=512;
    }

    return RES_OK;
}

#if _USE_WRITE
DRESULT disk_write (
    BYTE pdrv,          /* Physical drive nmuber to identify the drive */
    const BYTE *buff,   /* Data to be written */
    DWORD sector,       /* Sector address in LBA */
    UINT count          /* Number of sectors to write */
)
{
    struct REGS reg;

    if(pdrv >= _VOLUMES)
        return RES_PARERR;
    if(drive_status[pdrv] & (STA_NOINIT | STA_NODISK))
        return RES_NOTRDY;

    while(count > 0){
        reg.D0 = 13; /* Disk_Write */
        reg.D1 = bios_drive_number(pdrv);
        reg.D2 = sector;
        reg.D3 = 1; /* BIOS supports single sector transfers only at present */
        reg.A0 = (BYTE*)buff;
        bios_call(&reg, &reg);

        if(reg.D0)
            return RES_ERROR;

        sector++;
        count--;
        buff+=512;
    }

    return RES_OK;
}
#endif

static long get_sector_count(BYTE pdrv)
{
    struct REGS reg;
    reg.D0 = 11; /* Disk_Info */
    reg.D1 = bios_drive_number(pdrv);
    reg.A0 = 0;  /* NULL = do not return drive info */
    bios_call(&reg, &reg);
    if(reg.D0)
        return -1;
    return reg.D1;
}

/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

#if _USE_IOCTL
DRESULT disk_ioctl (
    BYTE pdrv,      /* Physical drive nmuber (0..) */
    BYTE cmd,       /* Control code */
    void *buff      /* Buffer to send/receive control data */
)
{
    if(pdrv >= _VOLUMES)
        return RES_PARERR;
    if(drive_status[pdrv] & (STA_NOINIT | STA_NODISK))
        return RES_NOTRDY;

    switch(cmd){
        case CTRL_SYNC:
        case CTRL_TRIM:
            /* nop */
            return RES_OK;
        case GET_SECTOR_SIZE:
            *((long*)buff) = 512;
            return RES_OK;
        case GET_SECTOR_COUNT:
            *((long*)buff) = get_sector_count(pdrv);
            if(*(long*)buff == -1)
                return RES_ERROR;
            else
                return RES_OK;
        default:
            return RES_PARERR;
    }
}
#endif
