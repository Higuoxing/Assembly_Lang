;**************************
;*     8250´®ÐÐÍ¨ÐÅ       *
;**************************
DATA SEGMENT
ioport		equ 0d400h-0280h
PORT		equ ioport+2b8h
PORT1		equ ioport+2b9h
PORT3		equ ioport+2bbh
PORT5		equ ioport+2bdh
MES	DB 'You can play a key on the Keyboard!',0AH,0DH
	DB 'ESC quit to dos!',0AH,0DH,'$'
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA
START:		MOV	AX,DATA
		MOV	DS,AX
		MOV	AL,80H
		MOV	DX,PORT3
		OUT	DX,AL
		MOV	AL,13                ;set light divisor
		MOV	DX,PORT
		OUT	DX,AL
		MOV	AL,00                ;set low divisor 9600 boud
		MOV	DX,PORT1
		OUT	DX,AL
		MOV	AL,00011011B         ;8 bits 1 stop 
		MOV	DX,PORT3
		OUT	DX,AL
		MOV	AL,00H
		MOV	DX,PORT1
		OUT	DX,AL                ;interrupt enable all off
		MOV	DX,OFFSET MES
		MOV	AH,09H
		INT	21H
WAITI:		MOV	DX,PORT5
		IN 	AL,DX                ;GET LINE STATUS
		AND	AL,20H
		TEST	AL,20H
		JZ	WAITI
		MOV	AH,01
		INT	21H
		CMP	AL,27
		JZ	EXIT
		MOV	DX,PORT
		INC	AL
		OUT	DX,AL
		MOV	CX,40H
S50:		LOOP	S50
NEXT:		MOV	DX,PORT5
		IN	AL,DX
		AND	AL,01
		TEST	AL,01
		JZ	NEXT
		MOV	DX,PORT
		IN 	AL,DX
		MOV	DL,AL
		MOV	AH,02
		INT	21H
		JMP	WAITI
EXIT:		MOV	AH,4CH
		INT	21H
CODE ENDS
END START
