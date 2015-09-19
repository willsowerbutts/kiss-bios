#include "main68.h"

/* KISS-68030 memory sizing */
#define MEMORY_INCREMENT  ((64*1024)/sizeof(long)) /* test in chunks of 64KB */
#define MEMORY_TESTOFFSET (0xF800/sizeof(long))    /* test each chunk at 62KB offset */

void *memmax;               /* set by startup code according to 16/64M jumper position */
void *memtop = (long*)0;    /* determined by kiss68030_probe_ram() */

/* called from startup.s */
void kiss68030_probe_ram(void)
{
    volatile long *testptr;

    cprintf("RAM:");

    if(!memtop){
        /* we have to take care to avoid touching low memory here, else gcc generates "trap #7" */

        /* write labels out in reverse, so aliased areas end up with the lowest address */
        for(testptr = ((long*)memmax) - MEMORY_INCREMENT; testptr > 0; testptr -= MEMORY_INCREMENT)
            *(testptr + MEMORY_TESTOFFSET) = (long)testptr;

        data_cache_flush();

        /* read out the labels counting upwards */
        testptr = (long*)(MEMORY_INCREMENT * sizeof(long));
        while(testptr < (long*)memmax){
            if(*(testptr + MEMORY_TESTOFFSET) != (long)testptr)
                break;
            testptr += MEMORY_INCREMENT;
        }
        memtop = (void*)testptr;

        h_m_a = (long)memtop;
    }

    cprintf(" %d MB (0x%x)\n", (long)memtop >> 20, (long)memtop);
}

