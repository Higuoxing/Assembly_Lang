;*******************
;*     录音机      *
;*******************
data segment
ioport		equ 01400h-0280h
luport		equ ioport+29ah                  ;录音口地址
fangport	equ ioport+290h                  ;放音口地址
io8253a		equ ioport+283h
io8253b		equ ioport+280h
io8255c		equ ioport+28bh
io8255d		equ ioport+288h
data_qu  db 60000 dup(?)                         ;录音数据存放数据区
news_1   db 'Press any key to record:',24h       ;录音提示
news_2   db 0dh,0ah,' Press SPACE to Playing,other key is exit:',24h	;放音提示
data     ends
code     segment
	 assume cs:code,ds:data,es:data
begin:   mov ax,data                              ;初始化
	 mov  ds,ax
	 mov es,ax
	 mov  dx,offset news_1                    ;显示录音提示
	 mov  ah,9
	 int  21h
test_1:	 mov  ah,1                                ;等待键盘输入
	 int  16h
	 jz  test_1                               ;若不是则循环等待
	 call  lu                                 ;调用录音子程序
	 mov dx,offset news_2                     ;显示放音提示
	 mov ah,9
	 int 21h
fy: 	 call fang                                ;调用放音子程序
	 mov ax,0c07h
	 int 21h
	 cmp al,20h
	 jz fy
	 mov ah,4ch                              ;返回
	 int 21h
lu proc near                                     ;录音子程序
	 mov di,offset data_qu                   ;置数据区首地址为DI
	 mov cx,60000                            ;录60000个数据
	 cld
xunhuan:mov dx,luport                             ;启动A/D
	out dx,al
	call delay                               ;延时
	in al,dx                                 ;从A/D读数据到AL
	stosb                                    ;存入数据区,使DI加1
	loop xunhuan                             ;循环
	ret                                      ;子程序返回
lu endp
fang proc near                                   ;放音子程序
	 mov cx,60000                            ;放60000个数据
	 mov si,offset data_qu                   ;置数据区首地址为SI
	 cld
fang_yin: mov dx,fangport
	 lodsb                                   ;从数据区取出数据
	 sub al,30h
	 out dx,al                               ;放音
	 call delay                              ;延时
	 loop fang_yin                           ;循环
	 ret                                     ;子程序返回
fang endp
delay proc	near                             ;延时子程序
	push	dx
	mov	al,10h                           ;设8253通道0工作方式0
	mov	dx,io8253a
	out	dx,al
	mov	al,200                           ;写入计数器初值200
	mov	dx,io8253b
	out	dx,al
	mov	dx,io8255c                       ;设8255的A口为输入
	mov	al,9bh
	out	dx,al
	mov	dx,io8255d                       ;从8255的A口输入
delay1:	in	al,dx
	and	al,1                             ;判断PA0是否为1
	jz	delay1                           ;若PA0不为1,转de_lay
	pop	dx
	ret                                      ;子程序返回
delay endp
code ends
end begin
