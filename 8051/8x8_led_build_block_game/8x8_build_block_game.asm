ORG 00H 

UP BIT P1.0
RIGHT BIT P1.1
DOWN BIT P1.2
LEFT BIT P1.3
BUILD BIT P1.7
RS BIT P1.4
MASTER_SW BIT P1.5
EN BIT P1.6
	
CURSOR_X EQU 21H ;CURSOR LOCATION
CURSOR_Y EQU 51H

SETB P1.0
SETB P1.1
SETB P1.2
SETB P1.3
SETB P1.7 ;BUTTONS

CLR P1.4
SETB P1.5
CLR P1.6 ;LCD CONFIG 
MOV P2,#00H
MOV P3,#00H
MOV P0,#00H;CONFIG 

MOV P3,#0FEH ;INIT 
MOV CURSOR_X,#80H
MOV R1,#CURSOR_Y

ACALL LCD_INIT

MSW:JB MASTER_SW,BUILD_MODE
ACALL GENERATE_HEX
JNB MASTER_SW,$
BUILD_MODE:
MOV DPTR,#BUILD_LCD
ACALL DISPLAY_STRING
BUILD_MAIN:
ACALL INPUT
ACALL SCREEN_OUTPUT
JNB MASTER_SW,MSW
SJMP BUILD_MAIN

SCREEN_OUTPUT:
MOV R0,#51H
MOV R2,#8D
SO_LOOP:MOV A,R0
MOV B,R1
CJNE A,B,NOTPRESENT
MOV A,CURSOR_X
ORL A,@R0
SJMP NEXT_LINE 
NOTPRESENT:MOV A,@R0
NEXT_LINE:MOV P2,A
ACALL NEXT_GND
ACALL MICRO_DELAY
INC R0
DJNZ R2,SO_LOOP
RET

NEXT_GND:
MOV A,P3
RR A
MOV P3,A
RET

INPUT:JB UP,L1
MOV A,R1
CJNE A,#58H,GO_UP
MOV R1,#51H
SJMP RESET
GO_UP:INC R1
RESET:NOP
ACALL DELAY
L1:JB RIGHT,L2
MOV A,CURSOR_X
RR A
MOV CURSOR_X,A
ACALL DELAY
L2:JB DOWN,L3
MOV A,R1
CJNE A,#51H,GO_UP1
MOV R1,#58H
SJMP RESET1
GO_UP1:DEC R1
RESET1:NOP
ACALL DELAY
L3:JB LEFT,BUILD_INPUT
MOV A,CURSOR_X
RL A
MOV CURSOR_X,A
ACALL DELAY
BUILD_INPUT:JB BUILD,ENDINPUT
MOV A,@R1
MOV B,CURSOR_X
ORL A,B
MOV @R1,A
ACALL DELAY
ENDINPUT:NOP
RET

DELAY:
MOV TMOD,#01H
MOV R7,#4
SEC:MOV TL0,#00H
MOV TH0,#00H
SETB TR0
JNB TF0,$
CLR TR0 
CLR TF0
DJNZ R7,SEC
RET

MICRO_DELAY:
MOV TMOD,#02H
MSEC:MOV TL0,#00H
SETB TR0
JNB TF0,$
CLR TR0 
CLR TF0
RET

LCD_INIT:
MOV A,#38H
ACALL LCD_CMD
MOV A,#0FH
ACALL LCD_CMD
MOV A,#06H
ACALL LCD_CMD
MOV A,#01H
ACALL LCD_CMD
RET

LCD_CMD:
MOV P0,A
CLR RS
SETB EN
CLR EN
ACALL DELAY
RET

LCD_DATA:
MOV P0,A
SETB RS
SETB EN
CLR EN
ACALL DELAY
RET

GENERATE_HEX:
MOV DPTR,#HEX_LCD
ACALL DISPLAY_STRING
MOV A,#01H
ACALL LCD_CMD
MOV R1,#58H
MOV DPTR,#HEX_VALS
MOV R6,#8D
NEXT_HEX:MOV A,@R1
ANL A,#0F0H
SWAP A
MOV 88H,A
MOVC A,@A+DPTR
ACALL LCD_DATA
MOV A,@R1
ANL A,#0FH
MOVC A,@A+DPTR
MOV 89H,A
ACALL LCD_DATA
MOV A,#' '
ACALL LCD_DATA
DEC R1
MOV A,R6
MOV 10H,R6
CJNE A,#5,SAME_LINE
MOV A,#3FH
ACALL LCD_CMD
MOV A,#0C0H
ACALL LCD_CMD
ACALL MICRO_DELAY
SAME_LINE:DJNZ R6,NEXT_HEX
RET

DISPLAY_STRING:
MOV A,#01H
ACALL LCD_CMD
NEXT_CHAR:CLR A
MOVC A,@A+DPTR
ACALL LCD_DATA
ACALL MICRO_DELAY
INC DPTR
JNZ NEXT_CHAR
RET

ORG 400H
BUILD_LCD: DB "Build Mode..",0
HEX_LCD: DB "Generating hex..",0
HEX_VALS: DB '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
END 