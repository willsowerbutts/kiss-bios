/*  startup.s  */
/*
    Copyright (C) 2011-2015 John R. Coffman.
    Licensed for hobbyist use only.
***********************************************************************

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    in the file COPYING in the distribution directory along with this
    program.  If not, see <http://www.gnu.org/licenses/>.

**********************************************************************/
.include  "hardware.s"
.include  "mfpic.s"
.include  "ppi.s"
.include  "biostrap.s"

maxaddr     =   2*1024*1024
maxchip     =   32*1024
maxcount    =   maxaddr/maxchip
chiplong    =   maxchip/4
/* debugging lights and switches:               */
lites       =   0xFF + BOARD_BASE_IO    /* output only */
switches    =   lites           /* input only */


    .bss
    .comm   h_m_a,4
    .comm   mem_chain,4
    .comm   nvram,32
    .comm   debug,2


    .text
    .globl  location_zero

    .even
location_zero:
    .long   BOARD_INIT_SP       /* Reset:  initial SSP */
    .long   _start              /* Reset:  initial PC  */
vector_2:
    .long   exception_2         /* Bus Error     *** */
    .long   exception_3         /* Address Error *** */
    .long   exception_4         /* Illegal Instruction */
    .long   exception_5         /* Zero Divide */
    .long   exception_6         /* CHK instruction */
    .long   exception_7         /* TRAPV instruction */
    .long   exception_8         /* Privilege violation */
    .long   exception_9         /* Trace trap */
    .long   exception_10        /* Emulation 1010 */
    .long   exception_11        /* Emulation 1111 */
    .long   exception_12        /* reserved */
    .long   exception_13        /* reserved */
    .long   exception_14        /* Format error */
    .long   exception_15        /* Uninitialized interrupt error */

vector_16:
    .globl  spurious_return     /* return from PIC interrupts */
/* the eight PIC202 interrupts are here */

    .long   spurious_return     /* 0 */
    .long   spurious_return
    .long   spurious_return     /* 2 */
      .globl    interrupt_3_timer
    .long   interrupt_3_timer
    .long   spurious_return     /* 4 */
    .long   spurious_return
    .long   spurious_return     /* 6 */
    .long   spurious_return

vector_24:
/* auto-vectored interrupts (7 is NMI) */
    .long   exception_trap      /* 0 */
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap      /* 7 -- NMI */

vector_32:
/* the TRAP call vectors */
    .long   exception_trap      /*  0 */
    .long   exception_trap
    .long   exception_trap      /*  2 -- CP/M-68 BDOS calls */
    .long   exception_trap      /*  3 -- BIOS calls for CP/M-68 */
    .long   exception_trap      /*  4 */
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap      /*  7 */
      .globl    bios_trap_entry
    .long   bios_trap_entry     /*  8 -- put the BIOS calls here */
    .long   exception_trap      /*  9 */
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap      /* 12 */
    .long   exception_trap
    .long   exception_trap
    .long   exception_trap      /* 15 -- used by simulator */

vector_48:
/* unassigned exception traps */
.rept   16
    .long   exception_trap
.endr

vector_64:
/* unassigned exception traps for use by User OS */
.rept   192
    .long   exception_trap
.endr
vector_final:
# end of the exception vectors

    .globl  msg_welcome
mcrlf:
    .ascii  "\r\n\0"
msg_test1:
    .ascii  "To enter Setup type 's' during the memory test.\r\n"
    .asciz  "\rTesting and sizing memory ..."
msg_test2:
    .asciz  "\rFound memory from "
msg_to:
    .asciz  " to "

    .globl    bout,wout,dout,lout,nout

    .even

space:
    move.b  #0x20,%d0
    bra sio_put

crlf:
    lea mcrlf(%pc),%a0
    bra put_string

.if BOARD_KISS
    .globl data_cache_flush
data_cache_flush:
    /* WRS: need to read the documentation here -- can we write just a single bit
       to flush the data cache, or do we need to read and preserve the other bits? */
    movec.l %cacr,%d0
    or.w    #CACR_CD,%d0    /* clear data cache */
    movec.l %d0,%cacr
    rts
.endif


adout:
    # BOARD_KISS: addresses are 32-bit so we fall through into lout
.if BOARD_BABY
    # BOARD_BABY: 24-bit is sufficient
    swap    %d0
    jbsr    bout
    swap    %d0
    jbra    wout    
.endif
lout:
dout:
    swap    %d0
    jbsr    wout
    swap    %d0
wout:
    ror.w   #8,%d0
    jbsr    bout
    ror.w   #8,%d0
bout:
    ror.b   #4,%d0
    jbsr    nout
    ror.b   #4,%d0
nout:               /* write out the low nibble in ASCII */
    move.l  %d0,-(%sp)  /* push D0 */
    and.b   #0x0F,%d0   /* mask nibble */
    add.b   #0x30,%d0
    cmp.b   #0x3A,%d0   /* check for hex digit */
    blo.s   nout2
    add.b   #0x41-0x3A,%d0
nout2:
    bsr sio_put
    move.l  (%sp)+,%d0  /* pop D0 */
    rts

/* ------------------------------------------------------------------------ */

    .globl _start
_start:     /* RESET ENTRY VECTOR */
    or.w    #0x2700,%sr /* disable interrupts */

.if BOARD_KISS
    # KISS-68030 DRAM startup
    # Some DRAMs require this in the spec sheet. Maybe all
    # of them. This code should work for at least some sizes.
    # WRS: we need to review this code

    move.w  #8-1,%d2                /* outer counter */
DRAM_start00:
    lea     (0,%pc),%a3
DRAM_start:
    move.l  (%a3)+,%d0
    jbmi    DRAM_started

    move    %d0,%a0                 /* use A0 */
    move.w  #4096,%d1               /* count 4K addresses  */
DRAM_s0:
    move.l  (%a0)+,%d0              /* D0 is scratch */
    dbra    %d1,DRAM_s0             /* just do 4K read refreshes */

    lea     8(%a3),%a3              /* bump to next address */
    jbra    DRAM_start
DRAM_started:
    dbra    %d2,DRAM_start00        /* loop back 8 times */
.endif

# 4-Mem board init
    jbsr    mem4mem_init00

# Setup the Exception Vectors
    lea location_zero(%pc),%a1
    lea (0),%a2

n_vectors   =   (vector_final - location_zero) / 4
    move.w  #n_vectors-1,%d1
set_vector:
    move.l  (%a1)+,%d0
    move.l  %d0,(%a2)+
    dbra    %d1,set_vector

# Setup 68030 CPU
.if BOARD_KISS
    clr.l   %d2                 /* set Vector Base Register */
    movec.l %d2,%vbr
    move.l  #BOARD_CACR0,%d2    /* enable data & instruction caches */
    movec.l %d2,%cacr
.endif

# Setup for C language program: clear the .bss section
    lea.l   __bss_end,%a0
    move.l  %a0,%d2
    lea.l   __bss_start,%a1
    sub.l   %a1,%a0
    move.l  %a0,%d0
    jbra    zap_bss
zap_loop:
    clr.b   (%a1)+
zap_bss:
    dbra    %d0,zap_loop
    move.l  %d2,mem_chain /* heap (for malloc) starts immediately after .bss */

# Setup for C language program: copy .data from ROM to RAM
    lea.l   __data_end,%a0
    lea.l   __data_start,%a1    /* target in a1 */
    sub.l   %a1,%a0
    move.l  %a0,%d0             /* num bytes to copy in d0 */
    lea.l   __data_rom,%a2      /* source in a2 */
    jbra    copy_data
copy_data_loop:
    move.b  (%a2)+,(%a1)+
copy_data:
    dbra    %d0,copy_data_loop

    clr.b   debug               /* disable debug output */
    jbsr    get_nvram
    jbsr    sio_init
    jbsr    crlf

#  Print out the initial Welcome Message
    lea msg_welcome(%pc),%a0
    jbsr    put_string

.if BOARD_BABY
# Run the (mini-68K) memory test
    lea msg_test1(%pc),%a0
    jbsr    put_string

    lea.l   (maxaddr),%a0
    lea.l   (mem_ret,%pc),%a6
    jbra    memtest
mem_ret:
    move.l  %a5,h_m_a
    .globl  memtop
    move.l  %a5,memtop
    lea msg_test2(%pc),%a0
    jbsr    put_string

    sub.l   #maxchip,%a4

    move.l  %a4,%d0
    jbsr    adout

    lea msg_to(%pc),%a0
    jbsr    put_string
    move.l  %a5,%d0
    jbsr    adout
    jbsr    crlf
.endif

.if BOARD_KISS
# Determine the state of the 16/64M jumper:
# Attempt to access memory just over 64MB. If this succeeds, the board is
# configured to use 64MB modules. If it fails with a bus error (exception 2)
# the board is configured to use 16MB modules.
    move.l  8,%a1               /* stash the current trap handler */
    lea.l   (trap2_taken,%pc),%a2
    move.l  %a2,8               /* replace it */
    move.l  %sp,%a0             /* save SP */
    move.l  #0x4000000,%a2      /* assume 4 x 16MB modules = 64MB max */
    move.l  (%a2),%d0           /* attempt to read beyond this limit */
    move.l  #0x10000000,%a2     /* success - 4 x 64MB modules = 256MB max */
trap2_taken:
    move.l  %a0,%sp             /* oh dear, we took the trap. restore SP, carry on. */
    .globl memmax               /* it seems no other clean-up is required? */
    move.l  %a2,memmax          /* store max possible memory size */
    move.l  %a1,8               /* restore previous trap handler */
    .globl  kiss68030_probe_ram /* C comes to the rescue of the lazy programmer */
    jsr     kiss68030_probe_ram /* sets up memtop, h_m_a for us */
.endif

# Setup the NS32202 interrupt controller (PIC)
    .globl  ns202_init2
    jbsr    ns202_init2

# Enable interrupts
    and.w   #~0x0700,%sr

# Check for S keypress
    jbsr    sio_get
    move.l  %d0,-(%sp)          /* push argument, possible an 's' */
    .globl  setup
    jsr setup
    add.l   #4,%sp              /* discard argument */

    .globl  configure
    jsr configure               /* go configure based on NVRAM */
    
    .globl  main68
    jsr main68                  /* call main C language program */
/* any return from MAIN comes here */
        .globl  _exit
_exit:
    move.l  %d0,-(%sp)
__exit:             /* return code is at top of stack */
    pea halt_msg(%pc)
    jbsr    cprintf
    add.l   #8,%sp
/* now STOP, we are all done here */
stop0:  stop    #0x2701
    jbra    stop0       /* loop on NMI */
/* only a hardware RESET gets us beyond here */

        .globl  exit
exit:   add.l   #4,%sp      /* remove return address */
    jbra    __exit      /* leave return code on stack */


halt_msg:
    .ascii  "\nExit code = 0x%02x\n"
    .asciz  "BIOS: machine halted.\n"

    .even
exception_2:
    move.w  #2,-(%sp)
    jbra    exception_AB
exception_3:
    move.w  #3,-(%sp)
    jbra    exception_AB
exception_4:
    move.w  #4,-(%sp)
    jbra    exception
exception_5:
    move.w  #5,-(%sp)
    jbra    exception
exception_6:
    move.w  #6,-(%sp)
    jbra    exception
exception_7:
    move.w  #7,-(%sp)
    jbra    exception
exception_8:
    move.w  #8,-(%sp)
    jbra    exception
exception_9:
    move.w  #9,-(%sp)
    jbra    exception
exception_10:
    move.w  #10,-(%sp)
    jbra    exception
exception_11:
    move.w  #11,-(%sp)
    jbra    exception
exception_12:
    move.w  #12,-(%sp)
    jbra    exception
exception_13:
    move.w  #13,-(%sp)
    jbra    exception
exception_14:
    move.w  #14,-(%sp)
    jbra    exception
exception_15:
    move.w  #15,-(%sp)
    jbra    exception

msg_except:
    .ascii  "Exception 0x\0"

fmtregs:
    .ascii  "\nSR %04hx\n"
    .ascii  "D0 %08lx   "
    .ascii  "D1 %08lx   "
    .ascii  "D2 %08lx   "
    .ascii  "D3 %08lx\n"
    .ascii  "D4 %08lx   "
    .ascii  "D5 %08lx   "
    .ascii  "D6 %08lx   "
    .ascii  "D7 %08lx\n"
    .ascii  "A0 %08lx   "
    .ascii  "A1 %08lx   "
    .ascii  "A2 %08lx   "
    .ascii  "A3 %08lx\n"
    .ascii  "A4 %08lx   "
    .ascii  "A5 %08lx   "
    .ascii  "A6 %08lx   "
    .asciz  "SP %08lx\n"

fmtstack:
    .asciz  " %08lx %08lx %08lx %08lx %08lx %08lx\n"


    .even
exception_AB:
    movm.l  %d0-%d7/%a0-%a7,-(%sp)
    add.l   #2,60(%sp)      /* compensate */
/***    move.w  %sr,%d0     ***/
    move.w  66(%sp),%d0     /* SR at time of trap */
    move.l  %d0,-(%sp)
    pea fmtregs(%pc)
    jsr cprintf
    add.l   #4*18,%sp
    move.w  (%sp)+,%d7

    lea msg_except(%pc),%a0
    jbsr    put_string
    move.b  %d7,%d0
    jbsr    bout
    jbsr    crlf
# end of  Exception 0x??
    move.l  %sp,%d0
    jbsr    lout
    move.b  #':',%d0
    jbsr    sio_put
    jbsr    space

    move.w  (%sp)+,%d0
    jbsr    wout
    jbsr    space

    move.l  (%sp),%d0
    jbsr    lout
    jbsr    space

    move.w  (%sp)+,%d0
    jbsr    wout
    jbra    econtinue

exception:
    movm.l  %d0-%d7/%a0-%a7,-(%sp)
    add.l   #2,60(%sp)          /* compensate */

### move.w  %sr,%d0
    move.w  66(%sp),%d0     /* SR at time of trap */
    move.l  %d0,-(%sp)
    pea fmtregs(%pc)
    jsr cprintf
    add.l   #4*18,%sp
    move.w  (%sp)+,%d7

    lea msg_except(%pc),%a0
    jbsr    put_string
    move.b  %d7,%d0
    jbsr    bout
    jbsr    crlf
# end of  Exception 0x??
    move.l  %sp,%d0
    jbsr    lout
    move.b  #':',%d0
    jbsr    sio_put
econtinue:
    jbsr    space
    move.w  (%sp)+,%d0
    jbsr    wout
.if 1
    pea fmtstack(%pc)
    jsr cprintf
    add.l   #4,%sp
.else
    jbsr    space
    move.l  (%sp),%d0
    jbsr    lout
    jbsr    crlf
# end of line 1

.endif
    move.l  (%sp)+,%a0
    lea.l   (-12,%a0),%a0
    move.l  %a0,%d0
    jbsr    lout
    move.b  #':',%d0
    jbsr    sio_put
    jbsr    space

    move.w  #5,%d1
eloop:  
    move.w  (%a0)+,%d0
    jbsr    wout
    jbsr    space
    dbra    %d1,eloop

    move.b  #':',%d0
    jbsr    sio_put
    jbsr    space

    move.w  #3,%d1
eloop2:
    move.w  (%a0)+,%d0
    jbsr    wout
    jbsr    space
    dbra    %d1,eloop2
    jbsr    crlf

    jbra    exception_stop

exception_trap:
/*  former write to the Lites here */
exception_stop:
    stop    #0x2701
    jbra    exception_trap


# Swap all the bytes in a long

    .even
    .globl  bswap
bswap:
lswap:
    move.l  4(%sp),%d0
    ror.w   #8,%d0
    swap    %d0
    ror.w   #8,%d0
    rts

# Swap the bytes in a short
    .even
    .globl  wswap
wswap:
    move.w  4+2(%sp),%d0
    ror.w   #8,%d0
    rts

/* Run in User/Supervisor Mode
/*
/*  void _run_us_mode(word mode, (void*)pc);
        mode == 0 user mode
        mode >= 1 supervisor mode
        
*/
    .globl  _run_us_mode    
_run_us_mode:
    move.l  h_m_a,%a0
    move.l  %a0,%usp        /* set user stack pointer */
    move.l  (%sp)+,%d0      /* pop the return address */
    move.l  (%sp)+,%d0      /* pop the mode option */
    or.w    %d0,%d0
    jbeq    _user_mode
    or.w    #0x2000,%d0     /* set supervisor mode */
_user_mode:
    move.w  %d0,-(%sp)      /* S_bit = "mode", CCR = 0  */
    clr.l   %d0
    clr.l   %d1
    clr.l   %d2
    clr.l   %d3
    clr.l   %d4
    clr.l   %d5
    clr.l   %d6
    clr.l   %d7
    move.l  %d7,%a0
    move.l  %d7,%a1
    move.l  %d7,%a2
    move.l  %d7,%a3
    move.l  %d7,%a4
    move.l  %d7,%a5
    move.l  %d7,%a6
    rte             /* load SR + PC  */
/* user mode program must terminate with an EXIT bios call */
    


/* the below is for debugging */

dwdump:
    move.b  #' ',%d0
    jbsr    sio_put
    move.l  (%a0)+,%d0
    jbsr    dout
    rts

    .globl  stackdump
stackdump:
    move.l  %d0,-(%sp)
    move.l  %a0,-(%sp)

    lea 12(%sp),%a0
    move    %a0,%d0
    jbsr    dout
    move.b  #':',%d0
    jbsr    sio_put

    jbsr    dwdump
    jbsr    dwdump
    jbsr    dwdump
    jbsr    dwdump
    jbsr    dwdump
    jbsr    dwdump
    jbsr    crlf

    move.l  (%sp)+,%a0
    move.l  (%sp)+,%d0
    rts

    .globl  regdump
regdump:
    movm.l  %d0/%d1/%a0/%a1,-(%sp)

    movm.l  %d0-%d7/%a0-%a7,-(%sp)
    move.w  %sr,%d0
    movm.l  %d0,-(%sp)
    pea fmtregs(%pc)
    jsr cprintf
    add.l   #4*18,%sp

    movm.l  (%sp)+,%d0/%d1/%a0/%a1
    rts

############################################################
############################################################
############################################################
############################################################
############################################################
############################################################

.include  "memtest0.s"      
############################################################

    .end


