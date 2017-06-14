;386以上微机适用
;win9x/me/dos下可以用
;tasm611或以上编译
;***********************;
;*      PCI端口读      *;
;* PCI BIOS INT 方式读 *;
;***********************;
data	segment
io_plx_device_id	equ 05406h	;TPC卡设备ID
io_plx_vendor_id	equ 010b5h	;TPC卡厂商ID
IO_PLX_SUB_ID		EQU 0905410B5H	;TPC卡子设备及厂商ID
io_9054base_address	db 4 DUP(0)	;TPC卡9054芯片I/O基地址暂存空间
io_base_address		db 4 DUP(0)	;TPC卡I/O基地址暂存空间
memory_base_address	db 4 DUP(0)	;TPC卡MEMORY基地址暂存空间
interrupt_line		db 2 DUP(0)	;TPC卡中断号暂存空间
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
.386	;386模式编译
	mov	ax,data
	mov	ds,ax
	mov	es,ax
	mov	ax,stacks
	mov	ss,ax
	call	findtpc		;查找TPC卡资源并显示
	mov	ax,4c00h
	int	21h		;退出

findtpc proc near		;查找TPC卡资源并显示
	pushad
	pushfd
	MOV	AX,0B101H
	INT	1AH
	JC	findtpc_notfind		;检查PCI BIOS是否存在

	MOV	AX,0B102H
	MOV	CX,io_plx_device_id
	MOV	DX,io_plx_vendor_id
	MOV	SI,0
	INT	1AH
	JC	findtpc_notfind		;检查TPC卡是否安装,设备号、厂商号

	MOV	AX,0B10AH
	MOV	DI,02CH
	INT	1AH
	JC	findtpc_notfind
	CMP	ECX,IO_PLX_SUB_ID
	JNZ	findtpc_notfind		;检查TPC卡是否安装,子设备号、厂商号

	MOV	AX,0B10AH
	MOV	DI,14H
	INT	1AH
	JC	findtpc_notfind		;读TPC卡9054芯片I/O基址信息
	mov	dword ptr io_9054base_address,ecx
	and	ecx,1
	jz	findtpc_notfind		;检查是否为i/o基址信息
        mov	ecx,dword ptr io_9054base_address
	and	ecx,0fffffffeh
        mov	dword ptr io_9054base_address,ecx  ;去除i/o指示位并保存

	MOV	AX,0B10AH
	MOV	DI,18H
	INT	1AH
	JC	findtpc_notfind		;读TPC卡I/O基址信息
	mov	dword ptr io_base_address,ecx
	and	ecx,1
	jz	findtpc_notfind		;检查是否为i/o基址信息
	mov	ecx,dword ptr io_base_address
	and	ecx,0fffffffeh
	mov	dword ptr io_base_address,ecx	;去除i/o指示位并保存

	MOV	AX,0B10AH
	MOV	DI,1CH
	INT	1AH
	JC	findtpc_notfind		;读TPC卡MEMORY基址信息
	mov	dword ptr memory_base_address,ecx
	and	ecx,1h
	jnz	findtpc_notfind		;检查是否为memory基址信息
	mov	ecx,dword ptr memory_base_address
	and	ecx,0fffffff0h
	mov	dword ptr memory_base_address,ecx	;去除memory指示位并保存

	MOV	AX,0B10AH
	MOV	DI,3CH
	INT	1AH
	JC	findtpc_notfind		;读TPC卡中断信息
	and	cx,0ffh
	mov	word ptr interrupt_line,cx	;去除interrupt其它指示位并保存

        mov	dx,offset io9054baseaddress	;显示i/o提示信息
	mov	ah,09h
	int	21h
        mov	ax,word ptr io_9054base_address
	call	dispword			;显示i/o基地址

	mov	dx,offset iobaseaddress		;显示i/o提示信息
	mov	ah,09h
	int	21h
	mov	ax,word ptr io_base_address
	call	dispword			;显示i/o基地址

	mov	dx,offset memorybaseaddress	;显示memory提示信息
	mov	ah,09h
	int	21h
	mov	ax,word ptr memory_base_address+2
	call	dispword			;显示memory基地址高16位
	mov	ax,word ptr memory_base_address
	shr	ax,16
	call	dispword			;显示memory基地址低16位

	mov	dx,offset intnumber		;显示interrupt提示信息
	mov	ah,09h
	int	21h
	mov	ax,word ptr interrupt_line
	call	dispword			;显示中断号

	mov	dx,offset enter_return		;加回车符,换行符
	mov	ah,09h
	int	21h
	popfd
	popad
	ret
findtpc_notfind:
	mov dx,offset pcicardnotfind		;显示未找到tpc卡提示信息
	mov ah,09h
	int 21h
	mov ax,4c00h
	int 21h		;退出
findtpc endp

dispword proc near		;显示子程序
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
	and al,0fh	;首先取低四位
	mov dl,al
	cmp dl,9	;判断是否<=9
	jle dispword_num		;若是则为'0'-'9',ASCII码加30H
	add dl,7	;否则为'A'-'F',ASCII码加37H
dispword_num:
	add dl,30h
	mov ah,02h	;显示
	int 21h
	pop cx
	pop ax
	loop dispword_loop1
	pop bx
	pop cx
	pop dx
	ret		;子程序返回
dispword endp
code ends
end start
