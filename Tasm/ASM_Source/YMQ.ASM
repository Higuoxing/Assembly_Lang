;*******************************;
;*        I/O地址译码          *;
;*******************************;
ioport		equ 0d400h-0280h
outport1	equ ioport+2a0h
outport2	equ ioport+2a8h
code segment
	 assume cs:code
start:
	mov dx,outport1
	out dx,al
	call delay        ;调延时子程序
	mov dx,outport2
	out dx,al
	call delay        ;调延时子程序
	mov ah,1
	int 16h
	je start
	mov ah,4ch
	int 21h
delay proc near                   ;延时子程序
	mov bx,2000
lll:    mov cx,0
ll:     loop ll
	dec bx
	jne lll
	ret
delay endp
code ends
end start
