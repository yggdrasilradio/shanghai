
all:	test

test: shanghai.asm
	lwasm -l -9 -b -o shanghai.bin shanghai.asm > shanghai.lst
	decb copy -r -2 -b shanghai.bin /media/share1/COCO/drive3.dsk,SHANGHAI.BIN
	rm -f redistribute/shanghai.dsk
	decb dskini redistribute/shanghai.dsk
	decb copy -r -2 -b shanghai.bin redistribute/shanghai.dsk,SHANGHAI.BIN

release:
	rcp redistribute/shanghai.dsk ricka@rickadams.org:/home/ricka/rickadams.org/downloads/shanghai.dsk
	(cd /home/rca/projects; zip -r /tmp/shanghai.zip shanghai)
	rcp /tmp/shanghai.zip ricka@rickadams.org:/home/ricka/rickadams.org/downloads/shanghai.zip
	rm -f /tmp/shanghai.zip
