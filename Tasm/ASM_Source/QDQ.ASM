;********************************
;*     本程序为模拟抢答器       *
;********************************
data  segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+28ah
io8255b		equ ioport+28bh
io8255c		equ ioport+288h
led      db        3fh,06h,5bh,4fh,66h,6dh,7dh,07h ;数码表
data ends
code  segment
	assume cs:code,ds:data
start:mov ax,data
	mov ds,ax
	mov dx,io8255b        ;设8255为A口输出,C口输入
	mov ax,89h
	out dx,al
	mov bx,offset led  ;使BX指向段码管首址
sss:    mov dx,io8255a
	in  al,dx          ;从8255的C口输入数据
	or  al,al          ;比较是否为0
	je  sss            ;若为0,则表明无键按下，转sss
	mov cl,0ffh        ;cl作计数器,初值为-1
rr:   shr al,1
	inc cl
	jnc rr
	mov al,cl
	xlat
	mov dx,io8255c
	out dx,al
	mov dl,7           ;响铃 ASCII码为07
	mov ah,2
	int 21h
wai:  mov ah,1
	int 21h
	cmp al,20h         ;是否为空格
	jne eee            ;不是,转eee
	mov al,0           ;是,关灭灯
	mov dx,io8255c
	out dx,al
	jmp sss
eee:    mov ah,4ch         ;返回
	int 21h
code  ends
	end start
