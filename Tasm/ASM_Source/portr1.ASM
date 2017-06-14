;386����΢������
;win9x/me/dos�¿�����
;tasm611�����ϱ���
;***********************;
;*      PCI�˿ڶ�      *;
;* PCI BIOS INT ��ʽ�� *;
;***********************;
data	segment
io_plx_device_id	equ 05406h	;TPC���豸ID
io_plx_vendor_id	equ 010b5h	;TPC������ID
IO_PLX_SUB_ID		EQU 0905410B5H	;TPC�����豸������ID
io_9054base_address	db 4 DUP(0)	;TPC��9054оƬI/O����ַ�ݴ�ռ�
io_base_address		db 4 DUP(0)	;TPC��I/O����ַ�ݴ�ռ�
memory_base_address	db 4 DUP(0)	;TPC��MEMORY����ַ�ݴ�ռ�
interrupt_line		db 2 DUP(0)	;TPC���жϺ��ݴ�ռ�
pcicardnotfind		db 0dh,0ah,'TPC pci card not find or address/interrupt error !!!',0dh,0ah,'$'
io9054baseaddress	db 0dh,0ah,'TPC pci card 9054 Chip I/O Base Address : ','$'
iobaseaddress		db 0dh,0ah,'TPC pci card I/O Base Address : ','$'
memorybaseaddress	db 0dh,0ah,'TPC pci card Memory Base Address : ','$'
intnumber		db 0dh,0ah,'TPC pci card Interrupt Line : ','$'
enter_return		db 0dh,0ah,'$'
data	ends
stacks segment
 db 100 dup(?)
stacks ends
code segment
	assume cs:code,ds:data,es:data,ss:stacks
start:
.386	;386ģʽ����
	mov	ax,data
	mov	ds,ax
	mov	es,ax
	mov	ax,stacks
	mov	ss,ax
	call	findtpc		;����TPC����Դ����ʾ
	mov	ax,4c00h
	int	21h		;�˳�

findtpc proc near		;����TPC����Դ����ʾ
	pushad
	pushfd
	MOV	AX,0B101H
	INT	1AH
	JC	findtpc_notfind		;���PCI BIOS�Ƿ����

	MOV	AX,0B102H
	MOV	CX,io_plx_device_id
	MOV	DX,io_plx_vendor_id
	MOV	SI,0
	INT	1AH
	JC	findtpc_notfind		;���TPC���Ƿ�װ,�豸�š����̺�

	MOV	AX,0B10AH
	MOV	DI,02CH
	INT	1AH
	JC	findtpc_notfind
	CMP	ECX,IO_PLX_SUB_ID
	JNZ	findtpc_notfind		;���TPC���Ƿ�װ,���豸�š����̺�

	MOV	AX,0B10AH
	MOV	DI,14H
	INT	1AH
	JC	findtpc_notfind		;��TPC��9054оƬI/O��ַ��Ϣ
	mov	dword ptr io_9054base_address,ecx
	and	ecx,1
	jz	findtpc_notfind		;����Ƿ�Ϊi/o��ַ��Ϣ
        mov	ecx,dword ptr io_9054base_address
	and	ecx,0fffffffeh
        mov	dword ptr io_9054base_address,ecx  ;ȥ��i/oָʾλ������

	MOV	AX,0B10AH
	MOV	DI,18H
	INT	1AH
	JC	findtpc_notfind		;��TPC��I/O��ַ��Ϣ
	mov	dword ptr io_base_address,ecx
	and	ecx,1
	jz	findtpc_notfind		;����Ƿ�Ϊi/o��ַ��Ϣ
	mov	ecx,dword ptr io_base_address
	and	ecx,0fffffffeh
	mov	dword ptr io_base_address,ecx	;ȥ��i/oָʾλ������

	MOV	AX,0B10AH
	MOV	DI,1CH
	INT	1AH
	JC	findtpc_notfind		;��TPC��MEMORY��ַ��Ϣ
	mov	dword ptr memory_base_address,ecx
	and	ecx,1h
	jnz	findtpc_notfind		;����Ƿ�Ϊmemory��ַ��Ϣ
	mov	ecx,dword ptr memory_base_address
	and	ecx,0fffffff0h
	mov	dword ptr memory_base_address,ecx	;ȥ��memoryָʾλ������

	MOV	AX,0B10AH
	MOV	DI,3CH
	INT	1AH
	JC	findtpc_notfind		;��TPC���ж���Ϣ
	and	cx,0ffh
	mov	word ptr interrupt_line,cx	;ȥ��interrupt����ָʾλ������

        mov	dx,offset io9054baseaddress	;��ʾi/o��ʾ��Ϣ
	mov	ah,09h
	int	21h
        mov	ax,word ptr io_9054base_address
	call	dispword			;��ʾi/o����ַ

	mov	dx,offset iobaseaddress		;��ʾi/o��ʾ��Ϣ
	mov	ah,09h
	int	21h
	mov	ax,word ptr io_base_address
	call	dispword			;��ʾi/o����ַ

	mov	dx,offset memorybaseaddress	;��ʾmemory��ʾ��Ϣ
	mov	ah,09h
	int	21h
	mov	ax,word ptr memory_base_address+2
	call	dispword			;��ʾmemory����ַ��16λ
	mov	ax,word ptr memory_base_address
	shr	ax,16
	call	dispword			;��ʾmemory����ַ��16λ

	mov	dx,offset intnumber		;��ʾinterrupt��ʾ��Ϣ
	mov	ah,09h
	int	21h
	mov	ax,word ptr interrupt_line
	call	dispword			;��ʾ�жϺ�

	mov	dx,offset enter_return		;�ӻس���,���з�
	mov	ah,09h
	int	21h
	popfd
	popad
	ret
findtpc_notfind:
	mov dx,offset pcicardnotfind		;��ʾδ�ҵ�tpc����ʾ��Ϣ
	mov ah,09h
	int 21h
	mov ax,4c00h
	int 21h		;�˳�
findtpc endp

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
code ends
end start