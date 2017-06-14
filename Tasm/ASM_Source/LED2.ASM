;**************************************
;*           LED�����ʵ��            *
;*           ��̬��ʾ��56��           *
;**************************************
data  segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+28ah
io8255b		equ ioport+28bh
io8255c		equ ioport+288h
led      db   3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh ;����
buffer1  db   5,6         ;���Ҫ��ʾ��ʮλ�͸�λ
bz       dw   ?           ;λ��
data ends
code  segment
	assume cs:code,ds:data
start:	mov ax,data
	mov ds,ax
	mov dx,io8255b             ;��8255��ΪA�����
	mov al,80h
	out dx,al
	mov di,offset buffer1        ;��diΪ��ʾ������
loop2:	mov bh,02
lll:    mov byte ptr bz,bh
	push di
	dec di
	add di, bz
	mov bl,[di]                  ;blΪҪ��ʾ����
	pop di
	mov bh,0
	mov si,offset led            ;��led�����ƫ�Ƶ�ַΪSI
	add si,bx                    ;�����Ӧ��led����
	mov al,byte ptr [si]
	mov dx,io8255c               ;��8255A�Ŀ����
	out dx,al
	mov al,byte ptr bz           ;ʹ��Ӧ���������
	mov dx,io8255a
	out dx,al
	mov cx,3000
delay:	loop delay                   ;��ʱ
	mov bh,byte ptr bz
	shr bh,1
	jnz lll
	mov dx,0ffh
	mov  ah,06
	int  21h
	je  loop2                   ;�м��������˳�
	mov dx,io8255a
	mov al,0                    ;�ص��������ʾ
	out dx,al
	mov ah,4ch                  ;����
	int 21h
code ends
	end start