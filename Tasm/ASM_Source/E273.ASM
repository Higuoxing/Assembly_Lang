;****************************;
;*   简单的并行输出实验     *;
;****************************;
ioport		equ 0d400h-0280h
ls273		equ ioport+2a8h
code segment
  assume cs:code
start:
	mov ah,2      ;回车符
	mov dl,0dh
	int 21h
	mov ah,1      ;等待键盘输入
	int 21h
	cmp al,27     ;判断是否为ESC键
	je exit       ;若是则退出
	mov dx,ls273   ;若不是,从2A8H输出其ASCII码
	out dx,al
	jmp start     ;转start
exit: mov ah,4ch    ;返回
	int 21h
code ends
end start
