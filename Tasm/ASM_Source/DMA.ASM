;386����΢������
;��dos�¿�����
;tasm4.1�����ϱ���
;***********************;
;*       DMAʵ��       *;
;*     Block MODE      *;
;***********************;
 ioport_cent    equ     0d800h          ;TPC��PCI�ӿ�оƬIO�Ĵ�����ַ
 mem_data	equ     00h		;TPC���߼��˴洢����ַ��PCI����չ��6116
 dmamode	equ	001000000b	;DMAͨ��ģʽ��
 dmacount       equ     100h            ;�������ݳ���
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
	call dispmem	;��ʾԴ��������Ŀ��������

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

	call dispmem		;��ʾԴ��������Ŀ��������

exit:
	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al
        mov ax,4c00h
        int 21h

writemem proc
	mov ax,extra
	mov ds,ax
        mov si,offset in_data
        mov cx,100h
        mov dl,40h
loopx1:
	inc dl
        mov [si],dl
        add si,1
        cmp dl,5ah
        jnz loopx2
        mov dl,40h
loopx2:
	loop loopx1	;��Դ�洢�ռ䷴��д256��a-z

	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,100h
        mov dl,30h
loopx4:
        mov [si],dl
        add si,1
	loop loopx4	;��Ŀ��洢�ռ�д256��0
	ret
writemem endp

dispmem proc
	mov ax,extra
	mov ds,ax
        mov si,offset in_data
        mov cx,100h
loopx3:
        mov dl,[si]
        mov ah,02h
        int 21h
        add si,1
        loop loopx3	;��Դ�洢�ռ��256���ֽ����ݲ���ʾ
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h

	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,100h
loopx5:
        mov dl,[si]
        mov ah,02h
        int 21h
        add si,1
        loop loopx5	;��Ŀ��洢�ռ��256���ֽ����ݲ���ʾ
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h
	ret
dispmem endp

code ENDS
END start