;********************************;
;*    简单并行输入实验          *;
;********************************;
ioport		equ 0d400h-0280h
ls244		equ ioport+2a0h
code segment
	assume cs:code
start:mov dx,ls244        ;从2A0输入一数据
	in al,dx
	mov dl,al          ;将所读数据保存在DL中
	mov ah,02
	int 21h
	mov dl,0dh         ;显示回车符
	int 21h
	mov dl,0ah         ;显示换行符
	int 21h
	mov ah,06           ;是否有键按下
	mov dl,0ffh
	int 21h
	jnz exit
	je start           ;若无,则转start
exit: mov ah,4ch         ;返回
	int 21h
code  ends
end start
