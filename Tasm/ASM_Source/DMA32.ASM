;386����΢������
;��dos�¿�����
;tasm4.1�����ϱ���
;***********************;
;*    32λDMAʵ��      *;
;*     Block MODE      *;
;***********************;
 ioport_cent	equ     0d800h		;TPC��PCI�ӿ�оƬIO�Ĵ�����ַ
 mem_data	equ     00h		;TPC���߼��˴洢����ַ��PCI����չ��6116
 dmamode	equ	001000011b	;DMAͨ��ģʽ��,32λ���ݴ���
 dmacount	equ	100h		;�������ݳ���
 dmadpr		equ	0000b		;���ݴ��䷽��PCI->LOCAL��������TPC�豸
 dmadpr1	equ	1000b		;���ݴ��䷽��LOCAL->PCI��TPC�豸������
 dmacsr		equ	0011b		;����DMA����
extra segment at 6000h	;����������
 in_data	db 0400h dup (?)	;Դ������
 in_data1	db 0400h dup (?)	;Ŀ��������
extra ends
stacks segment
 db 100h dup(?)
stacks ends
code SEGMENT
 ASSUME CS:code,DS:stacks,SS:stacks,ES:stacks
start:
.386p

	call writemem	;дԴ�����������Ŀ��������
	call dispmem	;��ʾԴ��������Ŀ��������������

	mov dx,ioport_cent+80h
	mov eax,dmamode
	out dx,eax			;����DMAͨ��0ģʽ
	mov dx,ioport_cent+84h
	mov eax,060000h
	mov ecx,offset in_data
	add eax,ecx
	out dx,eax			;����PCI�ӿڶ˴洢����ַ��΢���ڴ�ĵ�ַ
	mov dx,ioport_cent+88h
	mov eax,mem_data
	out dx,eax			;����local�洢����ַ��PCI����չ��6116
	mov dx,ioport_cent+8ch
	mov eax,dmacount
	out dx,eax			;���ô������ݳ���
	mov dx,ioport_cent+90h
	mov eax,dmadpr
	out dx,eax			;���ô��䷽���
	mov dx,ioport_cent+0a8h
	mov al,dmacsr
	out dx,al			;��������
next:
	mov ah,1
	int 16h
        jnz exit		;��������˳�
        in  al,dx
        and ax,10000b
        jz next			;�ȴ�DMA���ͽ���

	mov dx,ioport_cent+80h
	mov eax,dmamode
	out dx,eax			;����DMAͨ��0ģʽ
	mov dx,ioport_cent+84h
	mov eax,060000h
	mov ecx,offset in_data1
	add eax,ecx
	out dx,eax			;����PCI�ӿڶ˴洢����ַ��΢���ڴ�ĵ�ַ
	mov dx,ioport_cent+88h
	mov eax,mem_data
	out dx,eax			;����local�洢����ַ��PCI����չ��6116
	mov dx,ioport_cent+8ch
	mov eax,dmacount
	out dx,eax			;���ô������ݳ���
	mov dx,ioport_cent+90h
	mov eax,dmadpr1
	out dx,eax			;���ô��䷽���
	mov dx,ioport_cent+0a8h
	mov al,dmacsr
	out dx,al			;��������
next1:
	mov ah,1
	int 16h
        jnz exit		;��������˳�
        in  al,dx
        and ax,10000b
        jz next1		;�ȴ�DMA���ͽ���

	call dispmem		;��ʾ���ͽ������Դ��������Ŀ������������

exit:
	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al		;�ر�DMA���͹���
        mov ax,4c00h
        int 21h			;�˳�

writemem proc
	pushad
	pushfd
	mov ax,extra
	mov ds,ax
        mov si,offset in_data
        mov cx,0100h
        mov edx,0F0h	;32λ������ʼֵ
loopx1:
        mov dword ptr [si],edx
	ADD edx,10H	;��������
        add si,4	;��ַ����
	loop loopx1	;��Դ�洢�ռ�д32λ��������

	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,0FFh
        mov edx,0h
loopx4:
        mov dword ptr [si],edx
        add si,4
	loop loopx4	;��Ŀ��洢�ռ�д0,���
	popfd
	popad
	ret
writemem endp

dispmem proc
	pushad
	pushfd
	mov ax,extra
	mov ds,ax
        mov si,offset in_data
        mov cx,028h		;������ʾ���ݳ���
loopx3:
        mov ax,word ptr [si]+2
	call dispword		;��ʾ��16λ����
	mov ax,word ptr [si]
	call dispword		;��ʾ��16λ����
        add si,4		;��ַ����
        mov ah,02h
	mov dl,20h
	int 21h		;�������ݼ����ո�
        loop loopx3	;��Դ�洢�ռ��32λ�������ݲ���ʾ
        mov ah,02h
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h		;��ʾ�س�������

	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,28h		;������ʾ���ݳ���
loopx5:
        mov ax,word ptr [si]+2
	call dispword		;��ʾ��16λ����
	mov ax,word ptr [si]
	call dispword		;��ʾ��16λ����
        add si,4		;��ַ����
        mov ah,02h
	mov dl,20h
	int 21h		;�������ݼ����ո�
        loop loopx5	;��Ŀ��洢�ռ��32λ�������ݲ���ʾ
        mov ah,02h
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h		;��ʾ�س�������
	popfd
	popad
	ret
dispmem endp

dispword proc near		;��ʾ�ӳ���
	push dx
	push cx
	push bx
	mov cx,4
	mov bx,16
dispword_loop1:
	push ax
	push cx
	sub bx,4
	mov cx,bx
	shr ax,cl
	and al,0fh	;����ȡ����λ
	mov dl,al
	cmp dl,9	;�ж��Ƿ�<=9
	jle dispword_num		;������Ϊ'0'-'9',ASCII���30H
	add dl,7	;����Ϊ'A'-'F',ASCII���37H
dispword_num:
	add dl,30h
	mov ah,02h	;��ʾ
	int 21h
	pop cx
	pop ax
	loop dispword_loop1
	pop bx
	pop cx
	pop dx
	ret		;�ӳ��򷵻�
dispword endp
code ENDS
END start