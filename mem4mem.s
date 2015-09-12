	.file	"mem4mem.s"
.globl mem4mem_boards
.include "mfpic.s"
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################


dev_4mem0	=	0
dev_4mem1	=	dev_4mem0 + 2
dev_4mem2	=	dev_4mem0 + 4
dev_4mem3	=	dev_4mem0 + 6

.text
	.even
mem4mem_boards:
	.long KISS68030_IO + dev_4mem0
	.long KISS68030_IO + dev_4mem1
	.long KISS68030_IO + dev_4mem2
	.long KISS68030_IO + dev_4mem3
	.long -1
.text
	.even
.globl mem4mem_init00
mem4mem_init00:
	link.w	%a6,#0000
	movm.l	%d0/%a0-%a2,-(%sp)

	lea mem4mem_boards,%a2
mm0:
	move.l	(%a2)+,%a0
	move.l	%a0,%d0
	addq.l	#1,%d0
	jbeq	mm9

	move.l	#63,%d0
	lea.l	1(%a0),%a1
mm1:
	move.b	%d0,(%a1)	/* set address */
	nop
	st	(%a0)		/* set EMM_unmapped to data */
	nop
	dbra	%d0,mm1

	move.b	(%a0),%d0	/* read data, enable board */
	jbra	mm0

mm9:
	movm.l	(%sp)+,%d0/%a0-%a2
	unlk	%a6
	rts









