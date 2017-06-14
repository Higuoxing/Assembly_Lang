DATA            SEGMENT
Ioport          equ     0d400h-0280h
PORT1           EQU     ioport+290H
PORT2           EQU     ioport+28BH
PORT3           EQU     ioport+28AH
BUF1            DW      ?
BUF2            DW      ?
DATA            ENDS
CODE            SEGMENT
ASSUME          CS:CODE,DS:DATA
START:		MOV     AX,DATA
		MOV     DS,AX
MOV     DX,PORT2
		MOV     AL,8BH
		OUT     DX,AL            ;8255 PORT C INPUT
LLL:            MOV     AL,80H
		MOV     DX,PORT1
		OUT     DX,AL             ;D/A OUTPUT 0V
		push    dx
		MOV     AH,06h
		mov     dl,0ffh
		INT     21H
		pop     dx
		JE      INTK              ;NOT ANY KEY JMP INTK
		MOV     AH,4CH
		INT     21H               ;EXIT TO DOS
INTK:           MOV     DX,PORT3
		IN      AL,DX             ;READ SWITCH
		TEST    AL,01H
		JNZ     K0
		TEST    AL,02H
		JNZ     K1
		TEST    AL,04H
		JNZ     K2
		TEST    AL,08H
		JNZ     K3
		TEST    AL,10H
		JNZ     K4
		TEST    AL,20H
		JNZ     K5
		JMP     LLL
K0:             MOV     BUF1,0400H
		MOV     BUF2,0330H
DELAY:          MOV     CX,BUF1
DELAY1:         LOOP    DELAY1
		MOV     AL,0FFH
		MOV     DX,PORT1
		OUT     DX,AL
		MOV     CX,BUF2
DELAY2:         LOOP    DELAY2
		JMP     LLL
K1:             MOV     BUF1,0400H
		MOV     BUF2,0400H
		JMP     DELAY
K2:             MOV     BUF1,0400H
		MOV     BUF2,0500H
		JMP     DELAY
K3:             MOV     BUF1,0400H
		MOV     BUF2,0600H
		JMP     DELAY
K4:             MOV     BUF1,0400H
		MOV     BUF2,0700H
		JMP     DELAY
K5:             MOV     BUF1,0400H
		MOV     BUF2,0800H
		JMP     DELAY
CODE ENDS
END START

