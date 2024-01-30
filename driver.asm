* uncompress driver
*
* U -> compressed data
*

DRIVER
T@
 * first two bytes of token are address
 LDX ,U++
 CMPX #$FFFF
 BEQ X@
 * third byte of token is count
 LDA ,U+
 PSHS A
L@
 LDD ,U++
 STD ,X++
 DEC ,S
 BNE L@
 LEAS 1,S
 BRA T@
X@
 RTS

