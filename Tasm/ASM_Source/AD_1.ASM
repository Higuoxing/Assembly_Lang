;*******************************;
;*接收A/D转换器数据在屏幕上显示*;
;*******************************;
ioport		equ 0d400h-0280h
io0809a		equ ioport+298h
code segment
	assume cs:code
start:mov  dx,io0809a       ;启动A/D转换器
	out  dx,al
	mov  cx,0ffh       ;延时
delay:loop delay
	in   al,dx         ;从A/D转换器输入数据
	mov  bl,al         ;将AL保存到BL
	mov  cl,4
	shr  al,cl         ;将AL右移四位
	call disp          ;调显示子程序显示其高四位
	mov  al,bl
	and  al,0fh
	call disp          ;调显示子程序显示其低四位
	mov  ah,02
	mov  dl,20h        ;加回车符
	int  21h
	mov  dl,20h
	int  21h
	push dx
	mov  ah,06h          ;判断是否有键按下
	mov  dl,0ffh
	int 21h
	pop dx
	je   start         ;若没有转START
	mov  ah,4ch        ;退出
	int  21h
disp  proc near          ;显示子程序
	mov  dl,al
	cmp  dl,9          ;比较DL是否>9
	jle  ddd           ;若不大于则为'0'-'9',加30h为其ASCII码
	add  dl,7          ;否则为'A'-'F',再加7
ddd:    add  dl,30h        ;显示
	mov  ah,02
	int  21h
	ret
disp endp
code ends
end start
