
* Shanghai - Color Computer 3 version
*
* (c) copyright 1987 Activision
*
* Programmed by Rick Adams
*
* Shanghai designed by Brodie Lockard
*
* Project management:
*    Sherry Whiteley (Activision)
*    Gene Schenberg (Tandy)
*
* Graphics by Doug Barnett
*
* Testing:
*    Keith Orr
*    Alex Edelstein
*

SCREEN EQU $8000

* TILE TABLE FORMAT:
*  ,U tile id
* 1,U pixel offset
* 3,U left
* 4,U right
* 5,U up
* 6,U down

 ORG 0
**************** base page
WINSET RMB 1
MONTYP RMB 1
DISABL RMB 1
WON    RMB 1
SAVED  RMB 1
WARN10 RMB 1 10 sec warning
WARN1  RMB 1 1 min warning
STUCK  RMB 1
CSTAT  RMB 1
FF91   RMB 1
FIND1  RMB 1
FIND2  RMB 1
BORDF  RMB 1 "in border" flag
FACE   RMB 5
TLPOS  RMB 1
TMOUT  RMB 1 number of timeouts
SCORES RMB 2 challenge match scores
NAMPTR RMB 2
NAMCNT RMB 1
TSCORE RMB 1 tournament player score
KEYON  RMB 1
CURMNU RMB 2 current menu
VMOVE  RMB 1 valid move flag
PLAYER RMB 1
TCOLOR RMB 1 tile mark color
TCOLP  RMB 2 tile mark pointer
TCOLC  RMB 1 tile mark counter
ROMSON RMB 1 "ROMs on" flag
MTIMER RMB 1 transient countdown timer
DRAGID RMB 1 selected dragon
OLDTIM RMB 1
TICKS  RMB 1
TOCKS  RMB 1
MINS   RMB 1
SECS   RMB 1
STILE1 RMB 3 selected tile
STILE2 RMB 3
COUNT  RMB 1
MNUPTR RMB 2
CMASK  RMB 1
CURSXY RMB 2
SEED1  RMB 1
SEED2  RMB 1
LSW    RMB 1
RSW    RMB 1
CURSX  RMB 2
CURSY  RMB 1
TILEX  RMB 2
TILEY  RMB 1
TEMPX  RMB 2
TEMPY  RMB 2
HFLAG  RMB 1
ITEMX1 RMB 2
ITEMX2 RMB 2
ITEMY1 RMB 2
ITEMY2 RMB 2
TLIMIT RMB 1 time limit

 ORG $1000
**************** RAM storage
STACK  RMB 1
TILES  RMB 144*7
HISTRY RMB 144
SCBORD RMB 24*10 scoreboard
NAME   RMB 20
CACHE  RMB 6*10

 ORG $1700

BEGIN
 LBRA START

*Composite Color set
CMPSET
 FCB 0     black            0
 FCB 37    yellow           1
 FCB 26    dark purple      2
 FCB 04    orange/brown     3
 FCB 15    dark green       4
 FCB 7     dark red         5
 FCB 12    blue             6
 FCB 11    dark blue        7
 FCB 38    light orange     8
 FCB 11    background dkblu 9
 FCB 16    tile edge dk greyA
 FCB 16    tile grout dkgreyB
 FCB 63    tile border whiteC
 FCB 63    blinking hilite  D
 FCB 32    grey             E
 FCB 63    tile white       F

;     00RG BRGB
; $00 0000 0000 black
; $07 0000 0111 dark grey
; $38 0011 1000 light grey
; $3f 0011 1111 white

;     00RG BRGB
; $02 0000 0010 dark green
; $10 0001 0000 green
; $12 0001 0010 bright green

;     00RG BRGB
; $04 0000 0100 dark red
; $20 0010 0000 red
; $24 0010 0100 bright red

;     00RG BRGB
; $01 0000 0001 dark blue
; $08 0000 1000 blue
; $09 0000 1001 bright blue

*RGB Color set
*$00,$37,$28,$22,$15,$24,$0d,$0c,$26,$0c,$07,$07,$3f,$3f,$38,$3f cartridge
RGBSET
 FCB $00 ; black            0
 FCB $37 ; yellow           1 menu border weave color
 FCB $28 ; dark purple      2
 FCB $22 ; pumpkin orange   3
 FCB $15 ; dark green       4
 FCB $24 ; dark red         5
 FCB $0d ; blue             6
 FCB $0c ; dark blue        7
 FCB $26 ; light orange     8
 FCB $01 ; dark blue        9 background
 FCB $38 ; light grey	    A tile edge
 FCB $07 ; dark grey	    B tile face outline
 FCB $3f ; white	    C tile face discoloration
 FCB $3f ; blinking hilite  D
 FCB $38 ; light grey       E
 FCB $3f ; white            F tile face

*Previous RGB color set
ZAPSET
 FCB $00 ; black            0
 FCB $37 ; yellow           1 menu border weave color
 FCB $28 ; dark purple      2
 FCB $22 ; pumpkin orange   3
 FCB $15 ; dark green       4
 FCB $24 ; dark red         5
 FCB $0d ; blue             6
 FCB $0c ; dark blue        7
 FCB $26 ; light orange     8
 FCB $0c ; dark blue        9 background
 FCB $37 ; dark grey	    A tile edge
 FCB $38 ; dark grey	    B tile face outline
 FCB $3e ; light yellow	    C tile face discoloration
 FCB $3f ; blinking hilite  D
 FCB $38 ; light grey       E
 FCB $3f ; white            F tile face

START
 ORCC #$50
 CLRA
 TFR A,DP
 LDS #STACK

*load into RAM
 ;LEAX BEGIN,PCR
 ;LDY #$3000
A@
 ;LDD ,X++
 ;STD ,Y++
 ;CMPY #BEGIN+$3F00
 ;BLS A@

*dispatch to warmstart address
 ;LDX #$3000
 ;LEAX WARM-BEGIN,X
 ;JMP ,X

*warmstart address
WARM
*clear base page
 CLRA
 CLRB
 TFR D,X
A@
 CLR ,X+
 DECA
 BNE A@

*NOP
*LEAU WARM,PCR take over reset
*CLR $FF40
*STU $72
*LDA #$55
*STA $71
 LBSR MINIT
 LBSR TASK0

 CLR $FFD9    fast CPU
 STB $FFDF    64k mode
 
 ;LEAU CMPSET,PCR default colorset
 LEAU RGBSET,PCR default colorset
 LBSR CLRSET
A@
 LBSR VINIT

 LBSR CLBORD clear scoreboard

*init clock
 LEAU IRQ,PCR
 STU $10D
 LDA $FF03
*ORA #3 ; (bad?)
 ORA #1 ; (better?)
 STA $FF03
 ANDCC #$EF start clock

* title page
 LBSR CLS
 LDA #6
 LDB #7
 LBSR CPOS
 LEAX 2*160,X
 LEAU TITLE2,PCR copyright
 LBSR MSG
 LDA #1
 LDB #22
 LBSR CPOS
 LEAX -160,X
 LEAU GENE1,PCR
 LBSR MSG
 LDA #1
 LDB #23
 LBSR CPOS
 LEAU GENE2,PCR
 LBSR MSG
 LDA #26
 LDB #22
 LBSR CPOS
 LEAX -160,X
 LEAU RICK1,PCR
 LBSR MSG
 LDA #29
 LDB #23
 LBSR CPOS
 LEAU RICK2,PCR
 LBSR MSG

 LBSR LETRNG "shanghai" lettering

 LDA #9
 STA DRAGID
 LBSR GDRAGN
 CLR DRAGID
 LBSR DRAGON
; LBSR CHIME
; LEAU ZPROG,PCR memory length check
; CMPU #$7000
; BLO MOK
; LBSR PING
MOK

 ;LBSR DELAY
 ;LBSR DELAY

 LDD #$0101
 LBSR CPOS
 LEAU TITLE1,PCR "color set"
 LBSR MSG
 LBSR CHIME

 LEAU TPMENU,PCR
 STU CURMNU
 LBRA TMENUS

TITLE1
 FCN "color set:"
TITLE2
 FCC "* 1986-87 "
 FCN "Activision, Inc."
RICK1
 FCN "Programmed by"
RICK2
 FCN "Rick Adams"
GENE1
 FCN "Designed by"
GENE2
 FCN "Brodie Lockard"

* Embedded text message for my friend
* Don Hutchison

 FCC "***  HI DON!  "
 FCC "  GOOD TO SEE YOU AGAIN!  ***"

MZAP
 LEAU ZAPSET,PCR
 INC MONTYP
 BRA C@
MRGB
 LEAU RGBSET,PCR
C@
 LBSR CLRSET
 INC MONTYP
 LDB #$90 turn off color burst
 STB $FF98 video mode register
 BRA INIT
MCMP
 LEAU CMPSET,PCR
 LBSR CLRSET
INIT
 LBSR GDRAGN

* main menu
MAIN
DM9
GM1
TO3
CH5
 LBSR CLS
 LDD #$0905
 LBSR CPOS
 LEAU MNHEAD,PCR
 LBSR MSG
 LEAU MNMENU,PCR
 LBRA TMENU

** begin again
MAIN2
 TST TLIMIT
 BEQ MM2
 LBSR PING
 BRA MAIN

** return to game
MAIN6
 TST TLIMIT
 BEQ MM6
 LBSR PING
 BRA MAIN

* solitaire
MM1
 CLR TLIMIT
BA
 LBSR GDRAGN
 CLR DRAGID
* begin again
MM2
 LBSR RESTOR
* return to game
MM6
PM2
 TST COUNT no tiles?
 BEQ BA begin again
 LBSR CLS

 LBSR DRAGON draw dragon
 LBSR UCOUNT
 TST TLIMIT
 LBGT CHGAME challenge game?
 LBLT TOGAME tournament game?

*game screen menu
 LEAU GMMENU,PCR
 LBSR DMENU
 LBSR CLTILE

GMLOOP
 LDB #1
 LBSR CURSOR		****
 LEAU GMMENU,PCR
 LBSR UMENU		****
 LDB #1
 LBSR BUTTON		****
 BEQ GMLOOP

 LBSR XMENU

*tile selected?
 LBSR SELECT
 TSTB
 BEQ GMLOOP
 LBSR MOVE
 TST WON
 LBNE MAIN
 BRA GMLOOP

*** menu bar options

*undo
GM2
 LBSR UNDO
 LBRA GMLOOP
*find
GM3
 LBSR FIND
 LBRA GMLOOP
*cancel
GM4
 LBSR CANCEL
 LBRA GMLOOP

**** process move
MOVE
 CLR VMOVE
 CLR WON

* click on a non-free tile?
 LBSR FREE
 BNE NTFREE

* second click on second tile?
 CMPU STILE2
 LBEQ RMTILE

* second click on first tile?
 CMPU STILE1
 BNE C11T  no
 LDD FIND1 find in progress?
 LBEQ CANCEL if not, cancel
 LBRA RMTILE if so, remove

* first click on first tile?
C11T
 LDY STILE1
 LBEQ T1CLIK

* first click on second tile?
 LDY STILE2
 LBEQ T2CLIK
 RTS

* first click on first tile
T1CLIK
 LBSR CLICK
 STU STILE1
 STB STILE1+2
 LBRA HILITE

NTFREE
 LBSR PING
 LBSR CANCEL
 LEAX NTFR1,PCR
 LEAY NTFR2,PCR
 LBRA UMSG

NTFR1
 FCN "Tile is"
NTFR2
 FCN "not free"

* first click on second tile
T2CLIK

*check to see if tiles match
 LDY STILE1
 LBSR MATCH
*BRA RMOKAY * Uncomment this to make any two tiles match
 BNE NOMATC

*they match, go ahead and highlight
RMOKAY
 LBSR CLICK
 STU STILE2
 STB STILE2+2
 LBRA HILITE

* remove the pair of tiles
RMTILE
 LDU STILE1
 LDB STILE1+2
 LBSR REMOVE   remove first tile
 LDU STILE2
 LDB STILE2+2
 LBSR REMOVE   remove second tile
 LBSR UCOUNT
 LBSR CLICK
 LBSR CLTILE
 INC VMOVE
 LBRA VICTOR   victory dragon(?)

* The tiles don't match
NOMATC
 LBSR PING
 LBSR CANCEL cancel first selection
 LEAX NOMT1,PCR
 LEAY NOMT2,PCR
 LBRA UMSG

* Undo
UNDO
 LDD STILE1 if move in progress
 LBNE CANCEL do "cancel" instead
 LDA COUNT
 CMPA #144
 BEQ XUNDO
 BSR TUNDO
 BSR TUNDO
XUNDO
 RTS

*undo last tile removal
TUNDO
 LDX #HISTRY
 LDB COUNT
 CLRA
 LEAX D,X
 LDB ,X B is tile pos
 LDU #TILES
 LDA #7
 PSHS B
 DECB
 MUL
 LEAU D,U
 PULS B
* now U points to tile data
* B is tile pos
 COM ,U un-delete tile
 LBSR REFRES
 INC COUNT count it
 LBRA UCOUNT

* Find
FIND
 LBSR CUROFF
 LBSR CANCL
 CLR STUCK
 LDD FIND1
 BNE FCONT
* for i=0 to 142
A@
 LDA FIND1
 CMPA #142
 BHI Z@
* for j=i+1 to 143
 LDA FIND1
 INCA
 STA FIND2
B@
 LDA FIND2
 CMPA #143
 BHI Y@
* link to tile 1
 LDA FIND1
 INCA
 STA STILE1+2
 DECA
 LDB #7
 MUL
 LDU #TILES
 LEAU D,U
 STU STILE1
* link to tile 2
 LDA FIND2
 INCA
 STA STILE2+2
 DECA
 LDB #7
 MUL
 LDU #TILES
 LEAU D,U
 STU STILE2
 LBSR FREE 1st tile free?
 BNE N@
 LDU STILE1
 LBSR FREE 2nd tile free?
 BNE N@
 LDU STILE1 identical tiles?
 CMPU STILE2
 BEQ N@
 LDY STILE2
 LBSR MATCH tiles match?
 BNE N@
*found something!
 LDU STILE1
 LDB STILE1+2
 LBSR REFRES
 LDU STILE2
 LDB STILE2+2
 LBSR REFRES
 LBSR UCOUNT
 LBRA CURON
* next j
FCONT
N@
 INC FIND2
 BRA B@
Y@
* next i
 INC FIND1
 BRA A@
*didn't find anything
Z@
 INC STUCK
 CLRA
 CLRB
 STD FIND1
 LBSR PING
 LBSR CLTILE
 LEAX NMM1,PCR "No more"
 LEAY NMM2,PCR " Moves"
 LBSR UMSG
 LBRA CURON

NMM1
 FCN " No more"
NMM2
 FCN "  moves"

NOMT1
 FCN "Tile does"
NOMT2
 FCN "not match"

* Cancel
CANCEL
 CLRA
 CLRB
 STD FIND1 cancel find sequence
CANCL
 LDD STILE1
 BEQ Z@
 LDD STILE2
 BEQ A@
* de-highlight tile 2
 LDU STILE2
 LDB STILE2+2
 CLR STILE2
 CLR STILE2+1
 CLR STILE2+2
 LBSR REFRES
A@
* de-highlight tile 1
 LDU STILE1
 LDB STILE1+2
 CLR STILE1
 CLR STILE1+1
 CLR STILE1+2
 LBSR REFRES
Z@
 RTS

TOHEAD
 FCC "Tournament - Select time"
 FCN " limit"

* Tournament menu
MM4
 LBSR CLS
 LDD #$0405
 LBSR CPOS
 LEAU TOHEAD,PCR
 LBSR MSG
 LEAU TOMENU,PCR
 LBRA TMENU

TO1
 LDA #-5
 BRA Z@
TO2
 LDA #-10
Z@
 STA TLIMIT
 LBSR CUROFF
 LEAU TOMENU,PCR
 LBSR DMENU
 LBSR GETNAM
 CLR TSCORE
 LBRA BA

*Tournament game screen menu
TOGAME
 LEAU TGMENU,PCR
 LBSR DMENU
 LBSR CLTILE

 LDA TLIMIT
 NEGA
 STA MINS
 CLR SECS
 CLR TICKS
 LBSR UUTIME

 CLR TSCORE
 LDA #1
 STA PLAYER
 LBSR UTSCOR

TGLOOP
 LDD MINS
 LBEQ ENTOUR
 LDB PLAYER
 LBSR CURSOR
 LEAU TGMENU,PCR
 LBSR UMENU
 LBSR UTIME update timer display

*1 minute warning
 TST WARN1
 BNE A@
 LDD MINS
 CMPD #$0100
 BNE A@
 INC WARN1
 LBSR CHIME
A@
*10 sec warning
 TST WARN10
 BNE B@
 LDD MINS
 CMPD #$000A
 BNE B@
 INC WARN10
 LBSR CHIME
B@
 LDB PLAYER
 LBSR BUTTON
 BEQ TGLOOP
 LBSR XMENU

*tile selected?
 LBSR SELECT
 TSTB
 BEQ TGLOOP
 LBSR MOVE
 TST VMOVE
 BEQ TGLOOP
* update tournament score
 INC TSCORE
 TST WON did player win?
 BNE TG1
 LBSR UTSCOR
 BRA TGLOOP

*** tournament turn is over
TG1
ENTOUR
 LBSR CANCEL
 LBSR CHIME  double chime
 LBSR CHIME
 LBSR POST   post score to scoreboard
 LBSR PTBORD display scoreboard
 LBNE MM2   continue tournament
A@
 CLR DRAGID tournament over
 LBRA INIT

*** tournament game menu bar options

*undo
TG2
 LBSR UNDO
 TST TSCORE
 LBEQ TGLOOP
 DEC TSCORE
 LBSR UTSCOR back up score
 LBRA TGLOOP
*cancel
TG3
 LBSR CANCEL
 LBRA TGLOOP

MNHEAD
 FCN "Shanghai Main Menu:"
DMHEAD
 FCN "Select a Dragon:"

*challenge match game screen menu
CHGAME
 LEAU CGMENU,PCR
 LBSR DMENU
 LBSR CLTILE
 CLR TSCORE
 CLR SCORES
 CLR SCORES+1
 CLR TMOUT
 LDA TLIMIT
 STA SECS
 CLR MINS
 CLR TICKS
 LBSR UUTIME
 LBSR UTSCOR
 LDA #1
 STA PLAYER
 LEAX PLAYR1,PCR
 LDY #0
 LBSR UMSG
 CLR MTIMER
CGLOOP
 LDD MINS
 LBEQ ENTURN
 LDB PLAYER
 LBSR CURSOR
 LEAU CGMENU,PCR
 LBSR UMENU
 LBSR UTIME update timer display
 LDB PLAYER
 LBSR BUTTON
 BEQ CGLOOP
 LBSR XMENU

*tile selected?
 LBSR SELECT
 TSTB
 BEQ CGLOOP
*process move
 LBSR MOVE
*valid move?
 TST VMOVE
 BEQ CGLOOP no, keep on
*valid move
 BRA ENTU0

*** turn is over
ENTURN
* timed out
 LBSR CANCEL
 LBSR CHIME
 INC TMOUT
 LDA TMOUT
 CMPA #4
 LBEQ CHDONE
 BRA Z@
ENTU0
* player scored
 LBSR CHIME
 CLR TMOUT
 INC TSCORE
Z@
 LDX #SCORES-1
 LDA PLAYER
 LEAX A,X
 LDB TSCORE
 STB ,X   put score away
 LBSR UTSCOR show score
 TST COUNT check for no more tiles
 LBEQ CHDONE
 LBSR CUROFF
 LBSR DELAY
 LBSR CURON
* change to next player
 LDA PLAYER
 LDB #1
 LEAX PLAYR1,PCR
 LDY #0
 CMPA #1
 BNE A@
 LEAX PLAYR2,PCR
 INCB
A@
 STB PLAYER
 LBSR UMSG
 CLR MTIMER
 LDX #SCORES-1
 LDB PLAYER
 LEAX B,X
 LDA ,X
 STA TSCORE next players score
 LBSR UTSCOR
 LDA TLIMIT reset timer
 STA SECS
 CLR MINS
 CLR TICKS
 LBSR UUTIME
 LBRA CGLOOP

PLAYR1
 FCN "Player one"
PLAYR2
 FCN "Player two"

*** challenge game menu bar options

*cancel
CG2
 LBSR CANCEL
 LBRA CGLOOP

* Challenge match done
CG1
 CLR DRAGID
 CLR COUNT
CHDONE
 LBSR CHBORD
 LBRA INIT

* tile select sound
*
CLICK
 PSHS D
 LBSR CLIK
 PULS D,PC

* Dragon menu
MM3
 LBSR CLS
 LDD #$0902
 LBSR CPOS
 LEAU DMHEAD,PCR
 LBSR MSG
 LEAU DGMENU,PCR
 LBRA TMENU

DM1
 LDB #1
 BRA DMCOM
DM2
 LDB #2
 BRA DMCOM
DM3
 LDB #3
 BRA DMCOM
DM4
 LDB #4
 BRA DMCOM
DM5
 LDB #5
 BRA DMCOM
DM6
 LDB #6
 BRA DMCOM
DM7
 LDB #7
 BRA DMCOM
DM8
 LDB #8
DMCOM
 STB DRAGID
 LBSR GDRAGN
 LBRA DM9

PKHEAD
 FCC "Peek under tiles and forfeit"
 FCN " game?"

* Peek menu
PEEK
GM5
 LBSR CLS
 TST STUCK dont verify if stuck
 BNE PM1
 LDD #$0206
 LBSR CPOS
 LEAU PKHEAD,PCR
 LBSR MSG
 LEAU PKMENU,PCR
 LBRA TMENU

* Yes
PM1

* Peek game

 LBSR CLS
 LBSR DRAGON
 LBSR UCOUNT

*game screen menu
 LEAU PGMENU,PCR
 LBSR DMENU
 LBSR CLTILE
PGLOOP
 LDB #1
 LBSR CURSOR
 LEAU PGMENU,PCR
 LBSR UMENU
 LDB #1
 LBSR BUTTON
 BEQ PGLOOP
 LBSR XMENU

*tile selected?
 LBSR SELECT
 TSTB
 BEQ PGLOOP
 LBSR REMOVE
 LBSR UCOUNT
 LBSR CLICK
 BRA PGLOOP

*** peek game menu bar options

*quit
PG1
 CLR COUNT prevent cheating
 LBRA MAIN
*undo
PG2
 LDA COUNT
 CMPA #144
 LBEQ PGLOOP
 LBSR TUNDO
 LBRA PGLOOP

CHHEAD
 FCC "CHALLENGE MATCH - Select time"
 FCN " limit"

* Challenge menu
MM5
 LBSR CLS
 LDD #$0206
 LBSR CPOS
 LEAU CHHEAD,PCR
 LBSR MSG
 LEAU CHMENU,PCR
 LBRA TMENU

CH1
 LDA #10
 STA TLIMIT
 LBRA BA
CH2
 LDA #20
 STA TLIMIT
 LBRA BA
CH3
 LDA #30
 STA TLIMIT
 LBRA BA
CH4
 LDA #60
 STA TLIMIT
 LBRA BA

* Highlight tile
* U points to entry in tile table,
* B contains tile position (1-144)
HILITE
 PSHS D,X,Y,U
 LBSR REFRES
 PULS D,X,Y,U,PC

* Remove tile
* U points to entry in tile table,
* B contains tile position (1-144)
REMOVE
 DEC COUNT
 PSHS B       remember this move
 LDX #HISTRY  so we can undo it
 LDB COUNT    later if necessary
 CLRA
 LEAX D,X
 PULS B
 STB ,X     put into history list
 COM ,U     that tile is removed
 LBSR REFRES
 CLRA
 CLRB
 STD FIND1
 RTS


*set colorset
*
* U -> color values
*
CLRSET
 LBSR VSYNC
 LDX #$FFB0
 LDB #16
A@
 LDA ,U+
 STA ,X+
 DECB
 BNE A@
 LDA $FFB9 background
 STA $FF9A border
 RTS

* complete 16-color blank tile
BLANK
 FDB $BBBB,$BBBB,$BBBB,$BBBB,$BBBB,$B000
 FDB $CCCC,$CCCC,$CCCC,$CCCC,$CCCC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFCC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCFF,$FFFF,$FFFF,$FFFF,$FFFC,$B000
 FDB $CCCC,$CCCC,$CCCC,$CCCC,$CCCC,$B000
 FDB $CCCC,$CCCC,$CCCC,$CCCC,$CCCC,$B000
BLANKH
 FDB $BBBB,$BBBB,$BBBB,$BBBB,$BBBB,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000
 FDB $DDDD,$DDDD,$DDDD,$DDDD,$DDDD,$B000

*Clear screen
CLS
 CLR CSTAT
 CLR MTIMER
CLSX
 TST WINSET
 BEQ T@
 CLRA
 CLRB
 BRA U@
T@
 LDD #$9999
U@
 LDX #$7D00
 LDU #SCREEN
CLS0
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 STD ,U++
 LEAX -32,X
 BNE CLS0
 RTS

*Init video 320 x 199 16 colors
VINIT
 LDB #$4C  mmu enabled
 STB $FF90 initialization register
 LDB #$80
 STB $FF98 video mode register
 LDB #$3E 200 lpf
;LDB #$7E 225 lpf?
;LDB #$1E 192 lpf?
 STB $FF99 video resolution register
 CLR $FF9F horiz scroll
TR0
 LDD #$C000 $8000

; $8000 / 8 / 256 MSB  32768 / 8 / 256 = $10
; $8000 / 8 AND $ff LSB = $00

SCLOC0
 STD $FF9D
; STA $FF9D
; STB $FF9E
 RTS

* Mark tile
*
* X -> pixel offset of tile
* B = tile id
MKTILE
 PSHS B,X,U
 PSHS B
 LEAX -1,X mark one pixel to left
 LBSR GCOLOR get mark color
 LSRB
 LSRB
 LSRB
 LSRB
 ANDB #$0F
 DECB       B = tile type
 LEAU MKTBL,PCR
* now U -> mark table
 LSLB
 LEAU B,U
 LDD ,U
 LEAU D,U
* now U -> tile marks for that type
 PULS B
 ANDB #$0F
 DECB
 LDA #3*20
 MUL
 LEAU D,U
* now U -> tile marks for specific tile
 TFR X,D
 PSHS B
 LSRA
 RORB
 TFR D,X
 LBSR FUDGE point to correct byte
 LEAX 160,X
 LEAX 160,X down a couple rows
 PULS B
 ANDB #1
 LDA #$FF
 MUL
 COMB
 INCB over one column
 LDA #20
 PSHS A
MKTL
 DEC ,S
 BLT XMKTL
* X -> screen, U -> mark row
 PSHS X

 LBSR TROW
 LEAU 1,U
 LEAX 4,X
 LBSR TROW
 LEAU 1,U
 LEAX 4,X
 LBSR TROW
 LEAU 1,U
 LEAX 4,X

 PULS X
 LEAX 160,X
 LBSR NCOLOR get next color
 BRA MKTL
XMKTL
 PULS A
 PULS B,X,U,PC

* Mark tile row
*
* U points to 1 byte of mark data
* X points to screen position
TROW
 PSHS X,U,B
 LDA ,U
 PSHS A
TROW0
 LDA ,S
 BEQ TROW2
 INCB
 LSLA
 STA ,S
 BCC TROW0
 TFR X,Y
 TFR B,A
 LSRA
 LEAY A,Y
 TFR B,A
 ANDA #1
 BEQ TROW1
 LDA ,Y
 ANDA #$F0
 STA ,Y
 LDA TCOLOR
 ANDA #$0F
 ORA ,Y
 STA ,Y
 BRA TROW0
TROW1
 LDA ,Y
 ANDA #$0F
 STA ,Y
 LDA TCOLOR
 ANDA #$F0
 ORA ,Y
 STA ,Y
 BRA TROW0
TROW2
 PULS A
 PULS X,U,B,PC

MKTBL
 FDB DRA1-*
 FDB WIN1-*
 FDB SEA1-*
 FDB FLO1-*
 FDB DOT1-*
 FDB CRK1-*
 FDB BAM1-*

* Draw blank tile
*
* X -> pixel offset of tile
* U -> tile data

TILE
 PSHS X,U
*put 21 pixels (11 bytes) across, 24 bytes down
 TFR X,D
 ANDB #1
 BNE ODD

*on even pixel boundary
 TFR X,D
 LSRA
 RORB
 TFR D,X
 LBSR FUDGE
 LDA #24
 PSHS A

LY
 DEC ,S
 BLT XLY
 TFR X,Y

* 11 bytes across
 LDD ,U++
 STD ,Y++
 LDD ,U++
 STD ,Y++
 LDD ,U++
 STD ,Y++
 LDD ,U++
 STD ,Y++
 LDD ,U++
 STD ,Y++
 LDA ,Y
 ANDA #$0F
 ORA ,U+
 STA ,Y+
 LEAU 1,U
 LEAX 160,X go to next screen row
 BRA LY
XLY
 PULS A
 PULS X,U,PC

ODD
*on odd pixel boundary
 TFR X,D
 LSRA
 RORB
 TFR D,X
 LBSR FUDGE
 LDA #24
 PSHS A

OLY
 DEC ,S
 LBLT XOLY
 TFR X,Y

* 11 bytes across
 LDA ,Y      pixel 1
 ANDA #$F0
 STA ,Y
 LDA ,U
 ANDA #$F0
 LSRA
 LSRA
 LSRA
 LSRA
 ORA ,Y
 STA ,Y+

 LBSR TWOPXL 2 and 3
 LBSR TWOPXL 4 and 5
 LBSR TWOPXL 6 and 7
 LBSR TWOPXL 8 and 9
 LBSR TWOPXL 10 and 11
 LBSR TWOPXL 12 and 13
 LBSR TWOPXL 14 and 15
 LBSR TWOPXL 16 and 17
 LBSR TWOPXL 18 and 19
 LBSR TWOPXL 20 and 21

 LEAU 2,U

 LEAX 160,X go to next screen row
 LBRA OLY
XOLY
 PULS A
 PULS X,U,PC

TWOPXL
 LDA ,U+
 LDB ,U
 ANDB #$F0
 LSLB
 ROLA
 LSLB
 ROLA
 LSLB
 ROLA
 LSLB
 ROLA
 STA ,Y+
 RTS

*Draw a dragon
*
DRAGON
 LBSR CLTILE
 LEAX BASES,PCR
A@
 LDA ,X+
 BEQ Z@
 DECA
 LDB #7
 MUL
 LDU #TILES
 LEAU D,U
 LBSR TPILE
 BRA A@
Z@
 LBRA DO144

*translate tile coordinate system
FUDGE
 LEAX 8*160,X room for menu
 LEAX 2,X right justify
 LEAX SCREEN,X screen offset
 RTS

XAXIS1 EQU $15A
YAXIS1 EQU $15B
XAXIS2 EQU $15C
YAXIS2 EQU $15D

* Draw cursor
*
* B = joystick (1=right, 2=left)
*
CURSOR
 LDB #2 ; force left joystick
 PSHS B

 LBSR CURON  turn cursor on
 INC ROMSON  tell IRQ that ROMs on
 STA $FFDE   turn on ROMs
 LBSR TASK1  force task 1
 JSR [$A00A] get joystick values
 CLR ROMSON  tell IRQ that ROMs off
 STA $FFDF   turn off ROMs
 LBSR TASK0

 PULS B      got left
 CMPB #1     want right?
 BEQ CUR0
 LDD XAXIS2
 STD XAXIS1  get left

CUR0
 LDA XAXIS1
 CMPA #62
 BLS CUR1
 LDA #62 dont let arrow wrap-around
CUR1
 LDB YAXIS1
 CMPB #62
 BLS CUR2
 LDB #62
CUR2
 CMPD CURSXY
 BEQ XCURS

 PSHS D save new xy

* erase old cursor
 LBSR CUROFF

* draw new cursor
 PULS D       get new xy back
 STD CURSXY
 LBSR CURON  draw new cursor

XCURS
 RTS
 
* Random number generator
* Entry: B - upper limit
*           (lower limit = 1)
* Exit: B - random number
*
* Routine donated by Jim Issel
*
RND PSHS B
RLP1 LDA SEED1
 LDB #5
 MUL
 PSHS D
 LDA SEED2
 LDB #8
 MUL
 ADDD ,S++
 EXG A,B
 CLRB
 PSHS D
 LDA SEED2
 LDB #5
 MUL
 ADDD ,S++
 ADDD #$3871
 STD SEED1
 CMPA ,S
 BHI RLP1
 TSTA
 BEQ RLP1
 PULS B
 EXG A,B
 CLRA
 RTS

* transfer tile data to RAM
*
* B = dragon index
*
TFRRAM
 LEAX DDATA,PCR
 LDA #144
 DECB
 MUL
 LEAX D,X
 LEAY TABLE,PCR
 LDU #TILES
 LDA #144
 STA COUNT
 PSHS A
RDRL
 DEC ,S
 LDA ,S
 CMPA #$FF
 BEQ XRDRL
 LDA ,X+
 STA ,U+  tile id
 LDD ,Y++
 STD ,U++ tile voffset
 LDD ,Y++
 STD ,U++ left, right
 LDD ,Y++
 STD ,U++ up, down
 BRA RDRL
XRDRL
 PULS A,PC

* scramble tiles in dragon
*
SCRAMB
* Pass through tile id's
 LDA #144
 PSHS A
RDRL2
 DEC ,S
 LDA ,S
 CMPA #$FF
 BEQ XRDRL2
* Pick a random place to swap with
 LDB #144
 LBSR RND
 DECB
 LDA #7
 MUL
 LDX #TILES
 TFR X,Y
 LEAX D,X
 LDB ,S
 LDA #7
 MUL
 LEAY D,Y
* Do the swap
 LDA ,X
 LDB ,Y
 STA ,Y
 STB ,X
 BRA RDRL2
XRDRL2
 PULS A,PC

*restore dragon
RESTOR
 CLR STUCK
 LDX #TILES
 LDA #144
 STA COUNT
A@
 TST ,X
 BGT B@
 COM ,X
B@
 LEAX 7,X
 DECA
 BNE A@
 RTS

* Generate a dragon
* 
GDRAGN
 LDB #144
 STB COUNT
 CLR STUCK
 LDB DRAGID
 TSTB
 LBNE TFRRAM
*random dragon
 LDB #1
 LBSR TFRRAM
 LBRA SCRAMB

* Put message on screen
* U points to message
* Message terminated by zero byte
* X points to screen location
MSG
 LDB ,U+
 BEQ XMSG
 PSHS U
 LBSR PUT
 PULS U
 BRA MSG
XMSG
 CLR HFLAG
 RTS

CVECT
 FCC " ,*?#'-.0123456789:"
 FCC "@ABCDEFGHIJKLM"
 FCN "NOPQRSTUVWXYZ"

* Put character on screen
* X points to screen
* B has character in it
PUT
 PSHS D,X,Y,U
 CMPB #'a'   lower case?
 BLO PUTUC
 SUBB #'a-'A convert to upper case
PUTUC

* convert char to font pointer
 LEAU FONT,PCR
 LEAY CVECT,PCR
A@
 TST ,Y
 BEQ BAD
 CMPB ,Y+
 BEQ Z@
 LEAU 8,U
 BRA A@
BAD
 LEAU FONT,PCR
Z@
 LDA #8
 PSHS A

PUT0
 DEC ,S
 BLT PUT1
 LDA ,U+
 LBSR CROW
 LEAX 160,X
 BRA PUT0

PUT1
 PULS A

PUT9
 PULS D,X,Y,U
 LEAX 4,X    *** was 3 ***
 RTS

* put character row on screen
* X points to screen
* A is row bits
CROW
 PSHS A
 LDA #$FF   default color is white
 STA CMASK
 TST BORDF  in border?
 BEQ A@
 CLRA       black
 STA CMASK
A@
 TST HFLAG
 BEQ CROWH
 LDA #$DD   highlight color white/grey
 STA CMASK
CROWH
 PULS A
 LDB #$99   background color
 TST BORDF  in border?
 BEQ C@
 LDB #$11   yellow
C@
 TST WINSET in victory dragon?
 BEQ D@
 CLRB       black
D@
 STB ,X
 STB 1,X
 STB 2,X
 STB 3,X
 LDB #$FF
 PSHS A
CROW0
 LDA ,S
 BEQ CROW2
 INCB
 LSLA
 STA ,S
 BCC CROW0
 TFR X,Y
 TFR B,A
 LSRA
 LEAY A,Y
 TFR B,A
 ANDA #1
 BEQ CROW1

*put into right nibble
 LDA ,Y
 ANDA #$F0
 PSHS A
 LDA CMASK
 ANDA #$0F
 ORA ,S+
 STA ,Y
 BRA CROW0
CROW1
* left nibble
 LDA ,Y
 ANDA #$0F
 PSHS A
 LDA CMASK
 ANDA #$F0
 ORA ,S+
 STA ,Y
 BRA CROW0
CROW2
 PULS A,PC

* Button
*
* B = 2 (left) or 1 (right)
* returns 1 in B if button on
*
BUTTON
 LDB #2 ; force left button
 LDA #$7F
 STA $FF02
*assume left for now
 LDU #LSW   LSW
 LDA #2     left mask
 CMPB #1
 BNE BUT0
 LEAU 1,U   RSW
 LDA #1     right mask
BUT0
 PSHS A
 ANDA $FF00 try usual button
 BEQ BON
 LDA ,S     nope
 LSLA       how about second
 LSLA       button on
 ANDA $FF00 deluxe joystick?
 BEQ BON

*button was off
 PULS A
 CLR ,U
 BRA BRETOF

*button was on
BON
 PULS A
 TST ,U     previous state?
 BNE BRETOF

*on, previously off
 INC ,U
 LDB #1
 RTS

BRETOF
 CLRB
 RTS

* convert voffset to x,y
* U -> X:Y
* D = voffset
VXY
 PSHS D,Y
 TFR D,Y
 CLR 2,U
 LSRA
 RORB
VXYL
 SUBD #160
 BLT XXYL
 INC 2,U
 LEAY -320,Y
 BRA VXYL
XXYL
 STY ,U
 PULS D,Y,PC

* Select tile to remove
*
* returns with B = tile pos
* if tile selected, B = 0 if tile not
* selected,
* and U points to entry in tile table
*
SELECT
* forget this
*LBSR CXYV
*LDU #CURSX
*LBSR VXY

*try this instead
 LDA CURSXY
 LDB #5
 MUL
 STD CURSX
 LDA CURSXY+1
 LDB #3
 MUL
 STB CURSY

 LDA #144
 PSHS A
SLL
 DEC ,S
 LDA ,S
 LDB #7
 MUL
 LDX #TILES
 LEAX D,X
 TST ,X     exists?
 BLE XSLL   ** BEQ
 TST 5,X    visible?
 BEQ SLLG

 LDA 5,X    check tile above
 DECA
 LDB #7
 LDU #TILES
 MUL
 LEAU D,U
 TST ,U     exists?
 BGT XSLL   not visible ** BNE

SLLG
 CLRA
 LDB ,S
 INCB
 TFR D,Y    remember tile position
 LDD 1,X    convert voffset
 EXG D,X
 LBSR FUDGE

*adjust for 3D effect
*tile pos at ,S
*X is voffset to adjust
 STD SAVED
 LDA ,S
 CMPA #143
 BLO A@
 LEAX -2*160+1,X
A@
 CMPA #139
 BLO B@
 LEAX -2*160+1,X
B@
 CMPA #123
 BLO C@
 LEAX -2*160+1,X
C@
 CMPA #87
 BLO D@
 LEAX -2*160+1,X
D@
 LDD SAVED

 EXG D,X
 SUBD #SCREEN

 LDU #TILEX
 LBSR VXY

 LDA CURSY  above tile?
 CMPA TILEY
 BLO XSLL

 LDA TILEY  below tile?
 ADDA #23
 CMPA CURSY
 BLO XSLL

 LDD CURSX  to left of tile?
 CMPD TILEX
 BLO XSLL

 LDD TILEX  to right of tile?
 ADDD #20
 CMPD CURSX
 BLO XSLL

 TFR X,U    tile is selected!
 PULS B
 INCB
 RTS
XSLL
 TST ,S
 LBNE SLL
 PULS B
 CLRB
 RTS

CURON
 PSHS D,X,Y,U
 TST CSTAT already on?
 LBNE XARW
 LDA #1
 STA CSTAT
 LBSR GETCP
 PSHS B,X
*suck up memory at cursor
 LDY #CACHE
 LDA #10
 PSHS A
A@
 DEC ,S
 BLT Z@
 LDD ,X++
 STD ,Y++
 LDD ,X++
 STD ,Y++
 LDD ,X++
 STD ,Y++
 LEAX 160-6,X
 BRA A@
Z@
 PULS A
 PULS B,X
*put cursor onto screen
 ANDB #1
 LBEQ EVARW

*odd arrow
 LDA ,X 1st row
 ORA #$0F
 STA ,X
 LDD #$FFFF
 STD 1,X
 STA 3,X
 LEAX 160,X

 LDA ,X 2nd row
 ORA #$0F
 STA ,X
 CLR 1,X
 CLR 2,X
 LDA 3,X
 ORA #$F0
 STA 3,X
 LEAX 160,X

 LDA ,X 3rd row
 ORA #$0F
 STA ,X
 CLR 1,X
 LDA #$0F
 STA 2,X
 LEAX 160,X

 LDA ,X 4th row
 ORA #$0F
 STA ,X
 CLR 1,X
 CLR 2,X
 LDA 3,X
 ORA #$F0
 STA 3,X
 LEAX 160,X

 LDA ,X 5th row
 ORA #$0F
 STA ,X
 LDA #$0F
 STA 1,X
 CLR 2,X
 STA 3,X
 LEAX 160,X

 LDA ,X 6th row
 ORA #$0F
 STA ,X
 LDA 1,X
 ORA #$F0
 STA 1,X
 LDA #$F0
 STA 2,X
 CLR 3,X
 LDA 4,X
 ORA #$F0
 STA 4,X
 LEAX 160,X

 LDA ,X 7th row
 ORA #$0F
 STA ,X
 LDA 2,X
 ORA #$0F
 STA 2,X
 CLR 3,X
 LDA #$0F
 STA 4,X
 LEAX 160,X

 LDA #$F0 8th row
 STA 3,X
 CLR 4,X
 LDA 5,X
 ORA #$F0
 STA 5,X
 LEAX 160,X

 LDA 3,X 9th row
 ORA #$0F
 STA 3,X
 LDA #$0F
 STA 4,X
 LEAX 160,X

 LDA 4,X
 ORA #$F0
 STA 4,X

 LBRA XARW

EVARW

*even arrow
 LDD #$FFFF 1st row
 STD ,X
 STA 2,X
 LDA 3,X
 ORA #$F0
 STA 3,X
 LEAX 160,X

 LDD #$F00F 2nd row
 STA ,X
 CLR 1,X
 STB 2,X
 LEAX 160,X

 STA ,X 3rd row
 CLR 1,X
 LDA 2,X
 ORA #$F0
 STA 2,X
 LEAX 160,X

 LDD #$F00F 4th row
 STA ,X
 CLR 1,X
 STB 2,X
 LEAX 160,X

 STA ,X 5th row
 STA 1,X
 CLR 2,X
 LDA 3,X
 ORA #$F0
 STA 3,X
 LEAX 160,X

 LDD #$FF0F 6th row
 STA ,X
 CLR 2,X
 STB 3,X
 LDA 1,X
 ORA #$0F
 STA 1,X
 LEAX 160,X

 LDA #$F0 7th row
 STA 2,X
 LDA ,X
 ORA #$F0
 STA ,X
 CLR 3,X
 LDA 4,X
 ORA #$F0
 STA 4,X
 LEAX 160,X

 LDA 2,X 8th row
 ORA #$0F
 STA 2,X
 CLR 3,X
 LDA #$0F
 STA 4,X
 LEAX 160,X

 LDA #$F0 9th row
 STA 3,X
 LDA 4,X
 ORA #$F0
 STA 4,X
 LEAX 160,X

 LDA 3,X 10th row
 ORA #$0F
 STA 3,X

XARW
 PULS D,X,Y,U,PC

* 
CUROFF
 PSHS D,X,Y,U
 TST CSTAT already off?
 BEQ X@
 CLR CSTAT
 LBSR GETCP
*put back memory
 LDY #CACHE
 LDA #10
 PSHS A
A@
 DEC ,S
 BLT Z@
 LDD ,Y++
 STD ,X++
 LDD ,Y++
 STD ,X++
 LDD ,Y++
 STD ,X++
 LEAX 160-6,X
 BRA A@
Z@
 PULS A
X@
 PULS D,X,Y,U,PC

*get cursor byte pointer
GETCP
 LDD CURSXY
 PSHS A
 LDX #SCREEN
 LDA #3
 MUL
 LDA #160
 MUL
 LEAX D,X
 LDB ,S
 LDA #5
 MUL
 LSRA
 RORB
 LEAX D,X
*x is now byte pointer
 PULS B,PC


* PRINT NUMBER ROUTINE
* D = NUMBER
* X = voffset
*
PRTNUM PSHS  D,X,Y,U
       LBSR  NMOUT
       PULS  D,X,Y,U,PC

* Display number
*   B = number
*   X = voffset
*
NMOUT
 PSHS B
 LDY #0 zero suppress flag
* FIRST DIGIT
 LDA #'0
 LDB ,S
DIG1A
 SUBB #100
 BCS XDIG1
 STB ,S
 INCA
 BRA DIG1A
XDIG1
 CMPA #'0 zero suppress
 BEQ DIG2
 EXG B,A
 LBSR PUT print 1st digit
 EXG B,A
 LEAY 1,Y
* SECOND DIGIT
DIG2
 LDA #'0
 LDB ,S
DIG2A
 SUBB #10
 BLT XDIG2
 STB ,S
 INCA
 BRA DIG2A
XDIG2
 CMPY #0 previous digit nonzero?
 BNE DIG2B if so, don't suppress
 CMPA #'0 zero suppress
 BEQ DIG3
DIG2B
 EXG B,A
 LBSR PUT print 2nd digit
 EXG B,A
 LEAY 1,Y
* THIRD DIGIT
DIG3
 LDA #'0
 ADDA ,S
 EXG B,A
 LBSR PUT print 3rd digit
 EXG B,A
 LEAY 1,Y
* Y is 3, do nothing
* Y is 2, print space
* Y is 1, print 2 spaces
 TFR Y,D
 CMPB #3
 BEQ XDIGN
 PSHS B
 LDB #' 
 LBSR PUT
 PULS B
 CMPB #1
 BNE XDIGN
 PSHS B
 LDB #' 
 LBSR PUT
 PULS B

XDIGN
 PULS B,PC

* Update tile count display
UCOUNT
 PSHS D,X,Y,U
 LDA #2
 LDB #19
 LBSR CPOS
 LEAX 4*160,X
 LEAU UTMSG,PCR
 LBSR MSG
 LDA #3
 LDB #20
 LBSR CPOS
 LEAX 5*160,X
 LDB COUNT
 CLRA
 LBSR PRTNUM
UCTX
 PULS D,X,Y,U,PC

UTMSG
 FCN "Tiles"

IRQ

* Check for BREAK key
 lda $ff02
 pshs a
 jsr kbcheck
 puls a
 sta $ff02

 CLR $FFDF turn off ROMs
 CLRA
 STA $FF91 set task 0
 INC TICKS
 INC TOCKS

* flash highlight color
 LDA TOCKS
 ANDA #8
 BEQ IRQH0
IRQH1
 LDA $FFBF
 STA $FFBD
 BRA IRQ0
IRQH0
 LDA $FFBE
 STA $FFBD

*update clock
IRQ0
 LDA TICKS
 CMPA #60
 BLT XIRQ

* one second
 CLR TICKS
 DEC SECS
 BGE XIRQ

* one minute
 LDA #59
 STA SECS
 TST MINS
 BEQ A@
 DEC MINS
 BRA XIRQ
A@
 CLR SECS

XIRQ
* take care of message area
 TST MTIMER
 BEQ IRQF
 DEC MTIMER  time to clear it?
 LDA MTIMER
 BNE IRQF
 LBSR CLMSG  clear it
IRQF
 TST ROMSON  does foreground want ROMs
 BEQ XXIRQ   on?  if so, turn em on
 STA $FFDE
XXIRQ
 LDA FF91
 STA $FF91
 LDA $FF02 dismiss interrupt
 RTI

* Display two digits
*   B = number
*   X = voffset
*   Y = zero supress
*         0: don't
*         1: do supress
*
NM2OUT
 PSHS B

* FIRST DIGIT
D2G2
 LDA #'0'
 LDB ,S
D2G2A
 SUBB #10
 BLT X2IG2
 STB ,S
 INCA
 BRA D2G2A
X2IG2
 CMPY #0 wants suppression?
 BEQ D2G2B no
 CMPA #'0
 BEQ D2G3 zero suppress
D2G2B
 EXG B,A
 LBSR PUT print 1st digit
 EXG B,A
* SECOND DIGIT
D2G3
 LDA #'0
 ADDA ,S
 EXG B,A
 LBSR PUT print 2nd digit
 EXG B,A

X2IGN
 PULS B,PC

* Set up time display
*
UUTIME
 PSHS D,X,Y,U
 LDA #2
 LDB #5
 LBSR CPOS
 LEAX -4*160+2,X
 TST TLIMIT
 BEQ Z@
 LEAU TSECS,PCR
 TST TLIMIT
 BGT A@
 LEAU TMINS,PCR
A@
 LBSR MSG    update time heading
 LDA #255
 STA OLDTIM  force time update
 LBSR UTIME  update time value
Z@
 PULS D,X,Y,U,PC

TMINS
 FCN "Mins"
TSECS
 FCN "Secs"

* Update time display
*
UTIME
 PSHS D,X,Y,U
 LDB SECS
 CMPB OLDTIM
 BEQ XUTIME
 STB OLDTIM
 LBSR CUROFF
 LDA #3 column
 LDB #6 row
 LBSR CPOS
 LEAX -3*160+2,X
 LDY #0
 LDB SECS
 TST TLIMIT
 BGE C@
*tournament - minutes
 LDB MINS
 LEAX -6,X
 LBSR NM2OUT
 LDB #':
 LBSR PUT
 LDB SECS
*challenge - seconds
C@
 LBSR NM2OUT
 LBSR CURON
XUTIME
 PULS D,X,Y,U,PC

*put something in the message area
* X -> message line 1
* Y -> message line 2 (0 if none)
*
UMSG
 LDA #240   set timer for message area
 STA MTIMER = 4 seconds
 PSHS Y
 PSHS X

 LBSR CLMSG  clear message area

 LDA #30     message first line
 LDB #5
 LBSR CPOS
 LEAX -160*4,X
 LDU ,S++
 LBSR MSG

 LDA #30     message second line
 LDB #6
 LBSR CPOS
 LEAX -160*4,X
 LDU ,S++
 PSHS U
 PULS D
 BEQ XUMSG   not a second line
 LBSR MSG

XUMSG
 LDA #240
 STA MTIMER
 RTS

* clear message area
CLMSG
 LDA CSTAT
 PSHS A
 BEQ  A@
 LBSR CUROFF
A@
 LDA #30
 LDB #5
 LBSR CPOS
 LEAX -160*4,X
 LBSR CLAREA
 LDA #30
 LDB #6
 LBSR CPOS
 LEAX -160*4,X
 LBSR CLAREA
 PULS A
 TSTA
 BEQ X@
 LBSR CURON
X@
 RTS

* clear one line of message area
* X -> message area line
*
CLAREA
 LDA #8
 PSHS A
 LDD #$9999
CLAL
 DEC ,S
 BLT XCLAL
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 STD ,X++
 LEAX 160-40,X
 BRA CLAL

XCLAL
 PULS A,PC

* check if tile is free
* U -> tile in tile table
*
FREE
 PSHS B
 PSHS U

*check tile existence
 TST ,U
 BLE NFREE

*check above tile
 LDB 5,U
 BEQ C@
 LDA #7
 DECB
 MUL
 LDU #TILES *bad
 LEAU D,U *bad
 TST ,U
 BGT NFREE
C@
*check left tile
 LDU ,S
 LDB 3,U
 BEQ YFREE
 LDA #7
 DECB
 MUL
 LDU #TILES
 LEAU D,U
 TST ,U
 BLE YFREE
*check right tile
 LDU ,S
 LDB 4,U
 BEQ YFREE
 LDA #7
 DECB
 MUL
 LDU #TILES
 LEAU D,U
 TST ,U
 BLE YFREE

NFREE
*not free
 PULS U
 PULS B
 LDA #1
 TSTA
 RTS

YFREE
*yes free
 PULS U
 PULS B
 CLRA
 TSTA
 RTS

* get tile mark color
* B is tile id
GCOLOR
 PSHS X,Y,U,A
 PSHS B
 LEAX COTBL,PCR
 CMPB #FLO+4 bamboo flower
 BEQ FLOBAM
 CMPB #DRA+2 red dragon
 BEQ RDDRA
 CMPB #DRA+3 green dragon
 BEQ GRDRA
 CMPB #BAM+1 one bam
 BEQ BRDRA
 ANDB #$F0
 CMPB #SEA
 BEQ SEASON
 LSRB
 LSRB
 LSRB
 LSRB
 DECB
 LDA #4
 MUL
 LEAX D,X
GCCONT
 STX TCOLP
 LDA ,X
 STA TCOLC
 LDA 1,X
 STA TCOLOR

XGCOLR
 PULS B
 PULS A,X,Y,U,PC

* exceptions for seasons
SEASON
 LDB ,S
 ANDB #$0F
 DECB
 LDA #4
 MUL
 LEAX SEACL,PCR
 LEAX D,X
 BRA GCCONT

* colors for seasons
SEACL
*spring
 FCB 13
 FCB $66 blue
 FCB 30
 FCB 0   black
*summer
 FCB 13
 FCB $88 orange
 FCB 30
 FCB 0   black
*autumn
 FCB 13
 FCB $33 tan
 FCB 30
 FCB 0   black
*winter
 FCB 13
 FCB 0   black
 FCB 30
 FCB 0   black

BRDRA
 LEAX ONEBAM,PCR
 BRA GCCONT
RDDRA
 LEAX -2,X
 BRA GCCONT
GRDRA
 LEAX -4,X
 BRA GCCONT
FLOBAM
 LEAX FLBAM,PCR
 BRA GCCONT

FLBAM
 FCB 13
 FCB $44 green
 FCB 30
 FCB 0   black

ONEBAM
 FCB 14
 FCB $55 red
 FCB 30
 FCB $44 green

*green dragon
 FCB 30
 FCB $44 green

*red dragon
 FCB 30
 FCB $55 dark red

COTBL
*dragons
 FCB 30
 FCB 0 black
 FCB 0
 FCB 0
*winds
 FCB 30
 FCB $55 red
 FCB 0
 FCB 0
*seasons
 FCB 13
 FCB $44 green
 FCB 30
 FCB 0   black
*flowers
 FCB 13
 FCB $66 blue
 FCB 30
 FCB 0   black
*dots
 FCB 30
 FCB $22 purple
 FCB 0
 FCB 0
*craks
 FCB 5
 FCB $66 blue
 FCB 30
 FCB 0   black
*bams
 FCB 30
 FCB $33 brown
 FCB 0
 FCB 0

* get next tile mark color
NCOLOR
 PSHS D,X,Y,U
 DEC TCOLC
 BGT XNCOLR
 LDX TCOLP
 LEAX 2,X
 STX TCOLP
 LDA ,X
 STA TCOLC
 LDA 1,X
 STA TCOLOR
XNCOLR
 PULS D,X,Y,U,PC

* "Chime" sound for tournament, etc.
* Sounds just like the chime in Coco
* Max and Stellar Lifeline, but its
* A Rick Adams original!

CHIME
 PSHS D
 LDA $FF23
 PSHS A
 ORA #8
 STA $FF23
 LDA $FF01
 PSHS A
 ANDA #$F7
 STA $FF01
 LDA $FF03
 PSHS A
 ANDA #$F7
 STA $FF03

 CLRB
CHIS
 LEAX SINTBL,PCR
 LDA #32
 PSHS A
CHI0
 DEC ,S
 BLT XCHI0
 LDA ,X+
 PSHS B
 MUL
 LSLA
 LSLA
 ANDA #$FC
 ORA #2
 STA $FF20
 PULS B
 BRA CHI0
XCHI0
 PULS A
 DECB
 BNE CHIS

 PULS A
 STA $FF03
 PULS A
 STA $FF01
 PULS A
 STA $FF23
 PULS D,PC

* Sine table for chime

SINTBL
 FCB $20,$26,$2C,$31,$36,$3A,$3D,$3F
 FCB $3F,$3F,$3D,$3A,$36,$31,$2C,$26
 FCB $20,$19,$13,$0E,$09,$05,$02,$00
 FCB $00,$00,$02,$05,$09,$0E,$13,$19

* Initialize memory management unit
*
MINIT
 LDX #$FFA0
 LDY #$FFA8
 LEAU MTBL,PCR
 LDA #8
 PSHS A
MINI0
 DEC ,S
 BLT XMINI
 LDD ,U++
 STA ,X+
 STB ,Y+
 BRA MINI0
XMINI
 PULS A,PC

MTBL
 FCB $38,$38
 FCB $39,$39
 FCB $3A,$3A
 FCB $3B,$3B
 FCB $30,$3C
 FCB $31,$3D
 FCB $32,$3E
 FCB $33,$3F

**** Victory Dragon
VICTOR
 CLR WON
 TST COUNT
 BNE XVIC * Comment this out and any tile match wins the game
 INC WON

*okay, somebody done won it!

*show current state
 LBSR UCOUNT
 LDA TSCORE
 PSHS A
 INC TSCORE
 LBSR UTSCOR
 LBSR CUROFF
 LBSR CHIME
 LBSR DELAY

*display congratulations
 INC WINSET
 LEAU DCOLOR,PCR
 TST MONTYP
 BNE A@
 LEAU DCOLOC,PCR
A@
 LBSR CLRSET
 CLRA
 STA $FF9A border
 LBSR CLS

 LEAU SDATA,PCR display dragon head
 LBSR DRIVER

 * LDD #$050E
 LDD #$0517 position of message
 LBSR CPOS
 LEAU VTMP,PCR
 LBSR MSG

 LBSR ROAR
 LBSR ROAR * DEBUG

 CLR WINSET
 LBSR CLS
 LBSR CURON
 PULS A
 STA TSCORE

*restore colorset
 LEAU RGBSET,PCR
 LDA MONTYP
 CMPA #1
 BEQ B@
 BHI A@
 LEAU CMPSET,PCR
 BRA B@
A@
 LEAU ZAPSET,PCR
B@
 LBSR CLRSET

XVIC
 RTS

VTMP
 FCN "You have conquered the dragon"

* A nice long delay
DELAY
 LDX #0
A@
 MUL
 MUL
 MUL
 LEAX -1,X
 BNE A@
 RTS

ROAR
 LBSR SNDON
 CLRA
 PSHS A
A@
 LBSR CCYC
 DEC ,S
 BEQ X@
 CLRB
 PSHS B
B@
 DEC ,S
 BEQ Q@
 LEAU MAIN,PCR
 LDA ,S
 BNE R@
 INCA
R@
 LDA A,U
 LDB 1,S
 BNE S@
 INCB
S@
 LDB B,U
 MUL
 ANDA #$F
 LDB D,U
 ANDB #$FC
 ORB #2
 STB $FF20
 BRA B@
Q@
 PULS A
 BRA A@
X@
 PULS A
SOFF
 LDA $FF23
 ANDA #$F7
 STA $FF23
 RTS

DOIT
 LDA ,-X
 ANDA #$3F
 RTS

*color cycling
CCYC
 LBSR VSYNC
 LBSR VSYNC * DEBUG
 LDX #$FFB8
 LBSR DOIT
 PSHS A
 LBSR DOIT
 PSHS A
 LBSR DOIT
 PSHS A
 LBSR DOIT
 PSHS A
 LBSR DOIT
 PSHS A
 LDA $FFB2
 ANDA #$3F
 STA $FFB7
 PULS A
 STA $FFB2
 PULS A
 STA $FFB3
 PULS A
 STA $FFB4
 PULS A
 STA $FFB5
 PULS A
 STA $FFB6
 RTS

* Challenge match scoreboard
CHBORD
 LBSR CLS
 LBSR BORDER

 LDA #7     "Challenge match results"
 LDB #6
 LBSR CPOS
 LEAU CHRES,PCR
 LBSR MSG

 LDA #12     "Player 1"
 LDB #8
 LBSR CPOS
 LEAU PLAYR1,PCR
 LBSR MSG

 LDA #26    Player 1 score
 LDB #8
 LBSR CPOS
 LDB SCORES
 LBSR PRTNUM

 LDA #12     "Player 2"
 LDB #10
 LBSR CPOS
 LEAU PLAYR2,PCR
 LBSR MSG

 LDA #26    Player 2 score
 LDB #10
 LBSR CPOS
 LDB SCORES+1
 LBSR PRTNUM

 LDA TMOUT
 CMPA #4
 BNE A@
 LDD #$060D     "Too many turns"
 LBSR CPOS
 LEAU TIMOUT,PCR
 LBSR MSG
A@

 LDA #9     "This match is ended"
 LDB #19
 LBSR CPOS
 LEAU ENDED,PCR
 LBSR MSG

 LDA #8     "Press any key..."
 LDB #21
 LBSR CPOS
 LEAU PRESS,PCR
 LBSR MSG

*wait for key here
 BRA KWAIT

CHRES
 FCN "Challenge match results:"
PRESS
 FCN "Press any key to exit"
TIMOUT
 FCN "Too many turns have passed"
ENDED
 FCN "This match is ended"

KWAIT
A@
 LBSR KCHEK  wait for no key
 BNE A@
B@
 LBSR KCHEK  wait for key
 BEQ B@
 RTS

* check for key pressed
KCHEK
 CLR $FF02
 LDA $FF00
 ANDA #$7F
 CMPA #$7F
 RTS

* Refresh game screen state
*
*  U -> tile table entry
*  B = tile position 1-144
*
REFRES
 PSHS D,X,Y
 CMPB #144 sneaky trick for tile 144
 BNE C@
 LDB #141
 LDU #140*7+TILES
C@
 PSHS U
 STB TLPOS
 LBSR CUROFF
 CLR MTIMER
 LBSR CLMSG
 LBSR TASK1 alter inactive screen
 LBSR CLSX

* redraw to the right
 LDU ,S
 LDA 4,U right
 BEQ N@
* based on tile to right
 LDB #7
 DECA
 MUL
 LDU #TILES
 LEAU D,U
 LDU 1,U voffset
 LEAU -RO,U
 BRA C@
N@
* no tile to immediate right
 LDU 1,U voffset
 LEAU -RO+CO,U
C@
 LBSR PILE3

* redraw column at active tile
 LDU ,S
 LDU 1,U
 LEAU -RO,U
 LBSR PILE3

* redraw to left
 LDU ,S
 LDA 3,U
 BEQ N@
* based on tile to left
 DECA
 LDU #TILES
 LDB #7
 MUL
 LEAU D,U
 LDU 1,U
 LEAU -RO,U
 BRA C@
* no tile to left
N@
 LDU 1,U
 LEAU -RO-CO,U
C@
 LBSR PILE3

* do tile 144 just in case
 LBSR DO144

* transfer region to active screen
 LDX ,S
 LDX 1,X voffset
 LDB TLPOS
 CMPB #12
 BLS X@
 LEAX -HFROW,X
X@
 LEAX -HFCOL,X
 TFR X,D
 LSRA
 RORB
 TFR D,X
 LBSR FUDGE
*now x points to UL corner of block
*20 bytes wide, 48 rows high
 LDA #36 assume tile 1-12 or 76-87
 LDB TLPOS
 CMPB #12 tile 1-12?
 BLS Q@ yes
* tile 13-144
 CMPB #75
 BLS R@ 13-75
* tile 76-144
 CMPB #87
 BLS Q@ ***was BLO***
R@
 LDA #48 not 1-12, 76-87
Q@
 PSHS A
A@
 DEC ,S
 BLT Z@
 TFR X,Y
 LBSR ONEROW
C@
 LEAX 160,X next row
 BRA A@
Z@
 PULS A
 CLRA
 CLRB
 LBSR TASK0 change to active screen
 LBSR CURON
 PULS U

 LBSR UCOUNT
 TST TLIMIT
 BEQ A@
 LBSR UTSCOR
 LBSR UUTIME
A@
 PULS D,X,Y,PC

PILE3
 PSHS U
 BSR VPILE
 LEAU RO,U
 BSR VPILE
 LEAU RO,U
 BSR VPILE
 PULS U,PC

* draw pile based on tile table pointer
*
* U -> tile table entry
*
TPILE
 PSHS D,X,Y,U
 BRA F@
*
* draw pile based on voffset
*
* U = voffset
*
VPILE
 PSHS D,X,Y,U
 TFR U,X
* look for base tile
 LDU #TILES
 LDA #87
A@
 CMPX 1,U
 BEQ F@
 LEAU 7,U
 DECA
 BNE A@
 PULS D,X,Y,U,PC no such base
* found base tile
* U points to it
F@
 LDX 1,U voffset of base tile
 CLR FACE id of top tile
* draw base and upper tiles
L@
 TST ,U tile exists?
 BLE N@ no
 LDB ,U exists
 STB FACE remember tile id
 STX FACE+1 and voffset
 STU FACE+3 and tile table pointer
 PSHS U
 LBSR EDGE do the edge
 PULS U
 LDA 5,U tile above it
 BEQ N@ isnt one
 CMPA #144 tile 144?
 BEQ N@ forget it
 DECA
 LDB #7
 MUL
 LDU #TILES
 LEAU D,U link to tile above
 LEAX -2*320+2,X voffset to next level
 BRA L@
* found the top of the pile
N@
 LDB FACE need to draw face?
 BEQ Z@ no
 LDX FACE+1 voffset
 LDU FACE+3 tile table pointer
 CMPU STILE1
 BEQ H@
 CMPU STILE2
 BNE W@
H@
 LEAU BLANKH,PCR highlight face tile
 BRA T@
W@
 LEAU BLANK,PCR de-highlighted tile
T@
 LBSR TILE draw blank tile
 LDX FACE+1
 LDU FACE+3
 LBSR SHADOW
 LDX FACE+1
 LDB FACE
 LBSR MKTILE mark tile
Z@
 PULS D,X,Y,U,PC

ONEROW
 PSHS X
 LDA TLPOS
 CMPA #31
 BNE A@
 LEAY 4,Y
 BRA B@ 
A@
 CMPA #45
 BEQ B@
* Copy 20 bytes
 LDU ,Y
 LDD 2,Y
 LBSR TASK0
 STU ,Y++
 STD ,Y++
 LBSR TASK1
* Copy 16 bytes
B@
 LDU ,Y
 LDD 2,Y
 LDX 4,Y
 LBSR TASK0
 STU ,Y++
 STD ,Y++
 STX ,Y++
 LBSR TASK1
 LDU ,Y
 LDD 2,Y
 LDX 4,Y
 LBSR TASK0
 STU ,Y++
 STD ,Y++
 STX ,Y++
 LBSR TASK1
 LDU ,Y
 LDD 2,Y
 LBSR TASK0
 STU ,Y++
 STD ,Y++
 LBSR TASK1
 PULS X,PC

* add 3D yellow edge highlighting
* at left and bottom of tile
*
* X = pixel offset
* B = tile id
*
EDGE
 PSHS B,X
 TFR X,D
 ANDB #1
 BEQ EVEDGE

*odd byte boundary
 TFR X,D
 LSRA
 RORB
 TFR D,X
 LBSR FUDGE
*detail at upper left corner
 LEAX -1,X
 LEAX 160,X
 LDA #$BA
 STA 1,X
 LEAX 160,X
 LDA ,X
 ANDA #$F0
 ORA #$0B
 STA ,X
 LDA #$AA
 STA 1,X
 LEAX 160,X
*vertical highlight
 LDA #23
 PSHS A
L@
 DEC ,S
 BLT Z@
 LDA 1,X
 ANDA #$0F
 ORA #$A0
 STA 1,X
 LDA ,X
 ANDA #$F0
 ORA #$0A
 STA ,X
 LEAX 160,X
 BRA L@
Z@
 PULS A

*horizontal highlight
 LEAX -2*160,X
 LEAX 1,X
 LDA #10
 LDB #$AA
A@
 DECA
 BLT Z@
 STB 160,X
 STB ,X+
 BRA A@
Z@
 
*detail at lower right corner
 LDA #$AB
 STA ,X
 LEAX 160,X
 LDA ,X
 ANDA #$0F
 ORA #$B0
 STA ,X
 BRA XEDGE

*even byte boundary
EVEDGE
 TFR X,D
 LSRA
 RORB
 TFR D,X
 LBSR FUDGE
 LDA #$AA yellow
*detail at upper left corner
 LEAX -1,X
 LEAX 160,X
 LDA ,X
 ANDA #$F0
 ORA #$0B
 STA ,X
 LEAX 160,X
 LDA #$BA
 STA ,X
*vertical highlight
 LEAX 160,X
 LDA #$AA
 LDB #23
L@
 DECB
 BLT Z@
 STA ,X
 LEAX 160,X
 BRA L@
Z@

*horizontal highlight
 LEAX -2*160,X
 LDA #$AA
 LDB #10
L@
 DECB
 BLT Z@
 STA 160,X
 STA ,X+
 BRA L@
Z@

*detail at lower right corner
 LDA #$AB
 STA ,X
 LEAX 160,X
 LDA ,X
 ANDA #$0F
 ORA #$B0
 STA ,X

XEDGE
 PULS B,X,PC

CLTILE
 CLR STILE1
 CLR STILE1+1
 CLR STILE1+2
 CLR STILE2
 CLR STILE2+1
 CLR STILE2+2
 RTS

DO144
 PSHS D,X,Y,U
 LDU #TILES
 LEAU 143*7,U
 LDB ,U
 BLE XDO144
 PSHS U

 LDX 1,U
 LEAX -2*320+2,X
 LEAX -2*320+2,X
 LEAX -2*320+2,X
 LEAX -2*320+2,X
*
 PSHS X
 LBSR EDGE
 LDU 2,S
 LBSR SHADOW
 LDU 2,S
*
 CMPU STILE1
 BEQ H@
 CMPU STILE2
 BEQ H@
 LEAU BLANK,PCR
 BRA C@
H@
 LEAU BLANKH,PCR
C@
 LBSR TILE

 PULS X
 LDU ,S
 LDB ,U
 LBSR MKTILE

 PULS U
XDO144
 PULS D,X,Y,U,PC

*check to see if tiles match
*
* U -> tile table entry
* Y -> other tile table entry
*
MATCH
 LDA ,U
 CMPA ,Y
 BEQ Y@
*check seasons/flowers match exception
 ANDA #$F0
 CMPA #$30
 BEQ SEACK
 CMPA #$40
 BNE N@
*check flower
 LDA ,Y
 ANDA #$F0
 CMPA #$40 other is flower?
 BEQ Y@
 BRA N@
*check season
SEACK
 LDA ,Y
 ANDA #$F0
 CMPA #$30 other is season?
 BNE N@
*tiles match
Y@
 CLRA
 TSTA
 RTS
N@
 LDA #1
 TSTA
 RTS

VSYNC
 SYNC
 RTS

; TST $FF02
;A@
; TST $FF03
; BGE A@
; RTS

* Draw shadow!!
*
* X = pixel offset
* U -> tile table entry
*
SHADOW
 PSHS X
 PSHS U
 LDA 4,U tile to right
 BEQ YSHAD never existed?
 DECA
 LDU #TILES
 LDB #7
 MUL
 LEAU D,U
 LDA ,U
 BGT XSHAD exists?

* need shadow
YSHAD
 LDU ,S
 LDD 2,S
 LSRA
 RORB
 TFR D,X
 LBSR FUDGE
 LDD 2,S
 ANDB #1
 BEQ EVSHAD

*odd byte shadow
 LEAX 11,X
 BSR SHADLN
 LDA #22
 PSHS A
A@
 DEC ,S
 BLT B@
 LEAX 160,X
 BSR SHADLN
 BSR SHADRN
 BRA A@
B@
 PULS B
 LEAX 160,X
 LBSR SHADLN
 BRA XSHAD

*even byte shadow
EVSHAD
 LEAX 10,X
 BSR SHADRN
 LDA #22
 PSHS A
A@
 DEC ,S
 BLT B@
 LEAX 160,X
 BSR SHADRN
 LEAX 1,X
 BSR SHADLN
 LEAX -1,X
 BRA A@
B@
 PULS B
 LEAX 160,X
 BSR SHADRN
 
XSHAD
 PULS U
 PULS X,PC

*shadow left nibble
*
* X -> byte
*
SHADLN
 PSHS U
 LDB ,X
 TFR B,A
 ANDA #$0F 
 ANDB #$F0
 LSRB
 LSRB
 LSRB
 LSRB
 LEAU DARKER,PCR
 LDB B,U
 LSLB
 LSLB
 LSLB
 LSLB
 PSHS A
 ORB ,S+
 STB ,X
 PULS U,PC

*shadow right nibble
*
* X -> byte
*
SHADRN
 PSHS U
 LDB ,X
 TFR B,A
 ANDA #$F0
 ANDB #$0F
 LEAU DARKER,PCR
 LDB B,U
 PSHS A
 ORB ,S+
 STB ,X
 PULS U,PC

DARKER
 FCB $0 0:black > black
 FCB $1 1:yellow > yellow
 FCB $2 2:dark purple > dark purple
 FCB $3 3:pumpkin orange > pumpkin orange
 FCB $4 4:dark green > dark green
 FCB $5 5:dark red > dark red
 FCB $6 6:blue > blue
 FCB $7 7:dark blue > dark blue
 FCB $8 8:light orange > light orange
 FCB $9 9:background 
 FCB $E A:white > grey
 FCB $B B:grey > grey
 FCB $E C:white > grey
 FCB $D D:flash
 FCB $0 E:grey > black
 FCB $E F:white > grey

* Error "ping" sound
*
* Sound routine donated by
* Don Hutchison

PING
 BSR  SNDON GET SOUND FROM 6 BIT DAC
 PSHS CC    SAVE IRQ FLAGS
 ORCC #$50  TURN OFF IRQS
 LDA #230   HOW LONG TO DO SOUND
A@
 BSR  B@    DO A TIME DELAY
*
 TFR  A,B   GET TIME COUNT
 ANDB #$F7  USE ONLY THE TOP 5 BITS
 ORB  #2    SET PRINTER BIT HIGH
 STB  $FF20 SEND IT OUT THE DAC PORT
*
 BSR  B@    DO A TIME DELAY
 LDB  #2    CLEAR ALL BITS BUT PRINTER
 STB  $FF20 ON DAC PORT
 DECA       MAKE BELL SOUND SMALLER
 DECA       BY 2
 CMPA #18   IS BELL DONE?
 BHS  A@    NO, THEN LOOP
 PULS CC    TURN ON IRQS
*
B@
 LDB #180   TIME DELAY USED BY PING
C@
 DECB
 BNE C@
 RTS

* Tile select "click" sound
*
* Modified from a routine donated by
* Don Hutchison
*
CLIK
 PSHS D,X
 LEAX MAIN,PCR
 LDA $FF20
 ANDA #3
 ORA #2
 STA $FF20
 BSR SNDON   TURN SOUND ON TO DAC
 LDA  #10     START TIME DELAY SHORT
A@
 TFR  A,B     DO A DELAY (USE COUNT)
B@
 DECB         GET LONGER EACH TIME
 BNE  B@
 LDB  ,X+     GET next value
 ORB #2
 STB  $FF20   SAVE SET PORT
 INCA         MAKE DELAY LONGER
 CMPA #76     ALL DONE?
 BLO  A@      NO, LOOP BACK

SNDOFF
 LBSR SOFF
 CLRB        MAKE RETURN ZERO
 PULS D,X,PC

SNDON
 LDA  $FF23  TURN ON THE SOUND BY
 ORA  #8     SETTING THE SOUND ON BIT
 STA  $FF23
 LDA  $FF01  GET LSB OF JOY/AUDIO
 ANDA #$FF-8 PORT AND RESET IT
 STA  $FF01  AND PUT IT BACK
 LDA  $FF03  GET MSB OF JOY/AUDIO
 ANDA #$FF-8 PORT AND RESET IT TOO
 STA  $FF03  AND PUT IT BACK
 RTS         NOW EXIT

TASK0
 PSHS A
 CLRA
 BRA A@
TASK1
 PSHS A
 LDA #1
A@
 STA FF91
 STA $FF91
 PULS A,PC

 include driver.asm
 include table.asm
 include dragons.asm
 include font.asm
 include tiles.asm
 include menus.asm
 include tourney.asm
 include lettring.asm

*RGB dragon colorset
DCOLOR
 FCB 00 *  0 background
 FCB 00 *  1 UNUSED
 FCB 36 *  2 flame CYCLES
 FCB 54 *  3 flame CYCLES
 FCB 52 *  4 flame CYCLES
 FCB 38 *  5 flame CYCLES
 FCB 32 *  6 flame CYCLES
 FCB 32 *  7 flame CYCLES
 FCB 00 *  8 **UNUSED**
 FCB 52 *  9 eye highlight
 FCB 36 * 10 main body
 FCB 00 * 11 **UNUSED**
 FCB 04 * 12 body edges/feathering
 FCB 00 * 13 **UNUSED** FLASHES!
 FCB 32	* 14 main body shading
 FCB 63 * 15 text

*Composite dragon colorset
DCOLOC
 FCB $00 *  0 background
 FCB $00 *  1 **UNUSED**
 FCB $16 *  2 flame CYCLES
 FCB $34 *  3 flame CYCLES
 FCB $25 *  4 flame CYCLES
 FCB $26 *  5 flame CYCLES
 FCB $16 *  6 flame CYCLES
 FCB $16 *  7 flame CYCLES
 FCB $00 *  8 **UNUSED**
 FCB $25 *  9 eye highlight
 FCB $07 * 10 main body
 FCB $00 * 11 **UNUSED**
 FCB $04 * $05 * 12 body edges/feathering
 FCB $16 * 13 **UNUSED** FLASHES!
 FCB $06 * 14 main body shading
 FCB $30 * 15 text

* HARD RESET TO RSDOS ON BREAK
kbcheck
	ldd #$00fb	; BREAK
	stb $ff02	; PIA0.DB
	ldb $ff00	; PIA0.DA
	andb #$7f
	cmpb #$3f
	bne LDFD0
	sta $ff22	; PIA1.DB
	tsta
	bne LDFD0

	* hard boot to RSDOS
	orcc #$50       ; turn off interrupts
	ldd  #$8c00
	tfr b,dp        ; reset direct page
	std $ff90       ; turn off MMU and task 0
	stb $ffd8       ; slow CPU
	stb $ffd6
	stb $ffde       ; turn on ROMs
	stb $0071
	jmp [$fffe]

LDFD0	rts

SDATA
 include victory.asm
 FDB $FFFF

ZPROG

 END START
