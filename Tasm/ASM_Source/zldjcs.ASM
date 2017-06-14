;******************;
;* 电机测速程序  *;
;******************;
ioport		equ 0ec00h-0280h
io8255k		equ ioport+28bh   ;8255控制口
io8255a		equ ioport+288h   ;8255 A口
io8253k		equ ioport+283h   ;8253控制
io82532		equ ioport+282h   ;8253计数器2
io82531		equ ioport+281h   ;8253计数器1
io82530		equ ioport+280h   ;8253计数器0
data   segment
mess   db 'Strike any key,return to DOS!',0AH,0DH,'$'
cou    db 0
cou1	db 0
count1  db 0
count2  db 0
count3  db 0
count4  db 0
data   ends
code   segment
assume cs:code,ds:data
start:   mov	ax,data
	  mov	ds,ax
	  mov	dx,offset mess
	  mov	ah,09h
	  int	21h                ;显示提示信息
	  mov   dx,io8253k
	  mov   al,36h             ;计数器0，方式3，先读写低8位，再读写高8位
	  out   dx,al              ;输入时钟，1MHZ
	  mov   dx,io82530
	  mov   ax,50000           ;初值50000，输出时钟周期50ms
	  out   dx,al
	  nop
         nop
	  mov   al,ah
	  out   dx,al
	  
	  mov	dx,io8255k             ;8255,A通道输入，C0输出
	  mov	al,90h
	  out	dx,al
	  mov	al,00
	  out	dx,al               ;C0(GATE1)低电平,定时器1禁止计数
	
	
ll:	  mov	ah,01h              ;有无键入
	  int	16h
	  jnz	quit1               ;有键，返回
	    
	  mov   dx,io8253k           
	  mov   al,70h
	  out   dx,al              ;计数器1，方式0，先读写低8位，再读写高8位。
	  mov   dx,io82531         ;输入时钟为光电开关输出。
	  mov   al,0ffh
	  out   dx,al
	  nop
	  nop
	  out   dx,al
	  
	  mov	dx,io8253k
	  mov	al,90h
	  out	dx,al              ;计数器2，方式0，只读写低8位
	  mov	dx,io82532
	  mov	al,100
	  out	dx,al               ;初值100，检测5秒
	  
	  mov	dx,io8255k
	  mov	al,01h
	  out	dx,al               ;PC0输出1，定时器1开始计数
	  	 
	  jmp	a0
quit1:	  jmp	quit
a0:	  mov	dx,io8255a             
a1:	  in	al,dx
	  and	al,01h
	  jz	a1                  ;8255 PA0是否为0
	  mov	dx,io8255k
	  mov	al,00h
	  out	dx,al               ;定时器1停止计数
	  	
          mov	dx,io82531
          in	al,dx
          mov	bl,al
          in	al,dx
          mov	bh,al              ;16位计数值送bx
          mov	ax,0ffffh
          sub	ax,bx              ;计算脉冲个数
	  call	disp                ;显示
	  mov	dl,0dh
	  mov	ah,02
	  int	21h
	  mov	dl,0ah
	  mov	ah,02
	  int	21h
          jmp ll                   ;无键，测量

;------------------------------------------------------------
disp	  PROC	NEAR                 ;BCD转换并显示子程序
	  mov	dx,0000h
	  mov	cx,03e8h             ;除1000
	  div	cx
	  mov	count1,al            ;千位            
	  mov	ax,dx
	  mov	cl,64h
	  div	cl                   ;除100
	  mov	count2,al            ;百位
	  mov	al,ah
	  mov	ah,00h
	  mov	cl,10
	  div	cl                   ;除10
	  mov	count3,al            ;10位
	  mov	count4,ah            ;个位          
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
          cmp	al,09h
          jle	num
          add	al,07h
num:      add	al,30h
          mov	dl,al
          mov	ah,02
          int	21h                 
          ret
disp1	  endp
;-------------------------------------------------------------
quit:	  
	 
	  mov ah,4ch               ;返回DOS
	  int 21h
	  
code    ends
	end start
	