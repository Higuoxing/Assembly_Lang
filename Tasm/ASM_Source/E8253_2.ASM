;*******************
;*    8253分频     *
;*******************
ioport		equ 0d400h-0280h
io8253a		equ ioport+280h
io8253b		equ ioport+281h
io8253c		equ ioport+283h
code segment
	assume   cs:code
start:mov dx,io8253c     ;向8253写控制字
	mov al,36h       ;使0通道为工作方式3
	out dx,al
	mov ax,1000      ;写入循环计数初值1000
	mov dx,io8253a
	out dx,al        ;先写入低字节
	mov al,ah
	out dx,al        ;后写入高字节
	mov dx,io8253c
	mov al,76h       ;设8253通道1工作方式2
	out dx,al
	mov ax,1000      ;写入循环计数初值1000
	mov dx,io8253b
	out dx,al        ;先写低字节
	mov al,ah
	out dx,al        ;后写高字节
	mov ah,4ch       ;程序退出
	int 21h
  code ends
	end start
