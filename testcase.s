	.file	"testcase.s"
.globl testcase
.text
	.even
testcase:
	move.l	(0x30,%pc,%a3),%d0
	move.l	0x30(%pc,%a3),%d0
	move.l	0x30(%pc,%a3*4),%d0
	move.l	0x3040(%pc,%a3),%d0
	move.l	0x3040(%pc,%a3*2),%d0
	move.l	0x304050(%pc,%a3),%d0
	move.l	0x304050(%pc,%a3*8),%d0

	move.l	0x3040(%a4*2),%d0
	move.l	([0x3040],0x5678),%d0

	move.l	([%a0,%d3*4],0x5678),%d0
	move.l	([0x3040,%a0,%d3*4],0x5678),%d0
	move.l	([0x304050,%a0],0x56789),%d0
	move.l	([0x3040,%a0],%d3*4,0x5678),%d0
	move.l	([0x3040,%a0],%d3.w*4,0x5678),%d0
	move.l	([0x3040,%a0],%a3.w*4,0x5678),%d0
	move.l	([0x3040,%a0],%d3.l*4,0x5678),%d0
	move.l	([0x3040,%a0],%d3,0x5678),%d0
#	move.l	(0x3040[%a0],%d3*4,0x5678),%d0
#	move.l	([0x3040,%a0],%d3*4)0x5678,%d0


	nop
	nop
	nop
	nop

