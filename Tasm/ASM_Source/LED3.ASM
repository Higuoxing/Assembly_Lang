;**************************************
;*           LED数码管实验            *
;*       动态循环显示“00-99”        *
;**************************************
data  segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+28ah
io8255b		equ ioport+28bh
io8255c		equ ioport+288h
led      db   3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh ;段码
buffer1  db   0,0         ;存放要显示的十位和个位
bz       dw   ?           ;位码
data ends
code  segment
	assume cs:code,ds:data
start:	mov ax,data
	mov ds,ax
	mov dx,io8255b            ;将8255设为A口输出
	mov al,80h
	out dx,al
	mov di,offset buffer1      ;设di为显示缓冲区
loop1:	mov cx,0300h               ;循环次数
loop2:	mov bh,02
lll:	mov byte ptr bz,bh
	push di
	dec di
	add di, bz
	mov bl,[di]                  ;bl为要显示的数
	pop di
	mov bh,0
	mov si,offset led            ;置led数码表偏移地址为SI
	add si,bx                    ;求出对应的led数码
	mov al,byte ptr [si]
	mov dx,io8255c               ;自8255A的口输出
	out dx,al
	mov al,byte ptr bz           ;使相应的数码管亮
	mov dx,io8255a
	out dx,al
	push cx
	mov cx,3000
delay:	loop delay                  ;延时
	pop cx
	mov bh,byte ptr bz
	shr bh,1
	jnz lll
	loop loop2                  ;循环延时
	mov  ax,word ptr [di]
	cmp  ah,09
	jnz  set
	cmp  al,09
	jnz  set
	mov  ax,0000
	mov  [di],al
	mov  [di+1],ah
	jmp  loop1
set:	mov  ah,01
	int  16h
	jne  exit                   ;有键按下则转exit
	mov  ax,word ptr [di]
	inc  al
	aaa
	mov [di],al                 ;al为十位
	mov [di+1],ah               ;ah中为个位
	jmp loop1
exit:	mov dx,io8255a
	mov al,0                    ;关掉数码管显示
	out dx,al
	mov ah,4ch                  ;返回
	int 21h
code ends
	end start
