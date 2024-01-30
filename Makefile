
all:	test

test: shanghai.asm
	lwasm -l -9 -b -o shanghai.bin shanghai.asm > shanghai.lst
ifneq ("$(wildcard /media/share1/COCO/drive3.dsk)","")
	decb copy -r -2 -b shanghai.bin /media/share1/COCO/drive3.dsk,SHANGHAI.BIN
endif
	rm -f redistribute/shanghai.dsk
	decb dskini redistribute/shanghai.dsk
	decb copy -r -2 -b shanghai.bin redistribute/shanghai.dsk,SHANGHAI.BIN
