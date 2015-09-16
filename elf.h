#ifndef _ELF_DOT_H_
#define _ELF_DOT_H_

typedef struct __attribute__ ((__packed__)) {
    unsigned char  ident_magic[4];
    unsigned char  ident_class;
    unsigned char  ident_data;
    unsigned char  ident_version;
    unsigned char  ident_osabi;
    unsigned char  ident_abiversion;
    unsigned char  padding[7];
    unsigned short type;
    unsigned short machine;
    unsigned long  version;
    unsigned long  entry;
    unsigned long  phoff;
    unsigned long  shoff;
    unsigned long  flags;
    unsigned short ehsize;
    unsigned short phentsize;
    unsigned short phnum;
    unsigned short shentsize;
    unsigned short shnum;
    unsigned short shtrndx;
} elf32_header;

typedef struct __attribute__ ((__packed__)) {
    unsigned long type;
    unsigned long offset;
    unsigned long vaddr;
    unsigned long paddr;
    unsigned long filesz;
    unsigned long memsz;
    unsigned long flags;
    unsigned long align;
} elf32_program_header;

enum {
    PT_NULL,    // 0
    PT_LOAD,    // 1
    PT_DYNAMIC, // 2
    PT_INTERP,  // 3
    PT_NOTE,    // 4
    PT_SHLIB,   // 5
    PT_PHDR     // 6
};

#endif
