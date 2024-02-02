* uncompress driver
*
* U -> compressed data
*

DRIVER
T@
 LDX ,U++	* screen address for row
 CMPX #$FFFF	* end of compressed data?
 BEQ X@
L@
 LDB ,U+	* first byte
 CMPB #$FF	* end of row?
 BEQ T@
 TSTB		* one or two byte token?
 BLT BYTE2
BYTE1		* one byte token
 BSR CVERT	* convert token to data
 STB ,X+	* write to screen
 BRA L@
BYTE2		* two byte token
 ANDB #$7F	* strip off sign bit
 BSR CVERT	* convert token to data
 LDA ,U+	* get run count
R@
 STB ,X+	* write to screen
 DECA		* end of run?
 BNE R@
 BRA L@		* get next token in this row
X@
 RTS

* convert token to value
*
* B is token/value
*
CVERT
 PSHS A
 LEAY DTBL,PCR
 CLRA
 LDB D,Y
 PULS A,PC

DTBL
 FCB 000,002,003,004,005,006,007,010,012,014
 FCB 032,034,035,036,037,038,039,042,044,046
 FCB 048,050,051,052,053,054,055,062,064,066
 FCB 067,068,069,070,071,074,078,080,082,083
 FCB 084,085,086,087,090,094,096,098,099,100
 FCB 101,102,103,106,110,112,114,115,116,117
 FCB 118,119,122,124,126,149,160,162,165,166
 FCB 170,172,174,192,197,198,199,202,204,206
 FCB 224,226,227,228,229,230,231,234,236,238
