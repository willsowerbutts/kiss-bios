	.file	"disasm.c"
gcc2_compiled.:
__gnu_compiled_c:
.globl optab
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

optab:
	.word -1
	.word 572
	.word 3
	.long .LC0
	.word -1
	.word 636
	.word 3
	.long .LC1
	.word -1
	.word 2620
	.word 3
	.long .LC2
	.word -1
	.word 2684
	.word 3
	.long .LC3
	.word -1
	.word 19194
	.word 0
	.long .LC4
	.word -1
	.word 19195
	.word 0
	.long .LC4
	.word -1
	.word 19196
	.word 0
	.long .LC4
	.word -1
	.word 20081
	.word 0
	.long .LC5
	.word -1
	.word 60
	.word 3
	.long .LC6
	.word -1
	.word 124
	.word 3
	.long .LC7
	.word -1
	.word 20080
	.word 0
	.long .LC8
	.word -1
	.word 20084
	.word 21
	.long .LC9
	.word -1
	.word 20083
	.word 0
	.long .LC10
	.word -1
	.word 20087
	.word 0
	.long .LC11
	.word -1
	.word 20085
	.word 0
	.long .LC12
	.word -1
	.word 20082
	.word 21
	.long .LC13
	.word -1
	.word 20086
	.word 0
	.long .LC14
	.word -2
	.word 20090
	.word 24
	.long .LC15
	.word -8
	.word 20680
	.word 12
	.long .LC16
	.word -8
	.word 20936
	.word 12
	.long .LC17
	.word -8
	.word 21192
	.word 12
	.long .LC18
	.word -8
	.word 21448
	.word 12
	.long .LC19
	.word -8
	.word 21704
	.word 12
	.long .LC20
	.word -8
	.word 21960
	.word 12
	.long .LC21
	.word -8
	.word 22216
	.word 12
	.long .LC22
	.word -8
	.word 22472
	.word 12
	.long .LC23
	.word -8
	.word 22728
	.word 12
	.long .LC24
	.word -8
	.word 22984
	.word 12
	.long .LC25
	.word -8
	.word 23240
	.word 12
	.long .LC26
	.word -8
	.word 23496
	.word 12
	.long .LC27
	.word -8
	.word 23752
	.word 12
	.long .LC28
	.word -8
	.word 24008
	.word 12
	.long .LC29
	.word -8
	.word 24264
	.word 12
	.long .LC30
	.word -8
	.word 24520
	.word 12
	.long .LC31
	.word -8
	.word 18560
	.word 14
	.long .LC32
	.word -8
	.word 18624
	.word 14
	.long .LC33
	.word -8
	.word 20048
	.word 15
	.long .LC34
	.word -8
	.word 20064
	.word 17
	.long .LC35
	.word -8
	.word 20072
	.word 17
	.long .LC35
	.word -8
	.word 18496
	.word 22
	.long .LC36
	.word -8
	.word 20056
	.word 22
	.long .LC37
	.word -16
	.word 20032
	.word 23
	.long .LC38
	.word -64
	.word 1536
	.word 3
	.long .LC39
	.word -64
	.word 1600
	.word 3
	.long .LC40
	.word -64
	.word 1664
	.word 3
	.long .LC41
	.word -64
	.word 512
	.word 3
	.long .LC0
	.word -64
	.word 576
	.word 3
	.long .LC1
	.word -64
	.word 640
	.word 3
	.long .LC42
	.word -64
	.word -7744
	.word 7
	.long .LC43
	.word -64
	.word -8000
	.word 7
	.long .LC44
	.word -64
	.word 2112
	.word 10
	.long .LC45
	.word -64
	.word 2176
	.word 10
	.long .LC46
	.word -64
	.word 2240
	.word 10
	.long .LC47
	.word -64
	.word 2048
	.word 10
	.long .LC48
	.word -64
	.word 16896
	.word 7
	.long .LC49
	.word -64
	.word 16960
	.word 7
	.long .LC50
	.word -64
	.word 17024
	.word 7
	.long .LC51
	.word -64
	.word 3072
	.word 3
	.long .LC52
	.word -64
	.word 3136
	.word 3
	.long .LC53
	.word -64
	.word 3200
	.word 3
	.long .LC54
	.word -64
	.word 2560
	.word 3
	.long .LC2
	.word -64
	.word 2624
	.word 3
	.long .LC3
	.word -64
	.word 2688
	.word 3
	.long .LC55
	.word -64
	.word 20160
	.word 7
	.long .LC56
	.word -64
	.word 20096
	.word 7
	.long .LC57
	.word -64
	.word -7232
	.word 7
	.long .LC58
	.word -64
	.word -7488
	.word 7
	.long .LC59
	.word -64
	.word 17088
	.word 5
	.long .LC60
	.word -64
	.word 17600
	.word 5
	.long .LC60
	.word -64
	.word 18112
	.word 5
	.long .LC60
	.word -64
	.word 16576
	.word 5
	.long .LC60
	.word -64
	.word 19584
	.word 18
	.long .LC61
	.word -64
	.word 19648
	.word 18
	.long .LC62
	.word -64
	.word 18560
	.word 18
	.long .LC61
	.word -64
	.word 18624
	.word 18
	.long .LC62
	.word -64
	.word 3584
	.word 25
	.long .LC63
	.word -64
	.word 3648
	.word 25
	.long .LC64
	.word -64
	.word 3712
	.word 25
	.long .LC65
	.word -64
	.word 18432
	.word 7
	.long .LC66
	.word -64
	.word 17408
	.word 7
	.long .LC67
	.word -64
	.word 17472
	.word 7
	.long .LC68
	.word -64
	.word 17536
	.word 7
	.long .LC69
	.word -64
	.word 16384
	.word 7
	.long .LC70
	.word -64
	.word 16448
	.word 7
	.long .LC71
	.word -64
	.word 16512
	.word 7
	.long .LC72
	.word -64
	.word 17920
	.word 7
	.long .LC73
	.word -64
	.word 17984
	.word 7
	.long .LC74
	.word -64
	.word 18048
	.word 7
	.long .LC75
	.word -64
	.word 0
	.word 3
	.long .LC6
	.word -64
	.word 64
	.word 3
	.long .LC7
	.word -64
	.word 128
	.word 3
	.long .LC76
	.word -64
	.word 18496
	.word 7
	.long .LC77
	.word -64
	.word -6208
	.word 7
	.long .LC78
	.word -64
	.word -6464
	.word 7
	.long .LC79
	.word -64
	.word -6720
	.word 7
	.long .LC80
	.word -64
	.word -6976
	.word 7
	.long .LC81
	.word -64
	.word 20672
	.word 7
	.long .LC82
	.word -64
	.word 20928
	.word 7
	.long .LC83
	.word -64
	.word 21184
	.word 7
	.long .LC84
	.word -64
	.word 21440
	.word 7
	.long .LC85
	.word -64
	.word 21696
	.word 7
	.long .LC86
	.word -64
	.word 21952
	.word 7
	.long .LC87
	.word -64
	.word 22208
	.word 7
	.long .LC88
	.word -64
	.word 22464
	.word 7
	.long .LC89
	.word -64
	.word 22720
	.word 7
	.long .LC90
	.word -64
	.word 22976
	.word 7
	.long .LC91
	.word -64
	.word 23232
	.word 7
	.long .LC92
	.word -64
	.word 23488
	.word 7
	.long .LC93
	.word -64
	.word 23744
	.word 7
	.long .LC94
	.word -64
	.word 24000
	.word 7
	.long .LC95
	.word -64
	.word 24256
	.word 7
	.long .LC96
	.word -64
	.word 24512
	.word 7
	.long .LC97
	.word -64
	.word 1024
	.word 3
	.long .LC98
	.word -64
	.word 1088
	.word 3
	.long .LC99
	.word -64
	.word 1152
	.word 3
	.long .LC100
	.word -64
	.word 19136
	.word 7
	.long .LC101
	.word -64
	.word 18944
	.word 7
	.long .LC102
	.word -64
	.word 19008
	.word 7
	.long .LC103
	.word -64
	.word 19072
	.word 7
	.long .LC104
	.word -256
	.word 25088
	.word 8
	.long .LC105
	.word -256
	.word 25344
	.word 8
	.long .LC106
	.word -256
	.word 25600
	.word 8
	.long .LC107
	.word -256
	.word 25856
	.word 8
	.long .LC108
	.word -256
	.word 26112
	.word 8
	.long .LC109
	.word -256
	.word 26368
	.word 8
	.long .LC110
	.word -256
	.word 26624
	.word 8
	.long .LC111
	.word -256
	.word 26880
	.word 8
	.long .LC112
	.word -256
	.word 27136
	.word 8
	.long .LC113
	.word -256
	.word 27392
	.word 8
	.long .LC114
	.word -256
	.word 27648
	.word 8
	.long .LC115
	.word -256
	.word 27904
	.word 8
	.long .LC116
	.word -256
	.word 28160
	.word 8
	.long .LC117
	.word -256
	.word 28416
	.word 8
	.long .LC118
	.word -256
	.word 24576
	.word 8
	.long .LC119
	.word -256
	.word 24832
	.word 8
	.long .LC120
	.word -3592
	.word -16128
	.word 1
	.long .LC121
	.word -3592
	.word -16120
	.word 1
	.long .LC121
	.word -3592
	.word -12032
	.word 1
	.long .LC122
	.word -3592
	.word -11968
	.word 1
	.long .LC123
	.word -3592
	.word -11904
	.word 1
	.long .LC124
	.word -3592
	.word -12024
	.word 1
	.long .LC122
	.word -3592
	.word -11960
	.word 1
	.long .LC123
	.word -3592
	.word -11896
	.word 1
	.long .LC124
	.word -3592
	.word -16064
	.word 13
	.long .LC125
	.word -3592
	.word -16056
	.word 13
	.long .LC125
	.word -3592
	.word -15992
	.word 13
	.long .LC125
	.word -3592
	.word -7936
	.word 6
	.long .LC126
	.word -3592
	.word -7872
	.word 6
	.long .LC127
	.word -3592
	.word -7808
	.word 6
	.long .LC128
	.word -3592
	.word -7904
	.word 6
	.long .LC126
	.word -3592
	.word -7840
	.word 6
	.long .LC127
	.word -3592
	.word -7776
	.word 6
	.long .LC128
	.word -3592
	.word -8192
	.word 6
	.long .LC129
	.word -3592
	.word -8128
	.word 6
	.long .LC130
	.word -3592
	.word -8064
	.word 6
	.long .LC131
	.word -3592
	.word -8160
	.word 6
	.long .LC129
	.word -3592
	.word -8096
	.word 6
	.long .LC130
	.word -3592
	.word -8032
	.word 6
	.long .LC131
	.word -3592
	.word -20216
	.word 11
	.long .LC132
	.word -3592
	.word -20152
	.word 11
	.long .LC133
	.word -3592
	.word -20088
	.word 11
	.long .LC134
	.word -3592
	.word -7928
	.word 6
	.long .LC135
	.word -3592
	.word -7864
	.word 6
	.long .LC136
	.word -3592
	.word -7800
	.word 6
	.long .LC137
	.word -3592
	.word -7896
	.word 6
	.long .LC135
	.word -3592
	.word -7832
	.word 6
	.long .LC136
	.word -3592
	.word -7768
	.word 6
	.long .LC137
	.word -3592
	.word -8184
	.word 6
	.long .LC138
	.word -3592
	.word -8120
	.word 6
	.long .LC139
	.word -3592
	.word -8056
	.word 6
	.long .LC140
	.word -3592
	.word -8152
	.word 6
	.long .LC138
	.word -3592
	.word -8088
	.word 6
	.long .LC139
	.word -3592
	.word -8024
	.word 6
	.long .LC140
	.word -3592
	.word 264
	.word 19
	.long .LC141
	.word -3592
	.word 328
	.word 19
	.long .LC142
	.word -3592
	.word 392
	.word 19
	.long .LC141
	.word -3592
	.word 456
	.word 19
	.long .LC142
	.word -3592
	.word -7912
	.word 6
	.long .LC143
	.word -3592
	.word -7848
	.word 6
	.long .LC144
	.word -3592
	.word -7784
	.word 6
	.long .LC145
	.word -3592
	.word -7880
	.word 6
	.long .LC143
	.word -3592
	.word -7816
	.word 6
	.long .LC144
	.word -3592
	.word -7752
	.word 6
	.long .LC145
	.word -3592
	.word -8168
	.word 6
	.long .LC146
	.word -3592
	.word -8104
	.word 6
	.long .LC147
	.word -3592
	.word -8040
	.word 6
	.long .LC148
	.word -3592
	.word -8136
	.word 6
	.long .LC146
	.word -3592
	.word -8072
	.word 6
	.long .LC147
	.word -3592
	.word -8008
	.word 6
	.long .LC148
	.word -3592
	.word -7920
	.word 6
	.long .LC149
	.word -3592
	.word -7856
	.word 6
	.long .LC150
	.word -3592
	.word -7792
	.word 6
	.long .LC151
	.word -3592
	.word -7888
	.word 6
	.long .LC149
	.word -3592
	.word -7824
	.word 6
	.long .LC150
	.word -3592
	.word -7760
	.word 6
	.long .LC151
	.word -3592
	.word -8176
	.word 6
	.long .LC152
	.word -3592
	.word -8112
	.word 6
	.long .LC153
	.word -3592
	.word -8048
	.word 6
	.long .LC154
	.word -3592
	.word -8144
	.word 6
	.long .LC152
	.word -3592
	.word -8080
	.word 6
	.long .LC153
	.word -3592
	.word -8016
	.word 6
	.long .LC154
	.word -3592
	.word -32512
	.word 1
	.long .LC155
	.word -3592
	.word -32504
	.word 1
	.long .LC155
	.word -3592
	.word -28416
	.word 1
	.long .LC156
	.word -3592
	.word -28352
	.word 1
	.long .LC157
	.word -3592
	.word -28288
	.word 1
	.long .LC158
	.word -3592
	.word -28408
	.word 1
	.long .LC156
	.word -3592
	.word -28344
	.word 1
	.long .LC157
	.word -3592
	.word -28280
	.word 1
	.long .LC158
	.word -3648
	.word -12288
	.word 2
	.long .LC159
	.word -3648
	.word -12224
	.word 2
	.long .LC160
	.word -3648
	.word -12160
	.word 2
	.long .LC161
	.word -3648
	.word -12032
	.word 2
	.long .LC159
	.word -3648
	.word -11968
	.word 2
	.long .LC160
	.word -3648
	.word -11904
	.word 2
	.long .LC161
	.word -3648
	.word -12096
	.word 2
	.long .LC162
	.word -3648
	.word -11840
	.word 2
	.long .LC163
	.word -3648
	.word 20480
	.word 4
	.long .LC164
	.word -3648
	.word 20544
	.word 4
	.long .LC165
	.word -3648
	.word 20608
	.word 4
	.long .LC166
	.word -3648
	.word -16384
	.word 2
	.long .LC167
	.word -3648
	.word -16320
	.word 2
	.long .LC168
	.word -3648
	.word -16256
	.word 2
	.long .LC169
	.word -3648
	.word -16128
	.word 2
	.long .LC167
	.word -3648
	.word -16064
	.word 2
	.long .LC168
	.word -3648
	.word -16000
	.word 2
	.long .LC169
	.word -3648
	.word 320
	.word 10
	.long .LC45
	.word -3648
	.word 384
	.word 10
	.long .LC46
	.word -3648
	.word 448
	.word 10
	.long .LC47
	.word -3648
	.word 256
	.word 10
	.long .LC48
	.word -3648
	.word 16768
	.word 9
	.long .LC170
	.word -3648
	.word -20480
	.word 2
	.long .LC171
	.word -3648
	.word -20416
	.word 2
	.long .LC172
	.word -3648
	.word -20352
	.word 2
	.long .LC173
	.word -3648
	.word -20288
	.word 2
	.long .LC174
	.word -3648
	.word -20032
	.word 2
	.long .LC175
	.word -3648
	.word -32320
	.word 9
	.long .LC176
	.word -3648
	.word -32576
	.word 9
	.long .LC177
	.word -3648
	.word -20224
	.word 2
	.long .LC178
	.word -3648
	.word -20160
	.word 2
	.long .LC179
	.word -3648
	.word -20096
	.word 2
	.long .LC180
	.word -3648
	.word 16832
	.word 2
	.long .LC181
	.word -3648
	.word 12352
	.word 16
	.long .LC182
	.word -3648
	.word 8256
	.word 16
	.long .LC183
	.word -3648
	.word -15936
	.word 9
	.long .LC184
	.word -3648
	.word -16192
	.word 9
	.long .LC185
	.word -3648
	.word -32768
	.word 2
	.long .LC186
	.word -3648
	.word -32704
	.word 2
	.long .LC187
	.word -3648
	.word -32640
	.word 2
	.long .LC188
	.word -3648
	.word -32512
	.word 2
	.long .LC186
	.word -3648
	.word -32448
	.word 2
	.long .LC187
	.word -3648
	.word -32384
	.word 2
	.long .LC188
	.word -3648
	.word -28672
	.word 2
	.long .LC189
	.word -3648
	.word -28608
	.word 2
	.long .LC190
	.word -3648
	.word -28544
	.word 2
	.long .LC191
	.word -3648
	.word -28416
	.word 2
	.long .LC189
	.word -3648
	.word -28352
	.word 2
	.long .LC190
	.word -3648
	.word -28288
	.word 2
	.long .LC191
	.word -3648
	.word -28480
	.word 2
	.long .LC192
	.word -3648
	.word -28224
	.word 2
	.long .LC193
	.word -3648
	.word 20736
	.word 4
	.long .LC194
	.word -3648
	.word 20800
	.word 4
	.long .LC195
	.word -3648
	.word 20864
	.word 4
	.long .LC196
	.word -3840
	.word 28672
	.word 20
	.long .LC197
	.word -4096
	.word 4096
	.word 16
	.long .LC198
	.word -4096
	.word 12288
	.word 16
	.long .LC60
	.word -4096
	.word 8192
	.word 16
	.long .LC35
	.word 0
	.word 0
	.word 0
	.long .LC199
.LC199:
	.ascii "*unknown instruction*\0"
.LC198:
	.ascii "move.b\0"
.LC197:
	.ascii "moveq.l\0"
.LC196:
	.ascii "subq.l\0"
.LC195:
	.ascii "subq.w\0"
.LC194:
	.ascii "subq.b\0"
.LC193:
	.ascii "suba.l\0"
.LC192:
	.ascii "suba.w\0"
.LC191:
	.ascii "sub.l\0"
.LC190:
	.ascii "sub.w\0"
.LC189:
	.ascii "sub.b\0"
.LC188:
	.ascii "or.l\0"
.LC187:
	.ascii "or.w\0"
.LC186:
	.ascii "or.b\0"
.LC185:
	.ascii "mulu\0"
.LC184:
	.ascii "muls\0"
.LC183:
	.ascii "movea.l\0"
.LC182:
	.ascii "movea.w\0"
.LC181:
	.ascii "lea\0"
.LC180:
	.ascii "eor.l\0"
.LC179:
	.ascii "eor.w\0"
.LC178:
	.ascii "eor.b\0"
.LC177:
	.ascii "divu\0"
.LC176:
	.ascii "divs\0"
.LC175:
	.ascii "cmpa.l\0"
.LC174:
	.ascii "cmpa.w\0"
.LC173:
	.ascii "cmp.l\0"
.LC172:
	.ascii "cmp.w\0"
.LC171:
	.ascii "cmp.b\0"
.LC170:
	.ascii "chk\0"
.LC169:
	.ascii "and.l\0"
.LC168:
	.ascii "and.w\0"
.LC167:
	.ascii "and.b\0"
.LC166:
	.ascii "addq.l\0"
.LC165:
	.ascii "addq.w\0"
.LC164:
	.ascii "addq.b\0"
.LC163:
	.ascii "adda.l\0"
.LC162:
	.ascii "adda.w\0"
.LC161:
	.ascii "add.l\0"
.LC160:
	.ascii "add.w\0"
.LC159:
	.ascii "add.b\0"
.LC158:
	.ascii "subx.l\0"
.LC157:
	.ascii "subx.w\0"
.LC156:
	.ascii "subx.b\0"
.LC155:
	.ascii "sbcd\0"
.LC154:
	.ascii "roxr.l\0"
.LC153:
	.ascii "roxr.w\0"
.LC152:
	.ascii "roxr.b\0"
.LC151:
	.ascii "roxl.l\0"
.LC150:
	.ascii "roxl.w\0"
.LC149:
	.ascii "roxl.b\0"
.LC148:
	.ascii "ror.l\0"
.LC147:
	.ascii "ror.w\0"
.LC146:
	.ascii "ror.b\0"
.LC145:
	.ascii "rol.l\0"
.LC144:
	.ascii "rol.w\0"
.LC143:
	.ascii "rol.b\0"
.LC142:
	.ascii "movep.l\0"
.LC141:
	.ascii "movep.w\0"
.LC140:
	.ascii "lsr.l\0"
.LC139:
	.ascii "lsr.w\0"
.LC138:
	.ascii "lsr.b\0"
.LC137:
	.ascii "lsl.l\0"
.LC136:
	.ascii "lsl.w\0"
.LC135:
	.ascii "lsl.b\0"
.LC134:
	.ascii "cmpm.l\0"
.LC133:
	.ascii "cmpm.w\0"
.LC132:
	.ascii "cmpm.b\0"
.LC131:
	.ascii "asr.l\0"
.LC130:
	.ascii "asr.w\0"
.LC129:
	.ascii "asr.b\0"
.LC128:
	.ascii "asl.l\0"
.LC127:
	.ascii "asl.w\0"
.LC126:
	.ascii "asl.b\0"
.LC125:
	.ascii "exg\0"
.LC124:
	.ascii "addx.l\0"
.LC123:
	.ascii "addx.w\0"
.LC122:
	.ascii "addx.b\0"
.LC121:
	.ascii "abcd\0"
.LC120:
	.ascii "bsr\0"
.LC119:
	.ascii "bra\0"
.LC118:
	.ascii "ble\0"
.LC117:
	.ascii "bgt\0"
.LC116:
	.ascii "blt\0"
.LC115:
	.ascii "bge\0"
.LC114:
	.ascii "bmi\0"
.LC113:
	.ascii "bpl\0"
.LC112:
	.ascii "bvs\0"
.LC111:
	.ascii "bvc\0"
.LC110:
	.ascii "beq\0"
.LC109:
	.ascii "bne\0"
.LC108:
	.ascii "bcs\0"
.LC107:
	.ascii "bcc\0"
.LC106:
	.ascii "bls\0"
.LC105:
	.ascii "bhi\0"
.LC104:
	.ascii "tst.l\0"
.LC103:
	.ascii "tst.w\0"
.LC102:
	.ascii "tst.b\0"
.LC101:
	.ascii "tas.b\0"
.LC100:
	.ascii "subi.l\0"
.LC99:
	.ascii "subi.w\0"
.LC98:
	.ascii "subi.b\0"
.LC97:
	.ascii "sle\0"
.LC96:
	.ascii "sgt\0"
.LC95:
	.ascii "slt\0"
.LC94:
	.ascii "sge\0"
.LC93:
	.ascii "smi\0"
.LC92:
	.ascii "spl\0"
.LC91:
	.ascii "svs\0"
.LC90:
	.ascii "svc\0"
.LC89:
	.ascii "seq\0"
.LC88:
	.ascii "sne\0"
.LC87:
	.ascii "scs\0"
.LC86:
	.ascii "scc\0"
.LC85:
	.ascii "sls\0"
.LC84:
	.ascii "shi\0"
.LC83:
	.ascii "sf\0"
.LC82:
	.ascii "st\0"
.LC81:
	.ascii "roxr\0"
.LC80:
	.ascii "roxl\0"
.LC79:
	.ascii "ror\0"
.LC78:
	.ascii "rol\0"
.LC77:
	.ascii "pea\0"
.LC76:
	.ascii "ori.l\0"
.LC75:
	.ascii "not.l\0"
.LC74:
	.ascii "not.w\0"
.LC73:
	.ascii "not.b\0"
.LC72:
	.ascii "negx.l\0"
.LC71:
	.ascii "negx.w\0"
.LC70:
	.ascii "negx.b\0"
.LC69:
	.ascii "neg.l\0"
.LC68:
	.ascii "neg.w\0"
.LC67:
	.ascii "neg.b\0"
.LC66:
	.ascii "nbcd\0"
.LC65:
	.ascii "moves.l\0"
.LC64:
	.ascii "moves.w\0"
.LC63:
	.ascii "moves.b\0"
.LC62:
	.ascii "movem.l\0"
.LC61:
	.ascii "movem.w\0"
.LC60:
	.ascii "move.w\0"
.LC59:
	.ascii "lsr\0"
.LC58:
	.ascii "lsl\0"
.LC57:
	.ascii "jsr\0"
.LC56:
	.ascii "jmp\0"
.LC55:
	.ascii "eori.l\0"
.LC54:
	.ascii "cmpi.l\0"
.LC53:
	.ascii "cmpi.w\0"
.LC52:
	.ascii "cmpi.b\0"
.LC51:
	.ascii "clr.l\0"
.LC50:
	.ascii "clr.w\0"
.LC49:
	.ascii "clr.b\0"
.LC48:
	.ascii "btst\0"
.LC47:
	.ascii "bset\0"
.LC46:
	.ascii "bclr\0"
.LC45:
	.ascii "bchg\0"
.LC44:
	.ascii "asr\0"
.LC43:
	.ascii "asl\0"
.LC42:
	.ascii "andi.l\0"
.LC41:
	.ascii "addi.l\0"
.LC40:
	.ascii "addi.w\0"
.LC39:
	.ascii "addi.b\0"
.LC38:
	.ascii "trap\0"
.LC37:
	.ascii "unlk\0"
.LC36:
	.ascii "swap\0"
.LC35:
	.ascii "move.l\0"
.LC34:
	.ascii "link\0"
.LC33:
	.ascii "ext.l\0"
.LC32:
	.ascii "ext.w\0"
.LC31:
	.ascii "dble\0"
.LC30:
	.ascii "dbgt\0"
.LC29:
	.ascii "dblt\0"
.LC28:
	.ascii "dbge\0"
.LC27:
	.ascii "dbmi\0"
.LC26:
	.ascii "dbpl\0"
.LC25:
	.ascii "dbvs\0"
.LC24:
	.ascii "dbvc\0"
.LC23:
	.ascii "dbeq\0"
.LC22:
	.ascii "dbne\0"
.LC21:
	.ascii "dbcs\0"
.LC20:
	.ascii "dbcc\0"
.LC19:
	.ascii "dbls\0"
.LC18:
	.ascii "dbhi\0"
.LC17:
	.ascii "dbra\0"
.LC16:
	.ascii "dbt\0"
.LC15:
	.ascii "movec\0"
.LC14:
	.ascii "trapv\0"
.LC13:
	.ascii "stop\0"
.LC12:
	.ascii "rts\0"
.LC11:
	.ascii "rtr\0"
.LC10:
	.ascii "rte\0"
.LC9:
	.ascii "rtd\0"
.LC8:
	.ascii "reset\0"
.LC7:
	.ascii "ori.w\0"
.LC6:
	.ascii "ori.b\0"
.LC5:
	.ascii "nop\0"
.LC4:
	.ascii "illegal\0"
.LC3:
	.ascii "eori.w\0"
.LC2:
	.ascii "eori.b\0"
.LC1:
	.ascii "andi.w\0"
.LC0:
	.ascii "andi.b\0"
.LC200:
	.ascii "%s\0"
.LC201:
	.ascii "  \0"
	.even
.globl pinstr
pinstr:
	link.w %a6,#0
	movm.l #0x2030,-(%sp)
	move.l 8(%a6),%a0
	move.l %a0,dot
	lea (2,%a0),%a1
	move.l %a1,sdot
	moveq.l #2,%d2
	move.l %d2,dotinc
	move.w (%a0),instr
	lea optab,%a3
	move.w instr,%d1
	.even
.L4:
	move.w %d1,%d0
	and.w (%a3),%d0
	cmp.w 2(%a3),%d0
	jbeq .L3
	lea (10,%a3),%a3
	jbra .L4
	.even
.L3:
	move.l 6(%a3),-(%sp)
	pea .LC200
	lea cprintf,%a2
	jsr (%a2)
	pea .LC201
	pea .LC200
	jsr (%a2)
	move.w 4(%a3),%d0
	lea (16,%sp),%sp
	cmp.w #28,%d0
	jbhi .L7
	tst.w %d0
	jbeq .L38
	move.w %d0,%a0
	moveq.l #25,%d2
	cmp.l %a0,%d2
	jbcs .L38
	.set .LI36,.+2
	move.w .L36-.LI36.b(%pc,%a0.l*2),%d0
	jmp %pc@(2,%d0:w)
	.even
.L36:
	.word .L10-.L36
	.word .L11-.L36
	.word .L12-.L36
	.word .L13-.L36
	.word .L14-.L36
	.word .L15-.L36
	.word .L16-.L36
	.word .L17-.L36
	.word .L18-.L36
	.word .L19-.L36
	.word .L20-.L36
	.word .L21-.L36
	.word .L22-.L36
	.word .L23-.L36
	.word .L24-.L36
	.word .L25-.L36
	.word .L26-.L36
	.word .L27-.L36
	.word .L28-.L36
	.word .L29-.L36
	.word .L30-.L36
	.word .L31-.L36
	.word .L32-.L36
	.word .L33-.L36
	.word .L34-.L36
	.word .L35-.L36
	.even
.L10:
	jsr noin
	jbra .L38
	.even
.L11:
	jsr inf1
	jbra .L38
	.even
.L12:
	jsr inf2
	jbra .L38
	.even
.L13:
	jsr inf3
	jbra .L38
	.even
.L14:
	jsr inf4
	jbra .L38
	.even
.L15:
	jsr inf5
	jbra .L38
	.even
.L16:
	jsr inf6
	jbra .L38
	.even
.L17:
	jsr inf7
	jbra .L38
	.even
.L18:
	jsr inf8
	jbra .L38
	.even
.L19:
	jsr inf9
	jbra .L38
	.even
.L20:
	jsr inf10
	jbra .L38
	.even
.L21:
	jsr inf11
	jbra .L38
	.even
.L22:
	jsr inf12
	jbra .L38
	.even
.L23:
	jsr inf13
	jbra .L38
	.even
.L24:
	jsr inf14
	jbra .L38
	.even
.L25:
	jsr inf15
	jbra .L38
	.even
.L26:
	jsr inf16
	jbra .L38
	.even
.L27:
	jsr inf17
	jbra .L38
	.even
.L28:
	jsr inf18
	jbra .L38
	.even
.L29:
	jsr inf19
	jbra .L38
	.even
.L30:
	jsr inf20
	jbra .L38
	.even
.L31:
	jsr inf21
	jbra .L38
	.even
.L32:
	jsr inf22
	jbra .L38
	.even
.L33:
	jsr inf23
	jbra .L38
	.even
.L34:
	jsr inf24
	jbra .L38
	.even
.L35:
	jsr inf25
	jbra .L38
	.even
.L7:
	pea 63.w
	jsr _con_out
.L38:
	move.l dotinc,%d0
	movm.l -12(%a6),#0xc04
	unlk %a6
	rts
.LC202:
	.ascii "illegal instruction format #\12\0"
	.even
.globl noin
noin:
	link.w %a6,#0
	pea .LC202
	pea .LC200
	jsr cprintf
	unlk %a6
	rts
	.even
.globl inf1
inf1:
	link.w %a6,#0
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.w instr,%d0
	bfextu %d0{#20:#3},%d2
	btst #3,%d0
	jbeq .L41
	moveq.l #7,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	lea paripd,%a2
	jbra .L43
	.even
.L41:
	moveq.l #7,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	lea pdr,%a2
.L43:
	jsr (%a2)
	pea 44.w
	jsr _con_out
	moveq.l #7,%d1
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr (%a2)
	move.l -8(%a6),%d2
	move.l -4(%a6),%a2
	unlk %a6
	rts
	.even
.globl inf2
inf2:
	link.w %a6,#0
	movm.l #0x3c00,-(%sp)
	move.w instr,%d1
	bfextu %d1{#20:#3},%d3
	move.w %d1,%d0
	and.w #192,%d0
	cmp.w #192,%d0
	jbne .L45
	moveq.l #1,%d2
	move.w %d1,%d0
	and.w #448,%d0
	cmp.w #448,%d0
	jbne .L46
	moveq.l #2,%d2
.L46:
	addq.w #8,%d3
	jbra .L47
	.even
.L45:
	move.w %d0,%d2
	asr.w #6,%d2
.L47:
	cmp.w #7,%d3
	jbgt .L49
	btst #8,%d1
	jbne .L48
.L49:
	moveq.l #3,%d4
	and.l %d2,%d4
	move.l %d4,-(%sp)
	moveq.l #63,%d5
	and.l %d1,%d5
	move.l %d5,-(%sp)
	jsr prtop
	pea 44.w
	jsr _con_out
	move.w %d3,%a0
	move.l %a0,-(%sp)
	jsr prtreg
	jbra .L50
	.even
.L48:
	move.w %d3,%a0
	move.l %a0,-(%sp)
	jsr prtreg
	pea 44.w
	jsr _con_out
	moveq.l #3,%d4
	and.l %d2,%d4
	move.l %d4,-(%sp)
	move.w instr,%d5
	moveq.l #63,%d4
	and.l %d4,%d5
	move.l %d5,-(%sp)
	jsr prtop
.L50:
	movm.l -16(%a6),#0x3c
	unlk %a6
	rts
.LC203:
	.ascii "SR\0"
.LC204:
	.ascii "CCR\0"
	.even
.globl inf3
inf3:
	link.w %a6,#0
	move.l %d2,-(%sp)
	bfextu instr+1{#0:#2},%d2
	move.l %d2,-(%sp)
	jsr primm
	pea 44.w
	jsr _con_out
	addq.l #8,%sp
	move.w instr,%d0
	cmp.w #572,%d0
	jbeq .L58
	jbgt .L61
	cmp.w #60,%d0
	jbeq .L58
	cmp.w #124,%d0
	jbeq .L55
	jbra .L59
	.even
.L61:
	cmp.w #2620,%d0
	jbeq .L58
	jbgt .L62
	cmp.w #636,%d0
	jbeq .L55
	jbra .L59
	.even
.L62:
	cmp.w #2684,%d0
	jbne .L59
.L55:
	pea .LC203
	jbra .L63
	.even
.L58:
	pea .LC204
.L63:
	pea .LC200
	jsr cprintf
	jbra .L52
	.even
.L59:
	move.l %d2,-(%sp)
	moveq.l #63,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr prtop
.L52:
	move.l -4(%a6),%d2
	unlk %a6
	rts
.LC205:
	.ascii "#$\0"
	.even
.globl inf4
inf4:
	link.w %a6,#0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	bfextu instr{#4:#3},%d2
	tst.w %d2
	jbne .L65
	moveq.l #8,%d2
.L65:
	pea .LC205
	pea .LC200
	jsr cprintf
	moveq.l #15,%d1
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr hexbzs
	pea 44.w
	jsr _con_out
	pea 1.w
	move.w instr,%d3
	moveq.l #63,%d1
	and.l %d1,%d3
	move.l %d3,-(%sp)
	jsr prtop
	move.l -8(%a6),%d2
	move.l -4(%a6),%d3
	unlk %a6
	rts
.LC206:
	.ascii "SR,\0"
.LC207:
	.ascii "CCR,\0"
.LC208:
	.ascii ",CCR\0"
.LC209:
	.ascii ",SR\0"
	.even
.globl inf5
inf5:
	link.w %a6,#0
	move.l %d2,-(%sp)
	move.w instr,%d0
	move.w %d0,%d2
	and.w #1536,%d2
	jbne .L67
	pea .LC206
	jbra .L73
	.even
.L67:
	cmp.w #512,%d2
	jbne .L68
	pea .LC207
.L73:
	pea .LC200
	jsr cprintf
	addq.l #8,%sp
	move.w instr,%d0
.L68:
	pea 1.w
	moveq.l #63,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr prtop
	addq.l #8,%sp
	cmp.w #1024,%d2
	jbne .L70
	pea .LC208
	jbra .L74
	.even
.L70:
	cmp.w #1536,%d2
	jbne .L71
	pea .LC209
.L74:
	pea .LC200
	jsr cprintf
.L71:
	move.l -4(%a6),%d2
	unlk %a6
	rts
	.even
.globl inf6
inf6:
	link.w %a6,#0
	movm.l #0x3020,-(%sp)
	move.w instr,%d0
	bfextu %d0{#20:#3},%d2
	btst #5,%d0
	jbeq .L76
	moveq.l #7,%d1
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr pdr
	addq.l #4,%sp
	lea _con_out,%a2
	jbra .L77
	.even
.L76:
	tst.w %d2
	jbne .L78
	moveq.l #8,%d2
.L78:
	pea 35.w
	lea _con_out,%a2
	jsr (%a2)
	moveq.l #15,%d3
	and.l %d2,%d3
	move.l %d3,-(%sp)
	jsr hexbzs
	addq.l #8,%sp
.L77:
	pea 44.w
	jsr (%a2)
	move.w instr,%d1
	moveq.l #7,%d3
	and.l %d3,%d1
	move.l %d1,-(%sp)
	jsr prtreg
	movm.l -12(%a6),#0x40c
	unlk %a6
	rts
	.even
.globl inf7
inf7:
	link.w %a6,#0
	pea 1.w
	move.w instr,%d0
	moveq.l #63,%d1
	and.l %d1,%d0
	move.l %d0,-(%sp)
	jsr prtop
	unlk %a6
	rts
.LC210:
	.ascii "$\0"
	.even
.globl inf8
inf8:
	link.w %a6,#0
	move.l %d2,-(%sp)
	move.b instr+1,%d0
	ext.w %d0
	cmp.w #-1,%d0
	jbne .L81
	move.l sdot,%a0
	move.w (%a0),%d1
	move.w %d1,%d0
	swap %d0
	mov.w 2(%a0),%d0
	move.l %a0,%d2
	add.l %d0,%d2
	addq.l #4,%a0
	move.l %a0,sdot
	addq.l #4,dotinc
	jbra .L82
	.even
.L81:
	tst.w %d0
	jbeq .L83
	move.l sdot,%a0
	lea (%a0,%d0.w),%a0
	move.l %a0,%d2
	jbra .L82
	.even
.L83:
	move.l sdot,%a0
	move.w (%a0),%a1
	move.l %a0,%d2
	add.l %a1,%d2
	addq.l #2,%a0
	move.l %a0,sdot
	addq.l #2,dotinc
.L82:
	pea .LC210
	pea .LC200
	jsr cprintf
	move.l %d2,-(%sp)
	jsr hexlzs
	move.l -4(%a6),%d2
	unlk %a6
	rts
	.even
.globl inf9
inf9:
	link.w %a6,#0
	move.l %d2,-(%sp)
	pea 1.w
	move.w instr,%d1
	moveq.l #63,%d2
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr prtop
	pea 44.w
	jsr _con_out
	bfextu instr{#4:#3},%d1
	move.l %d1,-(%sp)
	jsr pdr
	move.l -4(%a6),%d2
	unlk %a6
	rts
	.even
.globl inf10
inf10:
	link.w %a6,#0
	move.l %d2,-(%sp)
	move.w instr,%d0
	btst #8,%d0
	jbeq .L87
	bfextu %d0{#20:#3},%d0
	move.l %d0,-(%sp)
	jsr pdr
	jbra .L89
	.even
.L87:
	pea 1.w
	jsr primm
.L89:
	move.l #44,(%sp)
	jsr _con_out
	pea 1.w
	move.w instr,%d1
	moveq.l #63,%d2
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr prtop
	move.l -4(%a6),%d2
	unlk %a6
	rts
	.even
.globl inf11
inf11:
	link.w %a6,#0
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.w instr,%d1
	moveq.l #7,%d2
	and.l %d2,%d1
	move.l %d1,-(%sp)
	lea paripi,%a2
	jsr (%a2)
	pea 44.w
	jsr _con_out
	bfextu instr{#4:#3},%d1
	move.l %d1,-(%sp)
	jsr (%a2)
	move.l -8(%a6),%d2
	move.l -4(%a6),%a2
	unlk %a6
	rts
	.even
.globl inf12
inf12:
	link.w %a6,#0
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.w instr,%d1
	moveq.l #7,%d2
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr pdr
	pea 44.w
	jsr _con_out
	move.l sdot,%a0
	move.w (%a0),%a1
	lea (2,%a0),%a2
	move.l %a2,sdot
	addq.l #2,dotinc
	pea (%a1,%a0.l)
	jsr hexlzs
	move.l -8(%a6),%d2
	move.l -4(%a6),%a2
	unlk %a6
	rts
	.even
.globl inf13
inf13:
	link.w %a6,#0
	movm.l #0x3020,-(%sp)
	move.w instr,%d0
	bfextu %d0{#20:#3},%d1
	move.w %d0,%d2
	and.w #7,%d2
	and.w #248,%d0
	cmp.w #72,%d0
	jbne .L93
	addq.w #8,%d1
	jbra .L96
	.even
.L93:
	cmp.w #136,%d0
	jbne .L94
.L96:
	addq.w #8,%d2
.L94:
	moveq.l #31,%d3
	and.l %d1,%d3
	move.l %d3,-(%sp)
	lea prtreg,%a2
	jsr (%a2)
	pea 44.w
	jsr _con_out
	move.w %d2,%a0
	move.l %a0,-(%sp)
	jsr (%a2)
	movm.l -12(%a6),#0x40c
	unlk %a6
	rts
	.even
.globl inf14
inf14:
	link.w %a6,#0
	move.w instr,%d0
	moveq.l #7,%d1
	and.l %d1,%d0
	move.l %d0,-(%sp)
	jsr pdr
	unlk %a6
	rts
.LC211:
	.ascii ",#$\0"
	.even
.globl inf15
inf15:
	link.w %a6,#0
	move.l %d2,-(%sp)
	move.w instr,%d1
	moveq.l #7,%d2
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr par
	pea .LC211
	pea .LC200
	jsr cprintf
	move.l sdot,%a0
	move.w (%a0),%a0
	move.l %a0,-(%sp)
	jsr hexwzs
	addq.l #2,sdot
	addq.l #2,dotinc
	move.l -4(%a6),%d2
	unlk %a6
	rts
	.even
.globl inf16
inf16:
	link.w %a6,#0
	movm.l #0x2030,-(%sp)
	move.w instr,%d1
	move.w %d1,%d0
	and.w #12288,%d0
	move.w #1,%a3
	cmp.w #4096,%d0
	jbne .L100
	move.w #0,%a3
	jbra .L101
	.even
.L100:
	cmp.w #12288,%d0
	jbeq .L101
	cmp.w #8192,%d0
	jbne .L104
	move.w #2,%a3
	jbra .L101
	.even
.L104:
	jsr badsize
	move.w instr,%d1
.L101:
	move.w %a3,%a3
	move.l %a3,-(%sp)
	moveq.l #63,%d2
	and.l %d1,%d2
	move.l %d2,-(%sp)
	lea prtop,%a2
	jsr (%a2)
	pea 44.w
	jsr _con_out
	move.w instr,%d0
	bfextu %d0{#20:#3},%d1
	and.w #448,%d0
	asr.w #3,%d0
	or.w %d0,%d1
	move.l %a3,-(%sp)
	moveq.l #63,%d2
	and.l %d1,%d2
	move.l %d2,-(%sp)
	jsr (%a2)
	movm.l -12(%a6),#0xc04
	unlk %a6
	rts
.LC212:
	.ascii "USP,\0"
.LC213:
	.ascii ",USP\0"
	.even
.globl inf17
inf17:
	link.w %a6,#0
	move.l %d2,-(%sp)
	move.w instr,%d0
	move.w %d0,%d2
	and.w #7,%d2
	btst #3,%d0
	jbeq .L107
	pea .LC212
	pea .LC200
	jsr cprintf
	moveq.l #7,%d1
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr par
	jbra .L108
	.even
.L107:
	moveq.l #7,%d1
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr par
	pea .LC213
	pea .LC200
	jsr cprintf
.L108:
	move.l -4(%a6),%d2
	unlk %a6
	rts
.globl regmsk0
	.even
regmsk0:
	.word -32768
	.word 16384
	.word 8192
	.word 4096
	.word 2048
	.word 1024
	.word 512
	.word 256
	.word 128
	.word 64
	.word 32
	.word 16
	.word 8
	.word 4
	.word 2
	.word 1
.globl regmsk1
	.even
regmsk1:
	.word 1
	.word 2
	.word 4
	.word 8
	.word 16
	.word 32
	.word 64
	.word 128
	.word 256
	.word 512
	.word 1024
	.word 2048
	.word 4096
	.word 8192
	.word 16384
	.word -32768
	.even
.globl inf18
inf18:
	link.w %a6,#0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l sdot,%a0
	move.w (%a0)+,%d2
	move.l %a0,sdot
	addq.l #2,dotinc
	move.w instr,%d0
	btst #10,%d0
	jbeq .L110
	pea 1.w
	moveq.l #63,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr prtop
	pea 44.w
	jsr _con_out
	move.w %d2,%a1
	move.l %a1,-(%sp)
	pea regmsk1
	jsr putrlist
	jbra .L111
	.even
.L110:
	and.w #56,%d0
	cmp.w #32,%d0
	jbne .L112
	move.w %d2,%a1
	move.l %a1,-(%sp)
	pea regmsk0
	jbra .L114
	.even
.L112:
	move.w %d2,%a1
	move.l %a1,-(%sp)
	pea regmsk1
.L114:
	jsr putrlist
	addq.w #4,%sp
	move.l #44,(%sp)
	jsr _con_out
	pea 1.w
	move.w instr,%d1
	moveq.l #63,%d3
	and.l %d3,%d1
	move.l %d1,-(%sp)
	jsr prtop
.L111:
	move.l -8(%a6),%d2
	move.l -4(%a6),%d3
	unlk %a6
	rts
	.even
.globl inf19
inf19:
	link.w %a6,#0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.w instr,%d0
	move.w %d0,%d2
	and.w #384,%d2
	cmp.w #384,%d2
	jbne .L116
	bfextu %d0{#20:#3},%d0
	move.l %d0,-(%sp)
	jsr prtreg
	pea 44.w
	jsr _con_out
	addq.l #8,%sp
.L116:
	move.l sdot,%a0
	move.w (%a0),%a0
	move.l %a0,-(%sp)
	jsr hexwzs
	move.w instr,%d1
	moveq.l #7,%d3
	and.l %d3,%d1
	move.l %d1,-(%sp)
	jsr pari
	addq.l #8,%sp
	cmp.w #256,%d2
	jbne .L117
	pea 44.w
	jsr _con_out
	bfextu instr{#4:#3},%d1
	move.l %d1,-(%sp)
	jsr prtreg
.L117:
	addq.l #2,sdot
	addq.l #2,dotinc
	move.l -8(%a6),%d2
	move.l -4(%a6),%d3
	unlk %a6
	rts
	.even
.globl inf20
inf20:
	link.w %a6,#0
	pea .LC205
	pea .LC200
	jsr cprintf
	move.b instr+1,%d1
	extb.l %d1
	move.l %d1,-(%sp)
	jsr hexbzs
	pea 44.w
	jsr _con_out
	bfextu instr{#4:#3},%d1
	move.l %d1,-(%sp)
	jsr prtreg
	unlk %a6
	rts
	.even
.globl inf21
inf21:
	link.w %a6,#0
	pea 1.w
	jsr primm
	unlk %a6
	rts
	.even
.globl inf22
inf22:
	link.w %a6,#0
	move.w instr,%d0
	moveq.l #15,%d1
	and.l %d1,%d0
	move.l %d0,-(%sp)
	jsr prtreg
	unlk %a6
	rts
	.even
.globl inf23
inf23:
	link.w %a6,#0
	move.l %d2,-(%sp)
	pea .LC205
	pea .LC200
	jsr cprintf
	move.b instr+1,%d1
	moveq.l #15,%d2
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr hexbzs
	move.l -4(%a6),%d2
	unlk %a6
	rts
.LC214:
	.ascii "SFC\0"
.LC215:
	.ascii "DFC\0"
.LC216:
	.ascii "USP\0"
.LC217:
	.ascii "VBR\0"
.LC218:
	.ascii "illegal Control Register\0"
	.even
.globl inf24
inf24:
	link.w %a6,#0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l sdot,%a0
	move.w (%a0)+,%d0
	move.l %a0,sdot
	addq.l #2,dotinc
	move.w %d0,%d2
	and.w #4095,%d2
	bfextu %d0{#16:#4},%d3
	btst #0,instr+1
	jbeq .L123
	moveq.l #15,%d1
	and.l %d3,%d1
	move.l %d1,-(%sp)
	jsr prtreg
	pea 44.w
	jsr _con_out
	addq.l #8,%sp
.L123:
	cmp.w #1,%d2
	jbeq .L126
	jbgt .L131
	tst.w %d2
	jbeq .L125
	jbra .L129
	.even
.L131:
	cmp.w #2048,%d2
	jbeq .L127
	cmp.w #2049,%d2
	jbeq .L128
	jbra .L129
	.even
.L125:
	pea .LC214
	jbra .L133
	.even
.L126:
	pea .LC215
	jbra .L133
	.even
.L127:
	pea .LC216
	jbra .L133
	.even
.L128:
	pea .LC217
	jbra .L133
	.even
.L129:
	pea .LC218
.L133:
	pea .LC200
	jsr cprintf
	addq.l #8,%sp
	btst #0,instr+1
	jbne .L132
	pea 44.w
	jsr _con_out
	moveq.l #15,%d1
	and.l %d3,%d1
	move.l %d1,-(%sp)
	jsr prtreg
.L132:
	move.l -8(%a6),%d2
	move.l -4(%a6),%d3
	unlk %a6
	rts
	.even
.globl inf25
inf25:
	link.w %a6,#0
	movm.l #0x3800,-(%sp)
	move.w instr,%d3
	and.w #192,%d3
	move.l sdot,%a0
	move.w (%a0)+,%d0
	move.l %a0,sdot
	addq.l #2,dotinc
	bfextu %d0{#16:#4},%d2
	btst #11,%d0
	jbeq .L135
	moveq.l #15,%d1
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr prtreg
	pea 44.w
	jsr _con_out
	addq.l #8,%sp
.L135:
	moveq.l #63,%d4
	not.b %d4
	and.l %d3,%d4
	move.l %d4,-(%sp)
	move.w instr,%d1
	moveq.l #63,%d4
	and.l %d4,%d1
	move.l %d1,-(%sp)
	jsr prtop
	addq.l #8,%sp
	btst #3,instr
	jbne .L136
	pea 44.w
	jsr _con_out
	moveq.l #15,%d1
	and.l %d2,%d1
	move.l %d1,-(%sp)
	jsr prtreg
.L136:
	movm.l -12(%a6),#0x1c
	unlk %a6
	rts
.LC219:
	.ascii "A7\0"
	.even
.globl putrlist
putrlist:
	link.w %a6,#0
	movm.l #0x3820,-(%sp)
	move.w 14(%a6),%d4
	move.l 8(%a6),%a2
	moveq.l #-1,%d3
	clr.w %d2
	.even
.L141:
	move.w %d4,%d0
	and.w (%a2)+,%d0
	jbeq .L142
	tst.w %d3
	jbne .L143
	pea 47.w
	jsr _con_out
	addq.l #4,%sp
.L143:
	cmp.w #1,%d3
	jbeq .L144
	move.w %d2,%a0
	move.l %a0,-(%sp)
	jsr prtreg
	pea 45.w
	jsr _con_out
	addq.l #8,%sp
.L144:
	moveq.l #1,%d3
	jbra .L140
	.even
.L142:
	cmp.w #1,%d3
	jbne .L140
	subq.w #1,%d2
	move.w %d2,%a0
	move.l %a0,-(%sp)
	addq.w #1,%d2
	jsr prtreg
	clr.w %d3
	addq.l #4,%sp
.L140:
	addq.w #1,%d2
	cmp.w #15,%d2
	jble .L141
	cmp.w #1,%d3
	jbne .L148
	pea .LC219
	pea .LC200
	jsr cprintf
.L148:
	movm.l -16(%a6),#0x41c
	unlk %a6
	rts
	.even
.globl pdr
pdr:
	link.w %a6,#0
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.w 10(%a6),%d2
	pea 68.w
	lea _con_out,%a2
	jsr (%a2)
	lea nstring,%a0
	move.b (%a0,%d2.w),%d1
	extb.l %d1
	move.l %d1,-(%sp)
	jsr (%a2)
	move.l -8(%a6),%d2
	move.l -4(%a6),%a2
	unlk %a6
	rts
.LC220:
	.ascii "SP\0"
	.even
.globl par
par:
	link.w %a6,#0
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.w 10(%a6),%d2
	cmp.w #7,%d2
	jbne .L151
	pea .LC220
	pea .LC200
	jsr cprintf
	jbra .L152
	.even
.L151:
	pea 65.w
	lea _con_out,%a2
	jsr (%a2)
	lea nstring,%a0
	move.b (%a0,%d2.w),%d1
	extb.l %d1
	move.l %d1,-(%sp)
	jsr (%a2)
.L152:
	move.l -8(%a6),%d2
	move.l -4(%a6),%a2
	unlk %a6
	rts
	.even
.globl pdri
pdri:
	link.w %a6,#0
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.w 10(%a6),%d2
	pea 40.w
	lea _con_out,%a2
	jsr (%a2)
	move.w %d2,%a0
	move.l %a0,-(%sp)
	jsr pdr
	pea 41.w
	jsr (%a2)
	move.l -8(%a6),%d2
	move.l -4(%a6),%a2
	unlk %a6
	rts
	.even
.globl pari
pari:
	link.w %a6,#0
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.w 10(%a6),%d2
	pea 40.w
	lea _con_out,%a2
	jsr (%a2)
	move.w %d2,%a0
	move.l %a0,-(%sp)
	jsr par
	pea 41.w
	jsr (%a2)
	move.l -8(%a6),%d2
	move.l -4(%a6),%a2
	unlk %a6
	rts
	.even
.globl paripd
paripd:
	link.w %a6,#0
	move.l %d2,-(%sp)
	move.w 10(%a6),%d2
	pea 45.w
	jsr _con_out
	move.w %d2,%a0
	move.l %a0,-(%sp)
	jsr pari
	move.l -4(%a6),%d2
	unlk %a6
	rts
	.even
.globl paripi
paripi:
	link.w %a6,#0
	move.w 10(%a6),%a0
	move.l %a0,-(%sp)
	jsr pari
	pea 43.w
	jsr _con_out
	unlk %a6
	rts
.LC221:
	.ascii "%08lx\0"
	.even
.globl hexlzs
hexlzs:
	link.w %a6,#0
	move.l 8(%a6),-(%sp)
	pea .LC221
	jsr cprintf
	unlk %a6
	rts
.LC222:
	.ascii "%04lx\0"
	.even
.globl hexwzs
hexwzs:
	link.w %a6,#0
	move.w 10(%a6),%a0
	move.l %a0,-(%sp)
	pea .LC222
	jsr cprintf
	unlk %a6
	rts
.LC223:
	.ascii "%02lx\0"
	.even
.globl hexbzs
hexbzs:
	link.w %a6,#0
	move.b 11(%a6),%d1
	extb.l %d1
	move.l %d1,-(%sp)
	pea .LC223
	jsr cprintf
	unlk %a6
	rts
.LC224:
	.ascii "\12** illegal size field **\12\0"
	.even
.globl badsize
badsize:
	link.w %a6,#0
	pea .LC224
	pea .LC200
	jsr cprintf
	unlk %a6
	rts
	.even
.globl prtreg
prtreg:
	link.w %a6,#0
	move.w 10(%a6),%d0
	cmp.w #7,%d0
	jble .L162
	subq.w #8,%d0
	move.w %d0,%a0
	move.l %a0,-(%sp)
	jsr par
	jbra .L163
	.even
.L162:
	move.w %d0,%a0
	move.l %a0,-(%sp)
	jsr pdr
.L163:
	unlk %a6
	rts
	.even
.globl prdisp
prdisp:
	link.w %a6,#0
	move.l %d2,-(%sp)
	move.l sdot,%a0
	move.w (%a0)+,%d2
	move.l %a0,sdot
	addq.l #2,dotinc
	pea 36.w
	jsr _con_out
	move.w %d2,%a1
	move.l %a1,-(%sp)
	jsr hexwzs
	move.l -4(%a6),%d2
	unlk %a6
	rts
	.even
.globl prindex
prindex:
	link.w %a6,#0
	addq.l #2,sdot
	addq.l #2,dotinc
	unlk %a6
	rts
	.even
.globl primm
primm:
	link.w %a6,#0
	move.l %d2,-(%sp)
	clr.l %d2
	cmp.w #2,10(%a6)
	jbne .L169
	move.l sdot,%a0
	move.w (%a0)+,%d2
	ext.l %d2
	swap %d2
	clr.w %d2
	move.l %a0,sdot
	addq.l #2,dotinc
.L169:
	move.l sdot,%a0
	clr.l %d0
	move.w (%a0)+,%d0
	or.l %d0,%d2
	move.l %a0,sdot
	addq.l #2,dotinc
	pea .LC205
	pea .LC200
	jsr cprintf
	move.l %d2,-(%sp)
	jsr hexlzs
	move.l -4(%a6),%d2
	unlk %a6
	rts
.LC225:
	.ascii "(PC)\0"
	.even
.globl prtop
prtop:
	link.w %a6,#0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.w 10(%a6),%d0
	move.w 14(%a6),%d1
	move.w %d0,%d2
	and.w #7,%d2
	bfextu %d0{#26:#3},%d0
	moveq.l #7,%d3
	cmp.l %d0,%d3
	jbcs .L171
	.set .LI189,.+2
	move.w .L189-.LI189.b(%pc,%d0.l*2),%d0
	jmp %pc@(2,%d0:w)
	.even
.L189:
	.word .L172-.L189
	.word .L173-.L189
	.word .L191-.L189
	.word .L175-.L189
	.word .L176-.L189
	.word .L177-.L189
	.word .L178-.L189
	.word .L179-.L189
	.even
.L172:
	moveq.l #7,%d3
	and.l %d2,%d3
	move.l %d3,-(%sp)
	jsr pdr
	jbra .L171
	.even
.L173:
	moveq.l #7,%d3
	and.l %d2,%d3
	move.l %d3,-(%sp)
	jsr par
	jbra .L171
	.even
.L175:
	moveq.l #7,%d3
	and.l %d2,%d3
	move.l %d3,-(%sp)
	jsr paripi
	jbra .L171
	.even
.L176:
	moveq.l #7,%d3
	and.l %d2,%d3
	move.l %d3,-(%sp)
	jsr paripd
	jbra .L171
	.even
.L177:
	jsr prdisp
.L191:
	moveq.l #7,%d3
	and.l %d2,%d3
	move.l %d3,-(%sp)
	jsr pari
	jbra .L171
	.even
.L178:
	moveq.l #7,%d3
	and.l %d2,%d3
	move.l %d3,-(%sp)
	jsr prindex
	jbra .L171
	.even
.L179:
	move.w %d2,%a0
	moveq.l #4,%d3
	cmp.l %a0,%d3
	jbcs .L171
	.set .LI187,.+2
	move.w .L187-.LI187.b(%pc,%a0.l*2),%d0
	jmp %pc@(2,%d0:w)
	.even
.L187:
	.word .L181-.L187
	.word .L183-.L187
	.word .L184-.L187
	.word .L185-.L187
	.word .L186-.L187
	.even
.L181:
	move.l sdot,%a0
	move.w (%a0),%d0
	ext.l %d0
	tst.w %d0
	jbge .L182
	or.l #-65536,%d0
.L182:
	addq.l #2,%a0
	move.l %a0,sdot
	addq.l #2,dotinc
	move.l %d0,-(%sp)
	jsr hexlzs
	jbra .L171
	.even
.L183:
	move.l sdot,%a0
	move.w (%a0)+,%d2
	ext.l %d2
	swap %d2
	clr.w %d2
	move.l %a0,sdot
	move.l dotinc,%d1
	addq.l #2,%d1
	move.l %d1,dotinc
	clr.l %d0
	move.w (%a0)+,%d0
	add.l %d0,%d2
	move.l %a0,sdot
	addq.l #2,%d1
	move.l %d1,dotinc
	pea 36.w
	jsr _con_out
	move.l %d2,-(%sp)
	jsr hexlzs
	jbra .L171
	.even
.L184:
	jsr prdisp
	pea .LC225
	pea .LC200
	jsr cprintf
	jbra .L171
	.even
.L185:
	pea 16.w
	jsr prindex
	jbra .L171
	.even
.L186:
	move.w %d1,%a1
	move.l %a1,-(%sp)
	jsr primm
.L171:
	move.l -8(%a6),%d2
	move.l -4(%a6),%d3
	unlk %a6
	rts
.comm instr,2
.lcomm dot,4
.lcomm sdot,4
.lcomm dotinc,4
