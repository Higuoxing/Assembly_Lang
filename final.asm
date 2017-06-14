ioport           EQU     0ec00h-0280h
io0832          EQU     ioport+290H     ; io0832 port
io8255k         EQU     ioport+28BH     ; io8255 handler port
io8255a         EQU     ioport+288H     ; io8255a port
io8255b         EQU     ioport+289H     ; io8255b port
io8255c         EQU     ioport+28AH     ; io8255c port
io8253k      EQU     ioport+283H        ; io8253 handler port
io82532      EQU     ioport+282H        ; io8253 port 2
io82531      EQU     ioport+281H        ; io8253 port 1
io82530      EQU     ioport+280H        ; io8253 port 0

DATA            SEGMENT

        mess            DB      'Strike r to show the tested value!,s to show the sandard value!',0AH,0DH,'$'   
        LEDCOD  DB     3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
        BUF1            DW      ?
        BUF2            DW      ?
        NUM1    DB  0
        NUM2    DB  0   
        NUM3    DB  0
        NUM4    DB  0
        KEYS    DB  0
        SAND    DW  0           
        RESU    DW  0           
        MINU    DW  0           
        REPL    DW  0           
        REPG    DB  0           
        REPS    DB  0           
        ZFSIT   DB  0FFH            
        K0B2    DW  0010H
        K1B2    DW  0150H
        K2B2    DW  0200H
        K3B2    DW  0250H
        K4B2    DW  0300H
        K5B2    DW  0350H

DATA            ENDS


CODE            SEGMENT
ASSUME          CS:CODE,DS:DATA

START:
        MOV     AX,DATA
        MOV     DS,AX
        MOV     DX,io8255k
        MOV     AL,82H
        OUT     DX,AL
        MOV     DX,io8253k
        MOV     AL,36h     
        OUT     DX,AL             
        MOV     DX,io82530
        MOV     AX,50000
        OUT     DX,AL
        NOP
        NOP
        MOV     AL,AH
        OUT     DX,AL
        MOV     DX,io8255k
        MOV     AL,00H
        OUT DX,AL                 
        MOV DX,offset mess
        MOV AH,09H
        INT 21H
INTK:   
        MOV     DX,io8253k           
        MOV     AL,70H
        OUT     DX,AL
        MOV     DX,io82531
        MOV     AL,0ffH
        OUT     DX,AL
        NOP
        NOP
        OUT     DX,AL
        MOV     DX,io8253k
        MOV     AL,90H
        OUT     DX,AL           
        MOV     DX,io82532
        MOV     AL,100D
        OUT     DX,AL
        MOV     DX,io8255k
        MOV     AL,01H
        OUT     DX,AL   

LOOPER:
        MOV     AH,06H
        MOV     DL,0FFH
        INT     21H
        JE      COUNTER
        MOV     BL,AL
        XOR     BL,73H
        JZ      SANREP
        MOV     BL,AL
        XOR     BL,72H
        JZ      RESREP
        JMP     EXPRO


SANREP: 
        MOV     AX,SAND
        MOV     DX,0000h
        MOV     CX,000ah
        DIV     CX
        MOV     CL,10
        DIV     CL
        MOV     REPS,AL
        MOV     REPG,AH
        JMP     COUNTER

RESREP: 
        MOV     AX,RESU
        MOV     DX,0000h
        MOV     CX,000ah
        DIV     CX
        MOV     CL,10
        DIV     CL
        MOV     REPS,AL
        MOV     REPG,AH
        JMP     COUNTER

EXPRO:
        MOV     AH,4CH
        INT     21H

COUNTER:
        MOV     DX,io8255b             
        IN      AL,DX
        AND     AL,80H
        JZ      SWITMP

FINISH: 
        MOV     DX,io8255k
        MOV     AL,00H
        OUT     DX,AL
        MOV     DX,io82531
        IN      AL,DX
        MOV     BL,AL
        IN      AL,DX
        MOV     BH,AL
        MOV     AX,0FFFFH
        SUB     AX,BX
        MOV     RESU,AX
        CMP     AX,0000H
        JZ      RED                   
        CMP     AX,0200H
        JB      GREEN
        MOV     DX,io8255k
        MOV     AL,02H  
        OUT     DX,AL
        MOV     AL,06H  
        OUT     DX,AL
        MOV     AL,05H
        OUT     DX,AL
        JMP     LOOP2

RED:
        MOV     DX,io8255k      
        MOV     AL,03H
        OUT     DX,AL
        JMP     LOOP2

GREEN: 
        MOV     DX,io8255k  
        MOV     AL,02H  
        OUT     DX,AL
        MOV     AL,04H
        OUT     DX,AL
        MOV     AL,07H                           
        OUT     DX,AL
        JMP     LOOP2  

SWITMP:
        JMP     SWI

LOOP2:
        MOV     DX,io8255c                      
        IN      AL,DX
        TEST    AL,10H
        JNZ     NEXT1
        MOV     DX,RESU
        CMP     DX,SAND
        JL      LESSTHAN
        CMP     DX,SAND
        JG      GREATERTHAN

NEXT1:
        JMP     NEXT

LOOPERTMP:
        JMP     LOOPER

LESSTHAN:
        MOV     BL,KEYS
        TEST    BL,01H
        JNZ     CL0
        TEST    BL,02H
        JNZ     CL1
        TEST    BL,04H
        JNZ     CL2
        TEST    BL,08H
        JNZ     CL3
        TEST    BL,10H
        JNZ     CL4
        TEST    BL,20H
        JNZ     CL5
        JMP     NEXT

CL0:
        SUB     K0B2,0010H
        JMP     NEXT
CL1:
        SUB     K1B2,0010H
        JMP     NEXT
CL2:
        SUB     K2B2,0010H
        JMP     NEXT
CL3:
        SUB     K3B2,0010H
        JMP     NEXT
CL4:
        SUB     K4B2,0010H
        JMP     NEXT
CL5:
        SUB     K5B2,0010H
        JMP     NEXT

GREATERTHAN:    
        MOV     BL,KEYS
        TEST    BL,01H
        JNZ     CG0
        TEST    BL,02H
        JNZ     CG1
        TEST    BL,04H
        JNZ     CG2
        TEST    BL,08H
        JNZ     CG3
        TEST    BL,10H
        JNZ     CG4
        TEST    BL,20H
        JNZ     CG5
        JMP     NEXT

CG0:
        ADD     K0B2,0010H
        JMP     NEXT
CG1:
        ADD     K1B2,0010H
        JMP     NEXT
CG2:
        ADD     K2B2,0010H
        JMP     NEXT
CG3:
        ADD     K3B2,0010H
        JMP     NEXT
CG4:
        ADD     K4B2,0010H
        JMP     NEXT
CG5:
        ADD     K5B2,0010H
        JMP     NEXT

NEXT:   MOV     AX,SAND         
        CALL    DISP
        MOV     DL,0dh
        MOV     AH,02
        INT     21h
        MOV     AX,RESU 
        CALL    DISP             
        MOV     DL,0ah
        MOV     AH,02
        INT     21h
        JMP     INTK


SWI:
        MOV     DX,io8255b
        IN      AL,DX 
        MOV     KEYS,AL
        TEST    AL,40H
        JZ      SWIST
        MOV     ZFSIT,0FFH
        JMP     SWISAND

SWIST:
        MOV     ZFSIT,00H
        MOV     RESU,00H

SWISAND:
        TEST    AL,01H
        JNZ     K0
        TEST    AL,02H
        JNZ     KK1TMP
        TEST    AL,04H
        JNZ     KK2TMP
        TEST    AL,08H
        JNZ     KK3TMP
        TEST    AL,10H
        JNZ     KK4TMP
        TEST    AL,20H
        JNZ     K5TMP
        JMP     LOOPERTMP


K0:
        MOV     SAND,880
        MOV     BUF2,0050H
        MOV     AX,K0B2     
        MOV     BUF1,AX

DELAY: 
        MOV     CX,BUF2
        MOV     AL,0FFH
        MOV     DX,io0832
        OUT     DX,AL

DELAY1:
        MOV     AL,REPS
        MOV     BX,OFFSET LEDCOD
        XLAT
        MOV     DX,io8255a
        OUT     DX,AL
        MOV     AL,REPG
        MOV     BX,OFFSET LEDCOD
        XLAT
        OR      AL,80H
        MOV     DX,io8255a
        OUT     DX,AL
        LOOP    DELAY1
        JMP     TTMP

KK1TMP:
        JMP     K1
KK2TMP:
        JMP     K2
KK3TMP:
        JMP     K3
KK4TMP:
        JMP     K4

TTMP:
        MOV     AL,80H
        MOV     DX,io0832
        OUT     DX,AL
        MOV     CX,BUF1

DELAY2:
        MOV     AL,REPS
        MOV     BX,OFFSET LEDCOD
        XLAT
        MOV     DX,io8255a
        OUT     DX,AL
        MOV     AL,REPG
        MOV     BX,OFFSET LEDCOD
        XLAT
        OR      AL,80H
        MOV     DX,io8255a
        OUT     DX,AL
        LOOP    DELAY2
        JMP     LOOPERTMP

K5TMP:
        JMP     K5

K1:
        MOV     SAND,750
        MOV     BUF2,0050H
        MOV     AX,K1B2 
        MOV     BUF1,AX
        JMP     DELAY

K2:
        MOV     SAND,500 
        MOV     BUF2,0050H
        MOV     AX,K2B2     
        MOV     BUF1,AX
        JMP     DELAY

K3:
        MOV     SAND,430
        MOV     BUF2,0050H
        MOV     AX,K3B2     
        MOV     BUF1,AX
        JMP     DELAY

K4:
        MOV     SAND,140
        MOV     BUF2,0050H
        MOV     AX,K4B2     
        MOV     BUF1,AX
        JMP     DELAY

K5:
        MOV     SAND,110
        MOV     BUF2,0050H
        MOV     AX,K5B2     
        MOV     BUF1,AX
        JMP     DELAY

DISP PROC NEAR
        MOV     DX,0000h
        MOV     CX,000ah
        DIV     CX     
        MOV     CL,10
        DIV     CL
        MOV     NUM3,AL
        MOV     NUM4,AH          
        MOV     AL,NUM3
        CALL    DISP1
        MOV     AL,NUM4
        CALL    DISP1
        RET
        DISP    ENDP

DISP1 PROC NEAR          
        AND             AL,0FH
        CMP             AL,09H
        JLE             NUM
        ADD             AL,07H

NUM:
                ADD    AL,30H
        MOV             DL,AL
        MOV             AH,02
        INT             21H        
        RET

DISP1 ENDP
CODE ENDS
END START
