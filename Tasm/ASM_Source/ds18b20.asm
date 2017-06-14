
;*************DS18B20g.ASM*************************
;
;���ö�ʱ�жϣ���8253��ʽ0��ʱ��ʱ��1MHZ,��һ����1us
;**********************************************************
ioport		equ 0d400h-0280h
io8255k		equ ioport+28bh      ;8255 ���ƿ�
io8255c		equ ioport+28ah      ;8255 C��
io8255a		equ ioport+288h      ;8255 A��
io8253a		equ ioport+283h      ;8253 ���ƿ�
io8253b		equ ioport+280h      ;8253 ������0
STACK     SEGMENT  
STA       DB       20 DUP (?)
TOP       EQU      LENGTH STA
STACK     ENDS
;----------------------------------------------------------
DATA      SEGMENT
CSREG     DW  ?
IPREG     DW  ?
count0	  db  00
COUNT     db  00
COUNT1    DB  00
COUNT2	  DB  00
qf	  db  0eh
TEMP	  DB  00                             ;�¶ȣ�8λ
TEMPL	  DB  00                             ;�¶ȣ����ֽ�
TEMPH	  DB  00                             ;�¶ȣ����ֽ�
TEMPD	  DB  00                             ;�¶ȣ�С��λ
MESS      DB  '8253A TIMERO IN MODEO0 10uS  TIMER',0AH,0DH
          DB  '8255 IN MODEO PA0 INPUT PC4-PC7 OUTPUT',0AH,0DH
          DB  'Strike any key, to convert temperature!',0AH,0DH,'$'
          DB  'Strike ESC key, return to DOS!',0AH,0DH,'$'
buff	  db  20h
BUFF1     DB  20h
buff2	  db  20h
buff3	  db  20h
buff4	  db  2eh
buff5	  db  20h 
DATA      ENDS
;----------------------------------------------------------
CODE      SEGMENT
ASSUME    CS:CODE,DS:DATA,SS:STACK
;----------------------------------------------------------
START:    CLI
          MOV   AX,DATA
          MOV   DS,AX
          MOV   DX,OFFSET MESS
          MOV   AH,09H
          INT   21H                    ;��ʾ��ʾ��Ϣ
;----------------------------------------------------------
          MOV	DX,io8255k             ;8255��ʼ��
          MOV	AL,91H
          OUT	DX,AL                  ;8255 PA0 IN PC7-PC4 OUT PC0-PC3 IN     
          CALL	INI                    ;��ʼ��       
          MOV	AH,0CCH                ;������ROM����
          CALL	WRITE
          MOV	AH,4EH                 ;д�ݴ�������
          CALL	WRITE
          MOV	AH,32H                 ;д���¶�ֵ50��
          CALL	WRITE
          MOV	AH,00H                 ;д���¶�ֵ0��
          CALL	WRITE                            
          MOV	AH,1FH                 ;д�����ֽ�
          CALL	WRITE

KEY:      MOV	AH,01H                 ;���з����                  
          INT	16H
          jz	key
          MOV   AH,00                  ;�м��룬��ȡ��ֵ
          INT	16H
          CMP	Al,1BH	
          JZ    sss                    ;ESC �˳�
          CALL	INI                    ;��ʼ��
          MOV	AH,0CCH                ;������ROM����
          CALL	WRITE
          MOV	AH,44H                 ;�¶�ת������
          CALL	WRITE
      
conv:    
          MOV	DX,io8255k
	  MOV	AL,0eH                  ;PC7����
	  OUT	DX,AL      
	  nop
	  nop
	  MOV	DX,io8255k
	  MOV	AL,0fH                  ;PC7��1
	  OUT	DX,AL
conv1:    call	delay1                  ;�ӳ�50ms 
	  call  delay1
	  MOV	DX,io8255k
	  MOV	AL,0fH                  ;PC7��1
	  OUT	DX,AL
;         MOV	DX,io8255a
;	  IN	AL,DX
;	  AND	AL,80H                  ;ת���Ƿ���ɣ�δ��ɵȴ�     
;	  jz	conv1
          CALL	INI                    ;��ʼ��
          MOV	AH,0CCH                ;������ROM����
          CALL	WRITE		
          MOV	AH,0BEH                ;���ݴ�������
          CALL	WRITE
          CALL	READ                   ;�������ֽ�
          MOV	TEMPL,ah
          CALL	READ
          MOV	TEMPH,ah
          MOV	AL,TEMPL               ;�ϳ�һ��ʮ��λ��
          MOV	CL,04
          SAL	AX,CL                  ;������λ
          and	ah,7fh
          MOV	TEMP,AH                ;�¶�ֵ��������
                
          jmp	jjj
sss:      jmp	exit
jjj:      MOV	BUFF,2BH               ;+
AGN:      MOV	AH,TEMPL
          AND	AH,08H                   ;�¶�ֵС������
          JZ    AGN1
          MOV	BUFF5,35H             ;.5
          JMP	AGN2
AGN1:     MOV	BUFF5,30H             ;.0
;----------------------------------------------------------------------
AGN2:     mov	dl,buff
	  mov	ah,02
	  int	21h
          call	disp                ;��ʾ
	  mov	dl,0dh
	  mov	ah,02
	  int	21h
	  mov	dl,0ah
	  mov	ah,02
	  int	21h
          JMP	KEY
;--------------------------------------------------------------------
;�ָ��ֳ�������DOS
EXIT:     
	  MOV	AX,4C00H
	  INT	21H
            
;------------------------------------------------------------
;��ʱ�ӳ�����ʱʱ�䳤����COUNT
;��ֵ����

DELAY:    push	ax 
	  pushf            
          MOV   DX,io8253a
          MOV   AL,30H                 ;��ʱ��0��ģʽ0��16λ
          OUT   DX,AL
          MOV   DX,io8253b
          MOV   Al,count               ;8253 clk0 1MHZ
          OUT   DX,AL 
          mov	al,count0
          out	dx,al                
          MOV	DX,io8255c
lll:	  in    al,dx
	  and	al,01h
	  jz   lll	
          popf
          pop	ax	
          RET

;------------------------------------------------------------
;DS18B20��ʼ���ӳ���

	 
INI:	  MOV	DX,io8255k
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7��0 ����0  
	  MOV	COUNT0,02h
	  mov	count,0bch
          CALL	DELAY                   ;��������λ�������700΢��
          MOV	COUNT0,00
          mov	count,00                  
          MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;������λ��Ϊ������׼��  
	  MOV	COUNT0,00
	  mov	count,28h
	  CALL	DELAY                   ;�ȴ�40΢��
	  MOV	COUNT,00
ini1:	  MOV	DX,io8255a
	  IN	AL,DX
	  AND	AL,80H
	  JNZ	INI                      ;������Ӧ��ͣ���û��ͣ�������                      ;�����߱�ߣ���ʼ���ɹ�                       ;��ʼ��ʧ�ܣ�����
L2:       
          MOV	COUNT0,02h
          mov	count,0bch
          CALL	DELAY                    ;DS18B20��Ӧ�����������700΢��
          mov	count0,00
          MOV	COUNT,00
          MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL    
          RET

;--------------------------------------------------------------------------
;дDS18B20�ӳ���
WRITE	  PROC	NEAR
          MOV	COUNT1,08H
W0:	 
          MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7��1  
w1:	  MOV	DX,io8255k
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7��0,DS18B20�����߱��
	  nop
	  nop
	  SHR	AH,01
	  JC	W2
	  MOV	DX,io8255k                 
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7��0,д0
	  JMP	W3
W2:       MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7��1,д1 
W3:       MOV	COUNT0,00
          mov	count,46h
	  CALL	DELAY                   ;��ʱ70΢�룬дʱ��Ϊ70΢��
	  MOV	COUNT,00
	  MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL 
	  DEC	COUNT1
	  JNZ	W1  
	 
	  RET
WRITE	  ENDP
;-----------------------------------------------------------------
;��DS18B20�ӳ���

READ:     MOV	COUNT1,08H
          mov   ah,00
RE1:      
	  MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7��1,������Ϊ1
	  nop
wt0:	  MOV	DX,io8255k
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7��0,������Ϊ0
	  mov	cx,02h
wt2:	  loop	wt2
	  MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7��1,������Ϊ1	  
	  mov	cx,08h
wt1:	  loop	wt1
	  MOV	DX,io8255a
	  IN	AL,DX
	  AND	AL,80H                  ;��λ������
	  RCL	al,01                   ;������CF	
	  RCR	ah,01                   ;����ͨ��CF��AH
	  MOV	COUNT0,00
	  mov	count,46h
	  CALL	DELAY                   ;�����ݹ��̳���60΢��
	  MOV	COUNT,00           
	  DEC	COUNT1
	  JNZ	wt0 	         	  
	  RET


;-------------------------------------------------------------------
;ת����BCD�벢��ʾ
disp	  PROC	NEAR                 ;BCDת������ʾ�ӳ���
	  mov	al,temp
	  mov	ah,00h
	  mov	cl,100
	  div	cl                   ;��100
	  mov	buff1,al             ;��λֵ
	  mov	al,ah
	  mov	ah,00
	  mov	cl,10
	  div	cl                    ;��10
	  mov	buff2,al              ;10λֵ
	  mov	buff3,ah              ;��λֵ
ttt:    
          mov	al,buff1
          call	disp1
          mov	al,buff2
          call	disp1
          mov	al,buff3
          call	disp1
          mov	dl,buff4
          mov	ah,02
          int	21h
          mov	al,buff5
          call	disp1
          ret
DISP	  ENDP
;---------------------------------------------------------------------------------
disp1	  PROC	NEAR                ;��ʾһ���ַ�           
          and	al,0fh
          add	al,30h
          mov	dl,al
          mov	ah,02
          int	21h                 
          ret
disp1	  endp
;---------------------------------------------------------------------------
disp2	  proc	near
	  mov	al,temp
	  mov	cl,04
	  shr	al,cl
	  and	al,0fh
	  add	al,30h
	  cmp	al,39h
	  jbe	nt
	  add	al,07
nt:	  mov	dl,al
	  mov	ah,02
	  int	21h
	  mov	al,temp
	  and	al,0fh
	  add	al,30h
	  cmp	al,39h
	  jbe	nt1
	  add	al,07
nt1:	  mov	dl,al
	  mov	ah,02
	  int	21h
	  mov	dl,0ah
	  mov	ah,02
	  int	21h
	  mov	dl,0dh
	  mov	ah,02
	  int	21h
	  ret
disp2	  endp          	
;----------------------------------------------------------
DELAY1	  PROC	NEAR      
          push	ax 
	  pushf       
          MOV   DX,io8253a
          MOV   AL,30H                 ;��ʱ��0��ģʽ0��ʮ��λ
          OUT   DX,AL
          MOV   DX,io8253b
          mov	al,50h               ;8253 clk0 1MHZ
          OUT   DX,AL                  ;50ms��ʱ
          mov	al,0c3h
          out	dx,al
          mov	dx,io8255c
xxx:	  in    al,dx
	  and	al,01h
	  jz   xxx	
          popf
          pop	ax	
          RET
DELAY1    endp   

CODE	  ENDS
END       START  
