10 DIM A(256)
20 LOADM"BSCTOOL
30 INPUT "FILENAME";F$
40 HSCREEN 2
50 EXEC:R:L:F$
60 B=&H60000
70 FOR I=0 TO 255
80 A(I)=0
90 NEXT
95 ONBRK GOTO 170
100 POKE &HFFD9,0
110 FOR I=B TO B+32000
120 V=BUTTON(I)
140 A(V)=A(V)+1
150 LPOKE I,0
160 NEXT
170 POKE &HFFD8,0
180 POKE 150,41
190 PRINT #-2,F$
200 FOR I=0 TO 255
210 IF A(I)=0 THEN 230
220 PRINT #-2,I,A(I)
230 NEXT
