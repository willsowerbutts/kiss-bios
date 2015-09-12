Four KISS-68030 test programs.  
=====================================================================
TEST4.BIN -- tests 64Mb/128Mb/192Mb/256Mb DRAM configurations.
		(the 16/64 board jumper must be installed)
TEST3.BIN -- tests 16Mb/32Mb/48Mb/64Mb DRAM configurations.
		(the 16/64 board jumper must be open)

The two tests above perform the same tests, but just on different
address ranges.
16Mb & 64Mb SIMMs are single sided.
32Mb & 128Mb SIMMs are double sided.
The two size ranges, 16/32Mb cf. 64/128Mb, may not be mixed.

**NEW** The external I/O bus is tested at the start of either test program. 
The UART Reset condition is tested for.  If the UART cannot be found,
the red LED will flash 5 times before the program halts.  If the UART
is found, the type of UART (8250..16750) is detected & reported.
=====================================================================
TEST3.BIN -- performs exactly the same tests as TEST2 (below), but
separates the results from the long word test (Aligned/Unaligned)
from the Byte & MOVEM test.

READ BELOW for setup instructions:
=====================================================================

TEST2.BIN -- is derived from TEST1.BIN but is not entirely the same.
However, the stringent MOVEM test is the same.  The file should be
burned to a 128K or 512K Flash memory chip.  The resulting ROM is 
bootable.

The MF/PIC board is used for UART output at 9600 bps, 8n2.  The board
needs to be set to device 0x4?, placing the UART at 0x48..0x4F.
Left to right, or reading upward, device jumpers are ON,ON,OFF,ON.

The KISS board under test requires 32K of functioning SRAM.  The
DRAM test will examine 1..4 banks of 16Mb DRAM.  Single sided DRAM
strips allow for 16..32Mb of memory.  Up to 64Mb of memory may be
installed if double sides SIMMs are used.

Slot A, nearest to the CPU, is filled first.  If SIMMs of different
sizes are used, the largest (32Mb) is placed in slot A.  Slot B
may be left empty, or may have a SIMM of equal or smaller size
installed.

The only memory sizes tested are 16Mb, 32Mb, 48Mb, or 64Mb.  The
memory speed must be 60ns or faster.  Both EDO and FPM memory
are acceptable.  Parity is not used, so both Parity and non-Parity
SIMMs are acceptable.

=====================================================================

TEST2:  flash the red STOP LED twice.
If SRAM is not found, or tests bad, the LED is flashed six more times
and the test halts (steady RED LED).

If SRAM is okay, a message is printed.  Then the acid MOVEM test is
performed.  The test halts if SRAM fails, after a message is printed.

Banks of DRAM are then detected, and the series of aligned and
unaligned memory references are tested.  Each memory span has the 
address range under test printed first:  START, END.  The ending
address is actually the first byte NOT under test.  All reads and
writes are long words, aligned or unaligned according to the 
addresses printed.  It this test is good, then the individual Byte
tests and the acid MOVEM test are performed.  The resulting "pass" or
"fail" status of the two tests is then reported.

The testing proceeds through a table of pre-assigned addresses, and
successful passes through this series of tests are counted.

TEST2 runs until stopped manually.

=====================================================================

TEST1.BIN -- requires the 8-LED/8-switches board for debug output.
Without the specialized debugging board, you will see no output.
Don't waste you time with this binary.

=====================================================================
--John Coffman
<johninsd@gmail.com>
03-Aug-2015
04-Aug-2015

