;*************************
;本程序为步进电机测速程序
;前部为步进电机转速控制，
;后部为速度测量
;*************************
data   segment
ioport		equ 0ec00h-0280h
io8255k		equ ioport+28bh   ;8255控制口
io8255a		equ ioport+288h   ;8255 A口
io8255c		equ ioport+28ah   ;8255 C
io8253k		equ ioport+283h   ;8253控制
io82532		equ ioport+282h   ;8253计数器2
io82531		equ ioport+281h   ;8253计数器1
io82530		equ ioport+280h   ;8253计数器0
iot8253k		equ ioport+293h   ;通用插座8253控制
iot82530		equ ioport+290h   ;通用插座8253计数器0

mess    db 'Strike any key,return to DOS!',0AH,0DH,'$'
cou	 db 0
cou1	 db 0
count   db 0
count1	 db 0
count2	 db 0
count3	 db 0
count4	 db 0
buf     dw 0
data   ends
code   segment
assume cs:code,ds:data
start:    mov	ax,data
	  mov	ds,ax
	  mov	dx,offset mess
	  mov	ah,09h
	  int	21h                ;显示提示信息
	  
int82531: mov   dx,io8253k
	  mov   al,36h             ;计数器0，方式3，先读写低8位，再读写高8位
	  out   dx,al               ;输入时钟，1MHZ
	  mov   dx,io82530
	  mov   ax,50000           ;初值50000，输出时钟周期50ms
	  out   dx,al
	  mov   al,ah
	  out   dx,al
	  mov	dx,io8253k
	  mov	al,96h
	  out	dx,al               ;计数器2，方式3，只读写低8位
	  mov	dx,io82532
	  mov	al,200
	  out	dx,al               ;初值200，10秒检测一次，检测5秒
	  
int8255:  mov	dx,io8255k      ;8255,A通道输入，C低位输出，高位输入
          mov	al,98h
          out	dx,al
          mov	al,00
          out	dx,al            ;C0(GATE1)低电平，停止计数
readc:    mov	dx,io8255c
          in	al,dx                ;读C口 
          and	al,0f0h            
          test al,10h              ;高速
          jnz	k4
          test al,20h
          jnz	k5
          test al,40h
          jnz	k6
          test al,80h              ;低速
          jnz	k7
          jmp	readc
k4:       mov	buf,4000
          jmp	int8253
k5:       mov	buf,5000
          jmp	int8253
k6:	  mov	buf,6000
	  jmp	int8253
k7:	  mov	buf,8000
int8253:  mov   dx,iot8253k          ;向扩展8253写控制字
	  mov   al,36h                 ;使0通道为工作方式3
	  out   dx,al
	  mov   ax,buf                 ;写入循环计数初值buf
	  mov   dx,iot82530
	  out   dx,al                    ;先写入低字节
	  mov   al,ah
	  out   dx,al                    ;后写入高字节
	  mov	dx,io8255k
	  mov	al,03h
	  out	dx,al                    ;开始输出移位脉冲                                                                                                                                                                             
         mov	dx,io8255k
	  mov	al,04h
	  out	dx,al                     ;预置195 
         mov  cx,0a000h
loop2:   nop
         loop loop2                   ;延时，保证预置成功
         mov	dx,io8255k
	  mov	al,05h
	  out	dx,al                    ;启动电机
                                    
ll:	  mov	ah,01h                   ;有无键入
	  int	16h
	  jnz	quit1                    ;有键，返回
	  jmp	a0
quit1:	  jmp	quit
	
a0:	  mov   dx,io8253k            
	  mov   al,70h
	  out   dx,al                    ;计数器1，方式0，先读写低8位，再读写高8位。
	  mov   dx,io82531              ;输入时钟为光电开关输出。
	  mov   ax,0ffffh
	  out   dx,al
	  mov   al,ah
	  out   dx,al
      	  mov	dx,io8255a             
a1:	  in	al,dx
	  and	al,01h
	  cmp	al,00h
	  jnz	a1                      ;8255 PA0是否为0
a2:	  in	al,dx
         and	al,01h
	  cmp	al,00h
	  jz	a2                          ;8255 PA0是否为1
	  mov	dx,io8255k
	  mov	al,01h
	  out	dx,al                    ;开始计数
	  
	  mov	dx,io8255a
a3:	  in	al,dx
	  and	al,01h
	  cmp	al,00h         
	  jnz	a3                      ;8255 PA0是否为1
	  mov	dx,io8255k
	  mov	al,00h
	  out	dx,al                    ;停止计数	  
        
          mov	dx,io82531
          in	al,dx
          mov	bl,al
          in	al,dx
          mov	bh,al               ;计数值送bx
          mov	ax,0ffffh
          sub	ax,bx              ;计算脉冲个数
	   call	disp                   ;显示
	  mov	dl,0dh
	  mov	ah,02
	  int	21h
	  mov	dl,0ah
	  mov	ah,02
	  int	21h
         jmp int8255                ;无键，测量

;------------------------------------------------------------
disp	  PROC	NEAR                  ;BCD转换并显示子程序
	  mov	dx,0000h
	  mov	cx,1000
	  div	cx
	  mov	count1,al
	  mov	ax,dx
	  mov	cl,100
	  div	cl
	  mov	count2,al
	  mov	al,ah
	  mov	ah,00h
	  mov	cl,10
	  div	cl
	  mov	count3,al
	  mov	count4,ah
          mov	al,count1
          call	disp1
          mov	al,count2
          call	disp1
          mov	al,count3
          call	disp1
          mov	al,count4
          call	disp1
          ret
DISP	  ENDP
;--------------------------------------------------------------------
disp1	  PROC	NEAR                ;显示一个字符           
          and	al,0fh
          add	al,30h
          mov	dl,al
          mov	ah,02
          int	21h                 
          ret
disp1	  endp
;-------------------------------------------------------------
quit:	  mov	dx,io8255k
	  mov	al,02h
	  out	dx,al                        	 
	  mov ah,4ch                     ;返回DOS
	  int 21h	  
code    ends
	end start
