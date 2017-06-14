;**************************
;*     ���ɵ�·����       *
;**************************
data   segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+288h
io8255b		equ ioport+28ah
io8255c		equ ioport+28bh

se     db 00000000b    ;���ʱ���͵�����
       db 01010101b
       db 10101010b
       db 11111111b
ac0    db 00001111b    ;74LS00��ȷʱ���ʱ���յ�����
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
       mov dx,io8255c      ;��8255���г�ʼ�����
       mov al,89h       ;ʹA�����,C������
       out dx,al
       mov di,offset ac0 ;DI�д�Ž������ݵĻ�������ַ
       mov si,offset se  ;SI�д�ŷ������ݵĻ�������ַ
       mov cx,05h        ;�����ĸ��ֽ�
again: dec cx
       jz exit           ;����ĸ���ֵ�����,����ʾ��ʾ��Ϣ
       mov dx,io8255a
       mov al,[si]
       mov bl,[di]
       out dx,al         ;��������
       inc si
       inc di
       mov dx,io8255b
       in al,dx          ;��оƬ���߼����
	 and al,0fh
	 cmp al,bl
	 je again          ;����ȷ�ͼ���
error: mov dx,offset news ;���д�,оƬ������
       mov ah,09h         ;��ʾ�������ʾ��Ϣ
       int 21h
       jmp ppp
exit:  mov dx,offset outbuf;��ʾ��ȷ����ʾ��Ϣ
       mov ah,09h
       int 21h
ppp:   mov ah,4ch           ;����
       int 21h
code   ends
       end start
