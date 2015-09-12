/* cout.h */

struct hdr {
        short ch_magic;         /*c.out magic number 060016 = $600E*/
        long ch_tsize;          /*text size*/
        long ch_dsize;          /*data size*/
        long ch_bsize;          /*bss size*/
        long ch_ssize;          /*symbol table size*/
        long ch_stksize;        /*stack size*/
        long ch_entry;          /*entry point*/
        short ch_rlbflg;        /*relocation bits suppressed flag*/
};

#define MAGIC   0x601a  /* bra .+26 instruction*/

/* end cout.h */
