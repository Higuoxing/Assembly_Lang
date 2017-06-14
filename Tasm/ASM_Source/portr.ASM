;386以上微机适用
;win9x/me/dos下可以用
;tasm4.1或以上编译
;*********************;
;*     PCI端口读     *;
;*    端口读写方式   *;
;*********************;
data	segment
io_port_addre		equ 0cf8h	;32位配置地址端口
io_port_data		equ 0cfch	;32位配置数据端口
io_plx_id		equ 0540610b5h	;TPC卡设备及厂商ID
io_9054base_address     db 4 DUP(0)	;TPC卡9054芯片I/O基地址暂存空间
io_base_address         db 4 DUP(0)	;TPC卡I/O基地址暂存空间
memory_base_address     db 4 DUP(0)	;TPC卡MEMORY基地址暂存空间
interrupt_line          db 2 DUP(0)	;TPC卡中断号暂存空间
pcicardnotfind		db 0dh,0ah,'TPC pci card not find or address/interrupt error !!!',0dh,0ah,'$'
io9054baseaddress       db 0dh,0ah,'TPC pci card 9054 Chip I/O Base Address : ','$'
iobaseaddress		db 0dh,0ah,'TPC pci card I/O Base Address : ','$'
memorybaseaddress	db 0dh,0ah,'TPC pci card Memory Base Address : ','$'
intnumber		db 0dh,0ah,'TPC pci card Interrupt Line : ','$'
enter_return		db 0dh,0ah,'$'
data	ends
code segment
	assume cs:code,ds:data,es:data
start:
	mov ax,data
	mov ds,ax
	mov es,ax
.386	;386模式编译
	mov ebx,080000000h
next:
	add ebx,100h
	cmp ebx,081000000h
	jnz continue
	mov dx,offset pcicardnotfind	;显示未找到tpc卡提示信息
	mov ah,09h
	int 21h
	mov ah,4ch
	int 21h			;退出
continue:
	mov dx,io_port_addre
	mov eax,ebx
	out dx,eax		;写地址口
	mov dx,io_port_data
	in  eax,dx		;读数据口
	cmp eax,io_plx_id
	jnz  next		;检查是否发现tpc卡

	mov dx,io_port_addre
	mov eax,ebx
        add eax,14h
	out dx,eax		;写地址口
	mov dx,io_port_data
	in  eax,dx		;读数据口
	mov dword ptr io_9054base_address,eax
	and eax,1
	jz next			;检查是否为i/o基址信息
        mov eax,dword ptr io_9054base_address
	and eax,0fffffffeh
        mov dword ptr io_9054base_address,eax        ;去除i/o指示位并保存

	mov dx,io_port_addre
	mov eax,ebx
	add eax,18h
	out dx,eax		;写地址口
	mov dx,io_port_data
	in  eax,dx		;读数据口
	mov dword ptr io_base_address,eax
	and eax,1
	jz next			;检查是否为i/o基址信息
	mov eax,dword ptr io_base_address
	and eax,0fffffffeh
	mov dword ptr io_base_address,eax	;去除i/o指示位并保存

	mov dx,io_port_addre
	mov eax,ebx
	add eax,1ch
	out dx,eax		;写地址口
	mov dx,io_port_data
	in  eax,dx		;读数据口
	mov dword ptr memory_base_address,eax
	and eax,1h
	jnz next		;检查是否为memory基址信息
	mov eax,dword ptr memory_base_address
	and eax,0fffffff0h
	mov dword ptr memory_base_address,eax	;去除memory指示位并保存

	mov dx,io_port_addre
	mov eax,ebx
	add eax,3ch
	out dx,eax		;写地址口
	mov dx,io_port_data
	in  eax,dx		;读数据口
	and eax,0ffh
	mov word ptr interrupt_line,ax		;去除interrupt其它指示位并保存

        mov dx,offset io9054baseaddress		;显示i/o提示信息
	mov ah,09h
	int 21h
        mov ax,word ptr io_9054base_address
	call disp		;显示i/o基地址

	mov dx,offset iobaseaddress	;显示i/o提示信息
	mov ah,09h
	int 21h
	mov ax,word ptr io_base_address
	call disp		;显示i/o基地址

	mov dx,offset memorybaseaddress	;显示memory提示信息
	mov ah,09h
	int 21h
	mov ax,word ptr memory_base_address+2
	call disp		;显示memory基地址高16位
	mov ax,word ptr memory_base_address
	shr ax,16
	call disp		;显示memory基地址低16位

	mov dx,offset intnumber	;显示interrupt提示信息
	mov ah,09h
	int 21h
	mov ax,word ptr interrupt_line
	call disp		;显示interrupt号

	mov dx,offset enter_return	;加回车符,换行符
	mov ah,09h
	int 21h
	mov ah,4ch
	int 21h		;退出

disp proc near		;显示子程序
	push dx
	push cx
	push bx
	mov cx,4
	mov bx,16
loop1:	push ax
	push cx
	sub bx,4
	mov cx,bx
	shr ax,cl
	and al,0fh	;首先取低四位
	mov dl,al
	cmp dl,9	;判断是否<=9
	jle num		;若是则为'0'-'9',ASCII码加30H
	add dl,7	;否则为'A'-'F',ASCII码加37H
num:	add dl,30h
	mov ah,02h	;显示
	int 21h
	pop cx
	pop ax
	loop loop1
	pop bx
	pop cx
	pop dx
	ret		;子程序返回
disp endp
	code ends
	end start
