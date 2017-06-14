;******************************;
;*      ¼üÅÌÏÔÊ¾¿ØÖÆÆ÷1       *;
;******************************;
ioport		equ 0d400h-0280h
PORT0   EQU     ioport+2B0H          ;8279 DATA PORT
PORT1   EQU     ioport+2B1H          ;8279 CTRL PORT
DATA            SEGMENT
SEC1            DB      0             ;HOUR HIGHT
SEC2            DB      0             ;HOUP LOW
MIN1            DB      0             ;MIN  HIGHT
MIN2            DB      0             ;MIN LOW
HOUR1           DB      0             ;SEC HIGHT
HOUR2           DB      0             ;SEC LOW
LED             DB 3FH,06,5BH,4FH,66H,6DH,7DH,07,7FH,6FH,77H,7CH,39h,5EH,79h,71h
		DB 67H,37H,73H,31H,3EH,36H,66H
DATA            ENDS
CODE    SEGMENT
MAIN            PROC    FAR
ASSUME  CS:CODE,DS:DATA
START:          CLI
		MOV     AX,DATA
		MOV     DS,AX
		mov     sec1,0
		mov     sec2,0
		mov     min1,0
		mov     min2,0
		mov     hour1,0
		mov     hour2,0
		MOV     DX,PORT1
		MOV     AL,0D3H
		OUT     DX,AL                          ;8279 CLEAR
		MOV     AL,2AH
		OUT     DX,AL                          ;8279 CLOCK
		MOV     AL,40H
		OUT     DX,AL                          ;READ FIFO RAM COMMAND
		MOV     AL,00H
		OUT     DX,AL                          ;KEYBORD DISPLY MODE
		MOV     AL,80H
		OUT     DX,AL                          ;WRITE RAM COMMAND
KEY1:           CALL    KEY2                        ;CALL KEYBORD AND DISPLY
NEXT2:          MOV     HOUR2,AL
		MOV     HOUR1,AL
		MOV     MIN2,AL
		MOV     MIN1,AL
		MOV     SEC2,AL
		MOV     SEC1,AL
		push	ax
		mov	ah,1
		int	16h
		jne	toexit
LP0:		pop	ax
		CMP     AL,13H                             ;'R' COMMAND
		JNZ     LP1
toexit:		MOV     AX,4C00H                          ;QUIT TO DOS
		INT     21H
LP1:            JMP     KEY1
MAIN            ENDP        

KEY2            PROC    NEAR
		MOV     DX,PORT1
		MOV     AL,0D1H
		OUT     DX,AL                        ;CLEAR DISPLAY
WREP:           CALL    DISP
		MOV     DX,PORT1
		IN      AL,DX
		AND     AL,07H
		JZ      WREP
KEYN:           MOV     DX,PORT0
		IN      AL,DX
		MOV     BL,AL
		AND     AL,07H
		AND     BL,38H
		MOV     CL,03
		SHR     BL,CL
		CMP     BL,00H
		JNZ     LINE1
		ADD     AL,08H
		JMP     QUIT1
LINE1:          CMP     BL,01H
		JNZ     LINE2
		JMP     QUIT1
LINE2:          ADD     AL,10H
QUIT1:          RET
KEY2            ENDP

DISP            PROC    NEAR
		PUSH    CX
		MOV     AX,DATA
		MOV     DS,AX
		MOV     DX,PORT1
		MOV     AL,90H
		OUT     DX,AL
		MOV     SI,OFFSET SEC1
		MOV     CX,0006
		MOV     BX,OFFSET LED
DISP1:          CLD
		LODSB
		XLAT
		MOV     DX,PORT0
		OUT     DX,AL
		LOOP    DISP1
		POP     CX
		RET
DISP            ENDP
CODE            ENDS
END             START