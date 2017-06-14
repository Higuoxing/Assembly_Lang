;*******************************;
;*           步进电机          *;
;*******************************;
DATA SEGMENT 
ioport	EQU 	0d400h-0280h
P55A    EQU     ioport+288H   ;8255 A PORT OUTPUT
P55C    EQU     ioport+28AH   ;8255 C PORT INPUT
P55CTL  EQU     ioport+28BH   ;8255 COUTRL PORT
BUF     DB      0
MES     DB 'K0-K6 ARE SPEED CONTYOL',0AH,0DH
	DB 'K6 IS THE LOWEST SPEED ',0AH,0DH
	DB 'K0 IS THE HIGHEST SPEED',0AH,0DH
	DB 'K7 IS THE DIRECTION CONTROL',0AH,0DH,'$'
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA
START:          MOV     AX,CS
		MOV     DS,AX
		MOV     AX,DATA
		MOV     DS,AX
		MOV     DX,OFFSET MES
		MOV     AH,09
		INT     21H
		MOV     DX,P55CTL
		MOV     AL,8BH
		OUT     DX,AL                   ;8255 C INPUT, A OUTPUT
		MOV     BUF,33H
OUT1:           MOV     AL,BUF
		MOV     DX,P55A
		OUT     DX,AL
		push    dx
		MOV     AH,06h
		mov     dl,0ffh
		INT     21H                      ;ANY KEY PRESSED 
		pop     dx
		JE      IN1
		MOV     AH,4CH
		INT     21H

IN1:            MOV     DX,P55C
		IN      AL,DX                   ;INPUT SWITCH VALUE 
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
		TEST    AL,40H
		JNZ     K6
STOP:           MOV     DX,P55A
		MOV     AL,0FFH
		JMP     OUT1

K0:             MOV     BL,10H
SAM:            TEST    AL,80H
		JZ      ZX0
		JMP     NX0
K1:             MOV     BL,18H
		JMP     SAM
K2:             MOV     BL,20H
		JMP     SAM
K3:             MOV     BL,40H
		JMP     SAM
K4:             MOV     BL,80H
		JMP     SAM
K5:             MOV     BL,0C0H
		JMP     SAM
K6:             MOV     BL,0FFH
		JMP     SAM
ZX0:            CALL    DELAY
		MOV     AL,BUF
		ROR     AL,1
		MOV     BUF,AL
		JMP     OUT1
NX0:            CALL    DELAY
		MOV     AL,BUF
		ROL     AL,1
		MOV     BUF,AL
		JMP     OUT1

DELAY PROC    NEAR
DELAY1:         MOV     CX,05A4H
DELAY2:         LOOP    DELAY2
		DEC     BL
		JNZ     DELAY1
		RET
DELAY ENDP
CODE ENDS
END START
