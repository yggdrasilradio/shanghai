
* Tourney
*
* Tournament routines
*
* Programmed by Rick Adams
*
* (c) Copyright 1987 by Activision
*


*get name from keyboard
* X -> screen position
GETNAM
I@
 LBSR KCHEK
 BNE I@
 LDA #20
 CLRB
 LDY #NAME
 STY NAMPTR
L@
 STB ,Y+
 DECA
 BNE L@
 LDD #NAME
 CLR NAMCNT
 LDA #3
 LDB #19
 LBSR CPOS
 LEAU PROMPT,PCR
 LBSR MSG
 LDA #8
 LDB #20
 LBSR CPOS
 LEAX 2*160,X
 LDB #'@'
 INC HFLAG
 LBSR PUT
 CLR HFLAG
 LEAX -4,X
A@
 LBSR INKEY
 CMPB #'#   don't allow weave
 BEQ A@
 CMPB #'@   don't allow cursor
 BEQ A@
 CMPB #'*   don't allow copyright
 BEQ A@
 CMPB #$0D
 BEQ Z@
 CMPB #8
 BNE B@
* backspace
 TST NAMCNT
 BEQ A@
 DEC NAMCNT
 LDD NAMPTR
 SUBD #1
 STD NAMPTR
 LDB #' '    space
 LBSR PUT
 LEAX -8,X   2 backspaces
 LDB #'@' 
 INC HFLAG
 LBSR PUT    cursor
 CLR HFLAG
 LEAX -4,X   1 backspace
 BRA A@
* Normal character
B@
 LDA NAMCNT
 CMPA #19
 BHS A@
 INC NAMCNT
 LDY NAMPTR
 STB ,Y+
 STY NAMPTR
 LBSR PUT
 INC HFLAG
 LDB #'@'
 LBSR PUT
 CLR HFLAG
 LEAX -4,X
 BRA A@
Z@
 TST NAMCNT
 BNE EGN
 LDB #'-'
 STB NAME
 INC NAMCNT
EGN
 RTS

PROMPT
 FCC "Type your name, then"
 FCN " press enter:"

* POLL KEYBOARD, WAIT FOR KEY
* B = ASCII CHARACTER
*
INKEY
 INC ROMSON
 LBSR TASK1
 STA $FFDE
A@
 JSR [$A000]
 BEQ A@
 TFR A,B
 LBSR TASK0
 CLR ROMSON
 STA $FFDF
 RTS

* clear scoreboard
CLBORD
 PSHS D,X
 LDA #24*10+1
 LDX #SCBORD
 CLRB
A@
 DECA
 BEQ B@
 STB ,X+
 BRA A@
B@
 PULS D,X,PC

*update tournament score display
UTSCOR
 PSHS D,X,Y,U
 TST TLIMIT
 BEQ Z@
 LDA #30
 LDB #19
 LBSR CPOS
 LEAX 160*4,X
 LEAU TSMSG,PCR
 LBSR MSG
 LDA #31
 LDB #20
 LBSR CPOS
 LEAX 160*5,X
 LDB TSCORE
 CLRA
 LBSR PRTNUM
Z@
 PULS D,X,Y,U,PC

TSMSG
 FCN "Score"

* Put up tournament scoreboard
*
PTBORD
 LBSR CLS
 LDD #$0903
 LBSR CPOS
 LEAU SCHD1,PCR "Tournament Scoreboard"
 LBSR MSG
* put up names and scores
 LDU #SCBORD
 LDA #10
 PSHS A
A@
 DEC ,S
 BLT Z@
 TST ,U
 BEQ B@
* put up name and score
 LDA #4
 LDB #9
 SUBB ,S
 ADDB #6
 ADDA #2
 LBSR CPOS9
 PSHS U
 LBSR MSG    name
 LDA #4+26
 LDB #9
 SUBB 2,S
 ADDB #6
 ADDA #2
 LBSR CPOS9
 LDU ,S
 LDB 20,U
 LBSR PRTNUM score
 PULS U
 LEAU 24,U
 BRA A@
* null scoreboard entry
B@
 LDA #4
 LDB #9
 SUBB ,S
 ADDB #6
 ADDA #2
 LBSR CPOS9
 PSHS U
 LEAU DASH,PCR
 LBSR MSG
 LDA #4+26
 LDB #9
 SUBB 2,S
 ADDB #6
 ADDA #2
 LBSR CPOS9
 LEAU DASH,PCR
 LBSR MSG
 PULS U
 LEAU 24,U
 BRA A@
Z@
 PULS A
* do "continue tournament" menu
 LDA #4
 LDB #22
 LBSR CPOS
 LEAU SCHD2,PCR
 LBSR MSG "Continue tournament?"
 LEAU SCMENU,PCR
 LBRA TMENU

*yes
SC1
 LBSR CUROFF
 LDU CURMNU
 LBSR DMENU
 LBSR GETNAM
 LBSR CURON
 LDA #1
 TSTA
 RTS
*no
SC2
 CLRA
 TSTA
 RTS

DASH
 FCN "-"
SCHD1
 FCN "Tournament Scoreboard"
SCHD2
 FCN "Continue tournament?"

* Post tournament score to scoreboard
POST
 LDU #SCBORD-24
 LDA #10
 PSHS A
A@ DEC ,S
 BLT Z@
 LEAU 24,U
 LDA TSCORE
 CMPA 20,U
 BLO A@
 BNE B@
 CMPA #144
 BNE B@
*tie breaker
 LDA MINS
 CMPA 21,U
 BLO B@
 LDA SECS
 CMPA 22,U
 BLO B@
 LDA TICKS
 CMPA 23,U
 BHI A@
B@
 LDA ,S
 LBSR INS
 LBSR PUTNAM
Z@
 PULS A,PC

* insert line in scoreboard
INS
 PSHS U,A
 LDX #SCBORD+8*24
 LDY #SCBORD+9*24
*for each line
 PSHS A
A@
 DEC ,S
 BLT Z@
*for each character
 LDA #24
 PSHS X,Y
B@
 LDB ,X+
 STB ,Y+
 DECA
 BNE B@
 PULS X,Y
 LEAX -24,X
 LEAY -24,Y
 BRA A@
Z@
 PULS A
 PULS U,A,PC

* Put player into scoreboard
PUTNAM
 PSHS U
 LDX #NAME
 LDA NAMCNT
 CLR A,X
A@
 LDA ,X+
 STA ,U+
 BNE A@
 PULS U
 LDA TSCORE
 STA 20,U
 LDA MINS
 STA 21,U
 LDA SECS
 STA 22,U
 LDA TICKS
 STA 23,U
 RTS
