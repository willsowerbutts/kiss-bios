#
#  Makefile for KISS-68030 test code(s)
#
#	Uses AshWare distro of GCC 2.91
#
#
MCPU=68030
CROSS = m68k-elf
CROSSLIB = /usr/local/stow/m68k/lib/gcc/m68k-elf/4.9.2/
#
RETAIL=RETAIL=0
CPU=$(MCPU)
BIOSSIZE=48
#
#
CC = $(CROSS)-gcc
COPT = -O2 -m$(CPU) -Wall -D$(RETAIL)
# -Wa,-alhms,-L
AS = $(CROSS)-as
AOPT = -m$(CPU) -alhms --defsym $(RETAIL) --defsym M68000=$(CPU)
LD = $(CROSS)-ld
LOPT = -Ttext 0xFFF00000 -Tdata 0x400
UOPT = -Ttext 0x1100 --entry begin
LIB = $(CROSS)-ar
LIBS = -L$(CROSSLIB) -lc -lgcc

TARGET = kiss01
TUTOR = ../yoda/tutor13b.s68
#INC = -s 0x380000 $(TUTOR)/M
INC =


#.SUFFIXES =	.map .sym .mod .hex .out .bin

.c.o:
	$(CC) -c $(COPT) $*.c
.s.o:
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s
.c.s:
	$(CC) -S $(COPT) $*.c


SFILES = mfpic.s memtest.s memtest2.s uart.s ns202def.s biostrap.s error.s ppi.s allide.s siodef.s
HFILES = mytypes.h packer.h mfpic.h ns202.h dosdisk.h ide.h main68.h crc32.h \
  portab.h coff.h myide.h rtc.h io.h fdc8272.h wd37c65.h debug.h version.h
HSFILES = portab.h optab.h disasm.h
OFILES = main68.o serial.o rtc.o ds1302.o cprintf.o packer.o \
	pic202.o ns202.o ppide.o dualide.o bios8.o strtoul.o malloc.o \
	dualsd.o crctab.o bioscall.o fdc8272.o wd37c65.o floppy.o setup.o \
	debug.o beetle.o disasm.o mem4mem.o prettydump.o
CSFILES = main68.s cprintf.s packer.s ns202.s crc32.s malloc.s setup.s \
	rtc.s strtoul.s fdc8272.s wd37c65.s ppide2.s debug.s disasm.s



TABLES = startup.sym startup.mod
TTABLES = test1.sym test1.mod daytime.sym daytime.mod

LIBFILES = cprintf.o strtoul.o bioscall.o crt0.o


all:	test $(TARGET).hex $(TARGET).bin $(TABLES)
test:	test4.bin test3.bin test2.bin test1.bin #daytime.bin $(TTABLES)
alles:	all test
cfd:	cfdisk.out

ide:	ppide2.o
dt:	daytime.out
fdc:	fdc8272.o wd37c65.o floppy.o



cpm68.bin:	$(TARGET).bin rom/rom400.bin
	@echo
	@echo	to make CPM68.BIN execute the following batch file:
	@echo	CPM.bat	 	# which will do the concatenation
	

main68.o:	main68.c $(HFILES)
	$(CC) -S $(COPT) -DBIOSSIZE=$(BIOSSIZE) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

cprintf.o:	cprintf.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

packer.o:	packer.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

crc32.o:	crc32.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

malloc.o:	malloc.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

#mem4mem.o:	mem4mem.c $(HFILES)
#	$(CC) -S $(COPT) $*.c
#	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

fdc8272.o:	fdc8272.c fdc8272.h $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

wd37c65.o:	wd37c65.c wd37c65.h $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

ppide2.o:	ppide2.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

setup.o:	setup.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

rtc.o:	rtc.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

ns202.o:	ns202.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

debug.o:	debug.c $(HFILES) $(HSFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

disasm.o:	disasm.c $(HFILES) $(HSFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

strtoul.o:	strtoul.c $(HFILES)
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

startup.out:	startup.o bios.a
	$(LD) $(LOPT) -s -Map startup.map -o startup.out startup.o \
		bios.a $(LIBS)

$(TARGET).hex:	startup.out
	bin2hex -s 0x2000 -o $(TARGET).hex startup.out

$(TARGET).bin:	$(TARGET).hex
	hex2bin -R $(BIOSSIZE)k $(TARGET).hex $(INC) -o $(TARGET).bin

mylib.a:   $(LIBFILES)
	$(LIB) -r $*.a $(LIBFILES)

bios.a:	   $(OFILES)
	$(LIB) -r $*.a $(OFILES)

startup.mod:	startup.out
	grep ".text" $*.map | grep -v ".o)" | grep ".o" | \
		grep -v "set to" | sed "s/.text/     /" > $*.mod

startup.sym:	startup.out
	grep "                " $*.map | grep -v "=" | grep -v "(" | \
		grep -v LONG | grep -v "                 " | sort > $*.sym


test1.out:	test1.o
	$(LD) $(LOPT) $(LIBS) -s -Map test1.map -o test1.out test1.o

test1.bin:	test1.out
	bin2hex -s 0x2000 test1.out -o test1.hex
	hex2bin -R 8k test1.hex -o test1.bin

test1.mod:	test1.out
	grep ".text" $*.map | grep -v ".o)" | grep ".o" | \
		grep -v "set to" | sed "s/.text/     /" > $*.mod

test1.sym:	test1.out
	grep "                " $*.map | grep -v "=" | grep -v "(" | \
		grep -v LONG | grep -v "                 " | sort > $*.sym



test2.out:	test2.o
	$(LD) $(LOPT) $(LIBS) -s -Map test2.map -o test2.out test2.o

test2.bin:	test2.out
	bin2hex -s 0x2000 test2.out -o test2.hex
	hex2bin -R 8k test2.hex -o test2.bin

test2.mod:	test2.out
	grep ".text" $*.map | grep -v ".o)" | grep ".o" | \
		grep -v "set to" | sed "s/.text/     /" > $*.mod

test2.sym:	test2.out
	grep "                " $*.map | grep -v "=" | grep -v "(" | \
		grep -v LONG | grep -v "                 " | sort > $*.sym


test3.out:	test3.o
	$(LD) $(LOPT) $(LIBS) -s -Map test3.map -o test3.out test3.o

test3.bin:	test3.out
	bin2hex -s 0x2000 test3.out -o test3.hex
	hex2bin -R 8k test3.hex -o test3.bin

test3.mod:	test3.out
	grep ".text" $*.map | grep -v ".o)" | grep ".o" | \
		grep -v "set to" | sed "s/.text/     /" > $*.mod

test3.sym:	test3.out
	grep "                " $*.map | grep -v "=" | grep -v "(" | \
		grep -v LONG | grep -v "                 " | sort > $*.sym


test4.o:	test3.s memtest2.s uart.s biostrap.s
	$(AS) $(AOPT) --defsym SIZE=64 -a=$*.lst -o $*.o test3.s

test4.out:	test4.o
	$(LD) $(LOPT) $(LIBS) -s -Map test4.map -o test4.out test4.o

test4.bin:	test4.out
	bin2hex -s 0x2000 test4.out -o test4.hex
	hex2bin -R 8k test4.hex -o test4.bin

test4.mod:	test4.out
	grep ".text" $*.map | grep -v ".o)" | grep ".o" | \
		grep -v "set to" | sed "s/.text/     /" > $*.mod

test4.sym:	test4.out
	grep "                " $*.map | grep -v "=" | grep -v "(" | \
		grep -v LONG | grep -v "                 " | sort > $*.sym




#  cat startup.mod startup.sym | sed -e "s/        / /g" | sort >foo

daytime.o:	daytime.c bioscall.h
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

daytime.out:	daytime.o mylib.a
	$(LD) $(UOPT) -s -Map daytime.map -o daytime.out \
		daytime.o mylib.a $(LIBS)
#	bin2hex -s 0x1000 daytime.out -o daytime.hex
#	hex2bin -R 8k daytime.hex -o daytime.bin

daytime.bin:	daytime.out
	bin2hex -s 0x1000 daytime.out -o daytime.hex
	hex2bin -R 8k daytime.hex -o daytime.bin

daytime.sym:	daytime.out
	grep "                " $*.map | grep -v "=" | grep -v "(" | \
		grep -v LONG | grep -v "                 " | sort > $*.sym

daytime.mod:	daytime.out
	grep ".text" $*.map | grep -v ".o)" | grep ".o" | \
		grep -v "set to" | sed "s/.text/     /" > $*.mod


cfdisk.o:	cfdisk.c cfdisk.h mytypes.h portab.h bioscall.h ide.h packer.h
	$(CC) -S $(COPT) $*.c
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s

cfdisk.out:	cfdisk.o n8iox.o packer.o mylib.a
	$(LD) $(UOPT) -s -Map cfdisk.map -o cfdisk.out \
		cfdisk.o n8iox.o packer.o mylib.a $(LIBS)


tidy:	
	rm -f startup.out
	rm -f startup.mod
	rm -f startup.sym
	rm -f *.lst *.LST
	rm -f *.map

clean:	tidy
	rm -f *.o
	rm -f *.a
	rm -f *.hex
	rm -f *.bin *.BIN
	rm -f *.out
	rm -f $(CSFILES)


# debugging disasm.c
disasm2.o:	disasm2.s
	$(AS) $(AOPT) -a=$*.lst -o $*.o $*.s


## Dependencies
startup.o:	startup.s $(SFILES)
mem4mem.o:	mem4mem.s
serial.o:	serial.s  $(SFILES)
dualide.o:	dualide.s $(SFILES)
ppide.o:	ppide.s $(SFILES)
dualsd.o:	dualsd.s $(SFILES)
pic202.o:	pic202.s $(SFILES)
bios8.o:	bios8.s $(SFILES)
bioscall.o:	bioscall.s $(SFILES)
test1.o:	test1.s memtest.s biostrap.s
test2.o:	test2.s memtest2.s uart.s biostrap.s
test3.o:	test3.s memtest2.s uart.s biostrap.s
ds1302.o:	ds1302.s $(SFILES)
floppy.o:	floppy.s $(SFILES)

foo.o:		foo.c
time.o:		time.c $(HFILES)
crctab.o:	crctab.c crc7tab.h
crt0.o:		crt0.s

beetle.o:	beetle.s
n8iox.o:	n8iox.s
testcase.o:	testcase.s
