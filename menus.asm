
* Menus
*
* Menu routines and associated data
*
* Programmed by Rick Adams
*
* (c) copyright 1987 Activision
*


* Title page menu
*
TPMENU
 FCB 1,10
 FDB Z@-*
 FDB MZAP-*
RGBSEL
 FCB 20,1   column, row
 FDB A@-*
 FDB MRGB-*
CMPSEL
 FCB 27,1
 FDB B@-*
 FDB MCMP-*
 FCB $FF
A@
 FCN "@ RGB"
B@
 FCN "@ Composite"
Z@
 FCN " "

* Main menu
*
MNMENU
 FCB 12,8 column, row
 FDB A@-*
 FDB MM1-*
 FCB 12,10
 FDB B@-*
 FDB MAIN2-*
 FCB 12,12
 FDB C@-*
 FDB MM3-*
 FCB 12,14
 FDB D@-*
 FDB MM4-*
 FCB 12,16
 FDB E@-*
 FDB MM5-*
 FCB 12,18
 FDB F@-*
 FDB MAIN6-*
 FCB $FF
A@
 FCN "Play Solitaire"
B@
 FCN "Begin Again"
C@
 FCN "Select a Dragon"
D@
 FCN "Tournament Play"
E@
 FCN "Challenge Match"
F@
 FCN "Return to Game"

* Game screen menu
*
GMMENU
 FCB 4,0 column, row
 FDB QMENU-* "Menu"
 FDB GM1-*
 FCB 10,0
 FDB QUNDO-* "Undo"
 FDB GM2-*
 FCB 16,0
 FDB QFIND-* "Find"
 FDB GM3-*
 FCB 22,0
 FDB QCANCE-* "Cancel"
 FDB GM4-*
 FCB 30,0
 FDB QPEEK-* "Peek"
 FDB GM5-*
 FCB $FF
QMENU
 FCN "Menu"
QUNDO
 FCN "Undo"
QFIND
 FCN "Find"
QCANCE
 FCN "Cancel"
QPEEK
 FCN "Peek"

* Dragon menu
*
DGMENU
 FCB 12,5 pairs to kong
 FDB A@-*
 FDB DM1-*
 FCB 12,7 fours galore
 FDB B@-*
 FDB DM2-*
 FCB 12,9 four winds
 FDB C@-*
 FDB DM3-*
 FCB 12,11 bam bam
 FDB D@-*
 FDB DM4-*
 FCB 12,13 crak king
 FDB E@-*
 FDB DM5-*
 FCB 12,15 dots across
 FDB F@-*
 FDB DM6-*
 FCB 12,17 dragon rider
 FDB G@-*
 FDB DM7-*
 FCB 12,19 dragon's song
 FDB H@-*
 FDB DM8-*
 FCB 12,21 return to menu
 FDB QRETUR-*
 FDB DM9-*
 FCB $FF
A@
 FCN "Pairs to Kong"
B@
 FCN "Fours Galore"
C@
 FCN "Four Winds"
D@
 FCN "Bam Bam"
E@
 FCN "Crak King"
F@
 FCN "Dots Across"
G@
 FCN "Dragon Rider"
H@
 FCN "Dragon's Song"
QRETUR
 FCN "Return to Menu"

* Peek menu
*
PKMENU
 FCB 17,12   column, row
 FDB QYES-*
 FDB PM1-*
 FCB 17,14
 FDB QNO-*
 FDB PM2-*
 FCB $FF
QYES
 FCN "Yes"
QNO
 FCN "No"

* Challenge menu
*
CHMENU
 FCB 11,9 column, row
 FDB A@-*
 FDB CH1-*
 FCB 11,11
 FDB B@-*
 FDB CH2-*
 FCB 11,13
 FDB C@-*
 FDB CH3-*
 FCB 11,15
 FDB D@-*
 FDB CH4-*
 FCB 11,17
 FDB QRETUR-*
 FDB CH5-*
 FCB $FF
A@
 FCN "10 seconds"
B@
 FCN "20 seconds"
C@
 FCN "30 seconds"
D@
 FCN "60 seconds"

* Challenge match game screen menu
*
CGMENU
 FCB 4,0 column, row
 FDB QQUIT-* "Quit"
 FDB CG1-*
 FCB 24,0
 FDB QCANCE-* "Cancel"
 FDB CG2-*
 FCB $FF
QQUIT
 FCN "Quit"

* Tournament menu
*
TOMENU
 FCB 6,8 column, row
 FDB A@-*
 FDB TO1-*
 FCB 6,10
 FDB B@-*
 FDB TO2-*
 FCB 6,12
 FDB QRETUR-*
 FDB TO3-*
 FCB $FF
A@
 FCN "Begin 5 minute tournament"
B@
 FCN "Begin 10 minute tournament"

* Tournament game screen menu
*
TGMENU
 FCB 4,0 column, row
 FDB QQUIT-* "Quit"
 FDB TG1-*
 FCB 10,0
 FDB QUNDO-* "Undo"
 FDB TG2-*
 FCB 22,0
 FDB QCANCE-* "Cancel"
 FDB TG3-*
 FCB $FF

* Tournament scoreboard menu
*
SCMENU
 FCB 28,22   column, row
 FDB QYES-*
 FDB SC1-*
 FCB 33,22
 FDB QNO-*
 FDB SC2-*
 FCB $FF

* Peek game screen menu
*
PGMENU
 FCB 4,0 column, row
 FDB QQUIT-* "Quit"
 FDB PG1-*
 FCB 10,0
 FDB QUNDO-* "Undo"
 FDB PG2-*
 FCB $FF

* Draw menu
*
* U -> menu table
*
DMENU
 PSHS U
 STU CURMNU
 CLRA
 CLRB
 STD MNUPTR
DMENU0
 LDD ,U++
 BLT XDMENU
 LBSR CPOS   get position
 LDD ,U
 PSHS U
 LEAU D,U
 LBSR MSG    draw the item
 PULS U
 LEAU 4,U
 BRA DMENU0

XDMENU
 PULS U,PC

*convert text col,row to voffset
*
* A is col, B is row
* returns with voffset in X
*
CPOS
 PSHS A    save column
 LDX #SCREEN

 PSHS B   row
CPOSL
 DEC ,S
 BLT XCPOSL
 LEAX 160*8,X
 BRA CPOSL

XCPOSL
 LEAS 1,S

 PULS A   get column back
 LDB #4
 MUL
 LEAX D,X
 RTS

*convert text col,row to voffset
*
* A is col, B is row
* returns with voffset in X
*
CPOS9
 PSHS A    save column
 LDX #SCREEN

 PSHS B   row
C9OSL
 DEC ,S
 BLT X9POSL
 LEAX 160*9,X
 BRA C9OSL

X9POSL
 LEAS 1,S

 PULS A   get column back
 LDB #4
 MUL
 LEAX D,X
 RTS

* Update menu
*
* U -> menu table
*
UMENU
 LDA CURSXY+1
 LDB #3
 MUL
 STD TEMPY
 LDA CURSXY
 LDB #5
 MUL
 STD TEMPX
UMENUL
 LDD ,U     column, row
 LBLT XUMENU
* figure out x,y range for menu item
 PSHS A save column
 LDA #8 convert row to character pos
 MUL
 STD ITEMY1
 ADDB #8
 STD ITEMY2
 PULS A get column back
 LDB #8 convert column
 MUL
 STD ITEMX1

*derive len of message
 LEAX 2,U
 LDD 2,U
 LEAX D,X
 LDA #$FF
A@
 INCA
 TST ,X+
 BNE A@

 LDB #8
 MUL
 ADDD ITEMX1
 STD ITEMX2

* is the cursor within the range?
 LDD TEMPX
 CMPD ITEMX1
 LBLO UMENUX
 CMPD ITEMX2
 LBHI UMENUX
 LDD TEMPY
 CMPD ITEMY1
 BLO UMENUX
 CMPD ITEMY2
 BHI UMENUX

* pointing to this item!
 LDD MNUPTR
 BEQ UMENU1
* used to point to something
 PSHS U
 CMPD ,S++
 BNE UMENU0
 RTS         same thing, so forget it
* used to point to something else
* have to de-highlight old item,
* highlight new item
UMENU0
 PSHS U
 LDU MNUPTR
* de-highlight
 LDD ,U++
 LBSR CPOS
 LDD ,U
 LEAU D,U
 LBSR CUROFF
 LBSR MSG de-highlight
 LBSR CURON
 PULS U
 STU MNUPTR
* highlight
 LDD ,U++
 LBSR CPOS
 LDD ,U
 LEAU D,U
 INC HFLAG
 LBSR CUROFF
 LBSR MSG highlight
 LBRA CURON

* didn't point to anything previously
* so just highlight this item
UMENU1
 STU MNUPTR remember this item
* kludge to change color set
 LEAU RGBSEL,PCR
 CMPU MNUPTR
 BNE A@
 LEAU RGBSET,PCR
 LBSR CLRSET
A@
 LEAU CMPSEL,PCR
 CMPU MNUPTR
 BNE B@
 LEAU CMPSET,PCR
 LBSR CLRSET
B@
 LDU MNUPTR
 LDD ,U++
 LBSR CPOS
 LDD ,U
 LEAU D,U
 INC HFLAG
 LBSR CUROFF
 LBSR MSG highlight
 LBRA CURON

UMENUX
* try next menu item
 LEAU 6,U
 LBRA UMENUL

* not pointing to anything
XUMENU
 LDD MNUPTR
 BEQ XXUMNU
* used to point to something
* have to de-highlight old item
 TFR D,U
 LDD ,U++
 LBSR CPOS
 LDD ,U
 LEAU D,U
 LBSR CUROFF
 LBSR MSG de-highlight
 LBSR CURON
 CLRA
 CLRB
 STD MNUPTR forget old item

XXUMNU
 RTS

* Execute menu item
XMENU
 LDD MNUPTR
 BEQ XMENUX
 TFR D,U
 LEAU 4,U
 LDD ,U
 LEAS 2,S
 JMP D,U

XMENUX
 RTS

* draw menu border
*
BORDER
 INC BORDF
 LDX #SCREEN+4*160+1
 LDB #$00
* upper left corner detail
 STB -160-1,X
 STB -2*160-1,X
 LDA #39
* top 
 PSHS A
A@
 DEC ,S
 BLT B@
 LBSR HLINES
 LDB #'#
 LBSR PUT
 BRA A@
B@
 PULS A
* upper right corner detail
 LDB #$00
 STB -160,X
 STB -2*160,X
* bottom
 LDX #SCREEN+187*160+1
 LDA #39
 PSHS A
C@
 DEC ,S
 BLT D@
 LBSR HLINES
 LDB #'#
 LBSR PUT
 BRA C@
D@
 PULS A
* lower right corner detail
 LDB #$00
 STB 8*160,X
 STB 9*160,X
* left
 LDX #SCREEN+4*160+1
 LDA #24
 PSHS A
E@
 DEC ,S
 BLT F@
 BSR VLINES
 LDB #'#
 LBSR PUT
 LEAX 8*160-4,X
 BRA E@
F@
 PULS A
* lower left corner detail
 LDB #$00
 STB -1,X
*right
 LDX #SCREEN+4*160+1
 LEAX 38*4,X
 LDA #24
 PSHS A
G@
 DEC ,S
 BLT H@
 BSR VLINES
 LDB #'#
 LBSR PUT
 LEAX 8*160-4,X
 BRA G@
H@
 CLR BORDF
 PULS A,PC

VLINES
 PSHS X
 LDD #$0008
A@
 STA -1,X
 STA 4,X
 LEAX 160,X
 DECB
 BNE A@
 PULS X,PC

HLINES
 LDD #$0000
 STD -2*160,X
 STD -2*160+2,X
 STD -160,X
 STD -160+2,X
 STD 8*160,X
 STD 8*160+2,X
 STD 9*160,X
 STD 9*160+2,X
 RTS

* text menu
*
* U -> menu table
*
TMENU
 STU CURMNU
 LBSR BORDER
TMENUS
 LDU CURMNU
 LBSR DMENU
A@
 LDD SEED1 randomize
 ADDD #1
 STD SEED1
 LDB #1
 LBSR CURSOR
 LDU CURMNU
 LBSR UMENU
 LDB #1
 LBSR BUTTON
 BEQ A@
 LBSR XMENU
 BRA A@
