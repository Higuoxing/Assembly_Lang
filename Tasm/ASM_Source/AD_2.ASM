;****************************;
;*     ADת����2--ʾ����    *;
;*   �ɼ���������Ļ����ͼ   *;
;****************************;
ioport		equ 0d400h-0280h
io0809b		equ ioport+299h
code segment
	assume    cs:code
start:	mov ax,0012h          ;����Ļ��ʾ��ʽΪVGA 640X480ģʾ
	int 10h
start1:
	mov ax,0600h
	int 10h			;����
	and cx,0              ;cxΪ������
draw:	mov dx,io0809b           ;����A/Dת����ͨ��1
	out dx,al
	mov bx,500            ;��ʱ
delay:	dec bx
	jnz delay
	in al,dx              ;��������
	mov ah,0
	mov dx,368           ;dxΪ������
	sub dx,ax
	mov al,0ah            ;������ɫ
	mov ah,0ch            ;����
	int 10h
	cmp cx,639            ;һ���Ƿ���
	jz start1             ;����תstart
	inc cx                ;��������
	push dx
	mov ah,06h            ;�Ƿ��м�����
	mov dl,0ffh
	int 21h
	pop dx
	je draw               ;��,���������
	mov ax,0003           ;�лָ���ĻΪ�ַ���ʽ
	int 10h
	mov ah,4ch            ;����
	int 21h
code ends
end start