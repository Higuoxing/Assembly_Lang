;**************************************
;* 键盘输入数据(0-9)控制LED数码管显示 *
;**************************************
data  segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+288h
io8255b		equ ioport+28bh
led      db        3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh
mesg1    db        0dh,0ah,'Input a num (0--9),other key is exit:',0dh,0ah,'$'
data ends
code  segment
	assume cs:code,ds:data
start:  mov ax,data
	mov ds,ax
	mov dx,io8255b           ;使8255的A口为输出方式
	mov ax,80h
	out dx,al
sss:    mov dx,offset mesg1    ;显示提示信息
	mov ah,09h
	int 21h
	mov ah,01              ;从键盘接收字符
	int 21h
	cmp al,'0'             ;是否小于0
	jl  exit               ;若是则退出
	cmp al,'9'             ;是否大于9
	jg  exit               ;若是则退出
	sub al,30h             ;将所得字符的ASCII码减30H
	mov bx,offset led      ;bx为数码表的起始地址
	xlat                   ;求出相应的段码
	mov dx,io8255a            ;从8255的A口输出
	out dx,al
	jmp sss                ;转SSS
exit:   mov ah,4ch             ;返回
	int 21h
code ends
	end start



