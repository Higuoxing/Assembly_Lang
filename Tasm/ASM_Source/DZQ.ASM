;*******************
;*     电子琴      *
;*******************
data segment
ioport		equ 0d400h-0280h
io8253a		equ ioport+280h
io8253b		equ ioport+283h
io8255a		equ ioport+288h
io8255b		equ ioport+28bh
io0832a		equ ioport+290h
data1  db 80h,96h,0aeh,0c5h,0d8h,0e9h,0f5h,0fdh
       db 0ffh,0fdh,0f5h,0e9h,0d8h,0c5h,0aeh,96h
       db 80h,66h,4eh,38h,25h,15h,09h,04h
       db 00h,04h,09h,15h,25h,38h,4eh,66h	;正弦波数据
time   db 120,106,94,89,79,70,63,59	;发不同音时8253的计数器初值
msg    db 'Press 1,2,3,4,5,6,7,8,ESC:',0dh,0ah,'$'
num    db ?	;num为8253计数器初值的序号
data ends
code segment
    assume cs:code,ds:data
start:  mov ax,data
	mov ds,ax
	mov dx,offset msg
	mov ah,9
	int 21h              ;显示提示信息
sss:    mov ah,7
	int 21h              ;从键盘接收字符,不回显
	cmp al,1bh
	je  exit             ;若为ESC键,则转EXIT
	cmp al,31h
	jl  sss
	cmp al,38h
	jg  sss              ;若不在'1'-'8'之间转sss
	sub al,31h
	mov num,al           ;求出相应的时间常数的序号
	mov cx,60             ;取60次32个正弦波数据
ddd:	mov si,0
lll:	mov al,data1[si]     ;取正弦波数据
	mov dx,io0832a
	out dx,al            ;放音
	call delay           ;调延时子程序
	inc si
	cmp si,32            ;是否取完32个数据
	jl lll               ;若没有,则继续
	loop ddd             ;总循环次数60是否完,没有,则继续
	jmp sss
exit:   mov ah,4ch
	int 21h
delay proc near              ;延时子程序
ccc:    mov bx,offset time
	mov dx,io8253b       ;置8253通道0为方式0工作
	mov al,10h
	out dx,al
	mov dx,io8255b       ;设8255A口输入
	mov al,9bh
	out dx,al
	mov al,num           ;取相应的时间常数
	xlat
	mov dx,io8253a
	out dx,al            ;向8253通道0输出
kkk:	mov dx,io8255a
	in  al,dx            ;从8255A口读一字节
	test al,01           ;判PA0口是否为1
	jz  kkk              ;若不为1,则转KKK
	ret                  ;子程序返回
delay  endp
code   ends
	end  start
