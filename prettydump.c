#include "string.h"
#include "main68.h"

void pretty_dump_memory(void *start, int len)
{
    int i, rem;
    unsigned char *ptr=(unsigned char *)start;
    char linebuffer[17], *lbptr;

    for(i=0;i<16;i++)
        linebuffer[i] = ' ';
    linebuffer[16]=0;
    lbptr = &linebuffer[0];

    cprintf("%08lx ", (unsigned)ptr&(~15));
    for(i=0; i<((unsigned)ptr & 15); i++){
        cprintf("   ");
        lbptr++;
    }
    while(len){
        if(*ptr >= 32 && *ptr < 127)
            *lbptr = *ptr;
        else
            *lbptr = '.';

        cprintf(" %02x", *ptr++);
        len--;
        lbptr++;

        if((unsigned)ptr % 16 == 0){
            cprintf("  %s", linebuffer);
            lbptr = &linebuffer[0];
            if(len)
                cprintf("\n%08lx ", ptr);
            else{
                /* no ragged end to tidy up! */
                cprintf("\n");
                return;
            }
        }
    }

    rem = 16 - ((unsigned)ptr & 15);

    for(i=0; i<rem; i++){
        cprintf("   ");
        *lbptr = ' ';
        lbptr++;
    }
    cprintf("  %s\n", linebuffer);
}
