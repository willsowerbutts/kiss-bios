#ifndef _BOOTINFO_DOT_H_
#define _BOOTINFO_DOT_H_

/* WRS: Structures required for Linux kernel bootloading */
/* mostly taken from linux/arch/m68k/include/uapi/asm/bootinfo.h */

struct bi_record {
    unsigned short tag;                     /* tag ID */
    unsigned short size;                    /* size of record (in bytes) */
    unsigned long data[0];                 /* data */
};


struct mem_info {
    unsigned long addr;                    /* physical address of memory chunk */
    unsigned long size;                    /* length of memory chunk (in bytes) */
};

#define BI_LAST                 0x0000  /* last record (sentinel) */
#define BI_MACHTYPE             0x0001  /* machine type (unsigned long) */
#define BI_CPUTYPE              0x0002  /* cpu type (unsigned long) */
#define BI_FPUTYPE              0x0003  /* fpu type (unsigned long) */
#define BI_MMUTYPE              0x0004  /* mmu type (unsigned long) */
#define BI_MEMCHUNK             0x0005  /* memory chunk address and size */
                                        /* (struct mem_info) */
#define BI_RAMDISK              0x0006  /* ramdisk address and size */
                                        /* (struct mem_info) */
#define BI_COMMAND_LINE         0x0007  /* kernel command line parameters */
                                        /* (string) */

#define MACH_KISS68030          13      /* unofficial as of 2015-09 */
#define CPUB_68030              1
#define CPU_68030               (1 << CPUB_68030)
#define FPUB_68881              0
#define FPUB_68882              1
#define FPU_68881               (1 << FPUB_68881)
#define FPU_68882               (1 << FPUB_68882)
#define MMUB_68030              1       /* Internal MMU */
#define MMU_68030               (1 << MMUB_68030)

#define BOOTINFOV_MAGIC                 0x4249561A      /* 'BIV^Z' */
#define MK_BI_VERSION(major, minor)     (((major) << 16) + (minor))
#define BI_VERSION_MAJOR(v)             (((v) >> 16) & 0xffff)
#define BI_VERSION_MINOR(v)             ((v) & 0xffff)

struct __attribute__ ((__packed__)) bootversion {
    unsigned short branch;
    unsigned long magic;
    struct {
        unsigned long machtype;
        unsigned long version;
    } machversions[0];
};

#define KISS68030_BOOTI_VERSION MK_BI_VERSION(2, 0)

#endif
