;********************************;
;*    �򵥲�������ʵ��          *;
;********************************;
ioport		equ 0d400h-0280h
ls244		equ ioport+2a0h
code segment
	assume cs:code
start:mov dx,ls244        ;��2A0����һ����
	in al,dx
	mov dl,al          ;���������ݱ�����DL��
	mov ah,02
	int 21h
	mov dl,0dh         ;��ʾ�س���
	int 21h
	mov dl,0ah         ;��ʾ���з�
	int 21h
	mov ah,06           ;�Ƿ��м�����
	mov dl,0ffh
	int 21h
	jnz exit
	je start           ;����,��תstart
exit: mov ah,4ch         ;����
	int 21h
code  ends
end start