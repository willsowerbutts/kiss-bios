    .globl begin

begin:
    move.l  #2,%d0
    move.l  #0x33,%d1
    trap    #8
    bra     begin
