10 '**************************
20 ' T/S EDIT
30 ' COPYRIGHT 1983
40 ' DALE LEAR SOFTWARE INC.
50 '**************************
60 '
70 PALETTE 8,63:PALETTE 9,8:CLS 1
71 POKE &HD7C0,0:POKE &HD816,&H14
80 'xxxxxxxxxxxxxxxxxxxxxxxxxx
90 'xxxxxxxxxxxxxxxxxxxxxxxxxx
100 'THE FOLLOWING SECTION
110 ' SHOULD BE EDITED TO
120 ' SET UP THE DESIRED
130 ' DEFAULT PARAMETERS
140 '
150 '--------------------------
160 'SET VM= VIDEO MODE
170 '0-BLACK ON WHITE
180 '1-WHITE ON BLACK
190 '2-BLACK ON GREEN
200 '3-GREEN ON BLACK
210 VM=2
220 '--------------------------
230 'DISPLAY MODE
240 ' 0-32*16            -LO RES
250 ' 1-32*16 VIRTUAL 80 -LO RES
260 ' 2-32*16            -HI RES
270 ' 3-32*16 VIRTUAL 80 -HI RES
280 ' 4-40*24            -HI RES
290 ' 5-50*24            -HI RES
300 ' 6-60*24            -HI RES
310 ' 7-60*32            -HI RES
320 ' 8-80*24            -HI RES
330 ' 9-80*32            -HI RES
340 DM=4
350 '--------------------------
360 '
370 'SET SH= SHIFT LOCK
380 '0-UPPER/LOWER CASE
390 '1-ALL CAPS
400 SH=0
410 '--------------------------
420 '
430 'SET EM=EDITOR MODE
440 '0-PROGRAM
450 '1-TEXT
460 EM=0
470 '--------------------------
480 'TAB MODE
490 '0-TABS INSERTED
500 '1-BLANKS INSERTED
510 TM=1
520 '--------------------------
530 '
540 'SET TB=TAB STOP
550 ' POSSIBLE VALUES:
560 '
570 ' (MUST BE 1,2,4, OR 8)
580 TB=4
590 '
600 '--------------------------
610 '
620 'SET BD= PRINTER BAUD RATE
630 BD=1200
640 'xxxxxxxxxxxxxxxxxxxxxxxxxx
650 'xxxxxxxxxxxxxxxxxxxxxxxxxx
660 '     BELOW THIS POINT
670 '  SHOULD BE LEFT UNTOUCHED
680 '
690 K=&H200
700 POKE K+0,VM: POKE K+1,DM
710 POKE K+2,255*SH:POKE K+3,EM
720 POKE K+4,TM:POKE K+5,TB-1:
730 POKE 150,INT(55200//BD-5)
740 LOADM"TSEDIT"
750 EXEC
