
;*************DS18B20g.ASM*************************
;
;不用定时中断，用8253方式0延时，时钟1MHZ,计一个数1us
;**********************************************************
ioport		equ 0d400h-0280h
io8255k		equ ioport+28bh      ;8255 控制口
io8255c		equ ioport+28ah      ;8255 C口
io8255a		equ ioport+288h      ;8255 A口
io8253a		equ ioport+283h      ;8253 控制口
io8253b		equ ioport+280h      ;8253 计数器0
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
TEMP	  DB  00                             ;温度，8位
TEMPL	  DB  00                             ;温度，低字节
TEMPH	  DB  00                             ;温度，高字节
TEMPD	  DB  00                             ;温度，小数位
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
          INT   21H                    ;显示提示信息
;----------------------------------------------------------
          MOV	DX,io8255k             ;8255初始化
          MOV	AL,91H
          OUT	DX,AL                  ;8255 PA0 IN PC7-PC4 OUT PC0-PC3 IN     
          CALL	INI                    ;初始化       
          MOV	AH,0CCH                ;跳过读ROM命令
          CALL	WRITE
          MOV	AH,4EH                 ;写暂存器命令
          CALL	WRITE
          MOV	AH,32H                 ;写高温度值50度
          CALL	WRITE
          MOV	AH,00H                 ;写低温度值0度
          CALL	WRITE                            
          MOV	AH,1FH                 ;写配置字节
          CALL	WRITE

KEY:      MOV	AH,01H                 ;查有否键入                  
          INT	16H
          jz	key
          MOV   AH,00                  ;有键入，读取键值
          INT	16H
          CMP	Al,1BH	
          JZ    sss                    ;ESC 退出
          CALL	INI                    ;初始化
          MOV	AH,0CCH                ;跳过读ROM命令
          CALL	WRITE
          MOV	AH,44H                 ;温度转换命令
          CALL	WRITE
      
conv:    
          MOV	DX,io8255k
	  MOV	AL,0eH                  ;PC7清另
	  OUT	DX,AL      
	  nop
	  nop
	  MOV	DX,io8255k
	  MOV	AL,0fH                  ;PC7置1
	  OUT	DX,AL
conv1:    call	delay1                  ;延迟50ms 
	  call  delay1
	  MOV	DX,io8255k
	  MOV	AL,0fH                  ;PC7置1
	  OUT	DX,AL
;         MOV	DX,io8255a
;	  IN	AL,DX
;	  AND	AL,80H                  ;转换是否完成？未完成等待     
;	  jz	conv1
          CALL	INI                    ;初始化
          MOV	AH,0CCH                ;跳过读ROM命令
          CALL	WRITE		
          MOV	AH,0BEH                ;读暂存器命令
          CALL	WRITE
          CALL	READ                   ;读两个字节
          MOV	TEMPL,ah
          CALL	READ
          MOV	TEMPH,ah
          MOV	AL,TEMPL               ;合成一个十六位字
          MOV	CL,04
          SAL	AX,CL                  ;左移四位
          and	ah,7fh
          MOV	TEMP,AH                ;温度值整数部分
                
          jmp	jjj
sss:      jmp	exit
jjj:      MOV	BUFF,2BH               ;+
AGN:      MOV	AH,TEMPL
          AND	AH,08H                   ;温度值小数部分
          JZ    AGN1
          MOV	BUFF5,35H             ;.5
          JMP	AGN2
AGN1:     MOV	BUFF5,30H             ;.0
;----------------------------------------------------------------------
AGN2:     mov	dl,buff
	  mov	ah,02
	  int	21h
          call	disp                ;显示
	  mov	dl,0dh
	  mov	ah,02
	  int	21h
	  mov	dl,0ah
	  mov	ah,02
	  int	21h
          JMP	KEY
;--------------------------------------------------------------------
;恢复现场，返回DOS
EXIT:     
	  MOV	AX,4C00H
	  INT	21H
            
;------------------------------------------------------------
;延时子程序，延时时间长短由COUNT
;的值决定

DELAY:    push	ax 
	  pushf            
          MOV   DX,io8253a
          MOV   AL,30H                 ;定时器0，模式0，16位
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
;DS18B20初始化子程序

	 
INI:	  MOV	DX,io8255k
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7置0 口清0  
	  MOV	COUNT0,02h
	  mov	count,0bch
          CALL	DELAY                   ;主机发复位脉冲持续700微妙
          MOV	COUNT0,00
          mov	count,00                  
          MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;主机置位，为输入作准备  
	  MOV	COUNT0,00
	  mov	count,28h
	  CALL	DELAY                   ;等待40微秒
	  MOV	COUNT,00
ini1:	  MOV	DX,io8255a
	  IN	AL,DX
	  AND	AL,80H
	  JNZ	INI                      ;数据线应变低，若没变低，重来。                      ;数据线变高，初始化成功                       ;初始化失败，重来
L2:       
          MOV	COUNT0,02h
          mov	count,0bch
          CALL	DELAY                    ;DS18B20的应答过程至少需700微秒
          mov	count0,00
          MOV	COUNT,00
          MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL    
          RET

;--------------------------------------------------------------------------
;写DS18B20子程序
WRITE	  PROC	NEAR
          MOV	COUNT1,08H
W0:	 
          MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7清1  
w1:	  MOV	DX,io8255k
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7置0,DS18B20数据线变低
	  nop
	  nop
	  SHR	AH,01
	  JC	W2
	  MOV	DX,io8255k                 
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7置0,写0
	  JMP	W3
W2:       MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7清1,写1 
W3:       MOV	COUNT0,00
          mov	count,46h
	  CALL	DELAY                   ;延时70微秒，写时间为70微秒
	  MOV	COUNT,00
	  MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL 
	  DEC	COUNT1
	  JNZ	W1  
	 
	  RET
WRITE	  ENDP
;-----------------------------------------------------------------
;读DS18B20子程序

READ:     MOV	COUNT1,08H
          mov   ah,00
RE1:      
	  MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7置1,数据线为1
	  nop
wt0:	  MOV	DX,io8255k
	  MOV	AL,0eH
	  OUT	DX,AL                   ;PC7置0,数据线为0
	  mov	cx,02h
wt2:	  loop	wt2
	  MOV	DX,io8255k
	  MOV	AL,0fH
	  OUT	DX,AL                   ;PC7置1,数据线为1	  
	  mov	cx,08h
wt1:	  loop	wt1
	  MOV	DX,io8255a
	  IN	AL,DX
	  AND	AL,80H                  ;按位读数据
	  RCL	al,01                   ;数据送CF	
	  RCR	ah,01                   ;数据通过CF送AH
	  MOV	COUNT0,00
	  mov	count,46h
	  CALL	DELAY                   ;读数据过程持续60微秒
	  MOV	COUNT,00           
	  DEC	COUNT1
	  JNZ	wt0 	         	  
	  RET


;-------------------------------------------------------------------
;转换成BCD码并显示
disp	  PROC	NEAR                 ;BCD转换并显示子程序
	  mov	al,temp
	  mov	ah,00h
	  mov	cl,100
	  div	cl                   ;除100
	  mov	buff1,al             ;百位值
	  mov	al,ah
	  mov	ah,00
	  mov	cl,10
	  div	cl                    ;除10
	  mov	buff2,al              ;10位值
	  mov	buff3,ah              ;个位值
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
disp1	  PROC	NEAR                ;显示一个字符           
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
          MOV   AL,30H                 ;定时器0，模式0，十六位
          OUT   DX,AL
          MOV   DX,io8253b
          mov	al,50h               ;8253 clk0 1MHZ
          OUT   DX,AL                  ;50ms延时
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
