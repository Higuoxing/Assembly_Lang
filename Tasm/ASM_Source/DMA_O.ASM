;386����΢������
;��dos�¿�����
;tasm4.1�����ϱ���
;***********************;
;*       DMAʵ��       *;
;*     273 �����·    *;
;***********************;
 ioport_cent    equ 0d800h		;TPC��PCI�ӿ�оƬIO�Ĵ�����ַ
 io_data        equ 080000000h		;TPC���߼������������ַ��PCI����չ
 dmamode        equ 01000001000000b	;DMAͨ��ģʽ��,Demandģʽ
 dmacount       equ 40			;�������ݳ��ȣ�40�ֽڣ�10˫��
 dmadpr         equ 0000b		;���ݴ��䷽��PCI->LOCAL��������TPC�豸
 dmacsr         equ 0011b		;����DMA����
data SEGMENT
 out_data db    0,0,0,01h,0,0,0,02h,0,0,0,04h,0,0,0,08h,0,0,0,10h
          db    0,0,0,20h,0,0,0,40h,0,0,0,80h,0,0,0,0ffh,0,0,0,0h
data ENDS
extra segment at 6000h
 ext db dmacount dup(?)		;���ݻ�����
extra ends
stacks segment
 db 100h dup(?)
stacks ends
code SEGMENT
        ASSUME CS:code,DS:data,SS:stacks,ES:data
start:
.386p
	mov ax,data
	mov ds,ax
        mov ax,extra
        mov es,ax
        lea si,out_data
        lea di,ext
        cld
        mov cx,dmacount
        rep movsb		;������д�뻺����

	mov dx,ioport_cent+80h
        mov eax,dmamode
	out dx,eax			;����dmaͨ��0
	mov dx,ioport_cent+84h
	mov eax,060000h
        mov ecx,offset ext
	add eax,ecx
	out dx,eax			;����PCI�ӿڶ˴洢����ַ��΢���ڴ�ĵ�ַ
	mov dx,ioport_cent+88h
	mov eax,io_data
	out dx,eax			;����local�洢����ַ��PCI����չ
	mov dx,ioport_cent+8ch
        mov eax,dmacount
	out dx,eax			;���ô������ݳ���
	mov dx,ioport_cent+90h
        mov eax,dmadpr
	out dx,eax			;���ô��䷽���
	mov dx,ioport_cent+0a8h
        mov al,dmacsr
	out dx,al			;��������

next3:
	mov ah,1
	int 16h
        jnz exit		;��������˳�
        in al,dx
        and ax,10000b
        jz next3		;�ȴ�DMA���ͽ���

exit:
	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al
        mov ax,4c00h
        int 21h

code ENDS
	END start