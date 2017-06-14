;*******************
;*     ������      *
;*******************
data segment
ioport		equ 0d400h-0280h
io8253a		equ ioport+280h
io8253b		equ ioport+283h
io8255a		equ ioport+288h
io8255b		equ ioport+28bh
io0832a		equ ioport+290h
data1  db 80h,96h,0aeh,0c5h,0d8h,0e9h,0f5h,0fdh
       db 0ffh,0fdh,0f5h,0e9h,0d8h,0c5h,0aeh,96h
       db 80h,66h,4eh,38h,25h,15h,09h,04h
       db 00h,04h,09h,15h,25h,38h,4eh,66h	;���Ҳ�����
time   db 120,106,94,89,79,70,63,59	;����ͬ��ʱ8253�ļ�������ֵ
msg    db 'Press 1,2,3,4,5,6,7,8,ESC:',0dh,0ah,'$'
num    db ?	;numΪ8253��������ֵ�����
data ends
code segment
    assume cs:code,ds:data
start:  mov ax,data
	mov ds,ax
	mov dx,offset msg
	mov ah,9
	int 21h              ;��ʾ��ʾ��Ϣ
sss:    mov ah,7
	int 21h              ;�Ӽ��̽����ַ�,������
	cmp al,1bh
	je  exit             ;��ΪESC��,��תEXIT
	cmp al,31h
	jl  sss
	cmp al,38h
	jg  sss              ;������'1'-'8'֮��תsss
	sub al,31h
	mov num,al           ;�����Ӧ��ʱ�䳣�������
	mov cx,60             ;ȡ60��32�����Ҳ�����
ddd:	mov si,0
lll:	mov al,data1[si]     ;ȡ���Ҳ�����
	mov dx,io0832a
	out dx,al            ;����
	call delay           ;����ʱ�ӳ���
	inc si
	cmp si,32            ;�Ƿ�ȡ��32������
	jl lll               ;��û��,�����
	loop ddd             ;��ѭ������60�Ƿ���,û��,�����
	jmp sss
exit:   mov ah,4ch
	int 21h
delay proc near              ;��ʱ�ӳ���
ccc:    mov bx,offset time
	mov dx,io8253b       ;��8253ͨ��0Ϊ��ʽ0����
	mov al,10h
	out dx,al
	mov dx,io8255b       ;��8255A������
	mov al,9bh
	out dx,al
	mov al,num           ;ȡ��Ӧ��ʱ�䳣��
	xlat
	mov dx,io8253a
	out dx,al            ;��8253ͨ��0���
kkk:	mov dx,io8255a
	in  al,dx            ;��8255A�ڶ�һ�ֽ�
	test al,01           ;��PA0���Ƿ�Ϊ1
	jz  kkk              ;����Ϊ1,��תKKK
	ret                  ;�ӳ��򷵻�
delay  endp
code   ends
	end  start