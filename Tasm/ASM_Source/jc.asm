;**************************
;*     集成电路测试       *
;**************************
data   segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+288h
io8255b		equ ioport+28ah
io8255c		equ ioport+28bh

se     db 00000000b    ;检测时发送的数据
       db 01010101b
       db 10101010b
       db 11111111b
ac0    db 00001111b    ;74LS00正确时检测时接收的数据
       db 00001111b
       db 00001111b
       db 00000000b
outbuf db 'THE CHIP IS OK',07h,0ah,0dh,'$'
news   db 'THE CHIP IS BAD',07h,0ah,0dh,'$'
data ends
code segment
       assume cs:code,ds:code
start: mov ax,data
       mov ds,ax
       mov dx,io8255c      ;对8255进行初始化编程
       mov al,89h       ;使A口输出,C口输入
       out dx,al
       mov di,offset ac0 ;DI中存放接收数据的缓冲区首址
       mov si,offset se  ;SI中存放发收数据的缓冲区首址
       mov cx,05h        ;发送四个字节
again: dec cx
       jz exit           ;如果四个数值都相等,则显示提示信息
       mov dx,io8255a
       mov al,[si]
       mov bl,[di]
       out dx,al         ;发送数据
       inc si
       inc di
       mov dx,io8255b
       in al,dx          ;读芯片的逻辑输出
	 and al,0fh
	 cmp al,bl
	 je again          ;若正确就继续
error: mov dx,offset news ;若有错,芯片有问题
       mov ah,09h         ;显示错误的提示信息
       int 21h
       jmp ppp
exit:  mov dx,offset outbuf;显示正确的提示信息
       mov ah,09h
       int 21h
ppp:   mov ah,4ch           ;返回
       int 21h
code   ends
       end start
