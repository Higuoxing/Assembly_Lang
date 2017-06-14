;386以上微机适用
;纯dos下可以用
;tasm4.1或以上编译
;***********************;
;*    32位DMA实验      *;
;*     Block MODE      *;
;***********************;
 ioport_cent	equ     0d800h		;TPC卡PCI接口芯片IO寄存器基址
 mem_data	equ     00h		;TPC卡逻辑端存储器基址，PCI卡扩展的6116
 dmamode	equ	001000011b	;DMA通道模式字,32位数据传输
 dmacount	equ	100h		;传输数据长度
 dmadpr		equ	0000b		;数据传输方向，PCI->LOCAL，主机向TPC设备
 dmadpr1	equ	1000b		;数据传输方向，LOCAL->PCI，TPC设备向主机
 dmacsr		equ	0011b		;启动DMA传输
extra segment at 6000h	;主机缓冲区
 in_data	db 0400h dup (?)	;源数据区
 in_data1	db 0400h dup (?)	;目的数据区
extra ends
stacks segment
 db 100h dup(?)
stacks ends
code SEGMENT
 ASSUME CS:code,DS:stacks,SS:stacks,ES:stacks
start:
.386p

	call writemem	;写源数据区，清空目的数据区
	call dispmem	;显示源数据区，目的数据区的内容

	mov dx,ioport_cent+80h
	mov eax,dmamode
	out dx,eax			;设置DMA通道0模式
	mov dx,ioport_cent+84h
	mov eax,060000h
	mov ecx,offset in_data
	add eax,ecx
	out dx,eax			;设置PCI接口端存储器地址，微机内存的地址
	mov dx,ioport_cent+88h
	mov eax,mem_data
	out dx,eax			;设置local存储器地址，PCI卡扩展的6116
	mov dx,ioport_cent+8ch
	mov eax,dmacount
	out dx,eax			;设置传输数据长度
	mov dx,ioport_cent+90h
	mov eax,dmadpr
	out dx,eax			;设置传输方向等
	mov dx,ioport_cent+0a8h
	mov al,dmacsr
	out dx,al			;启动传送
next:
	mov ah,1
	int 16h
        jnz exit		;按任意键退出
        in  al,dx
        and ax,10000b
        jz next			;等待DMA传送结束

	mov dx,ioport_cent+80h
	mov eax,dmamode
	out dx,eax			;设置DMA通道0模式
	mov dx,ioport_cent+84h
	mov eax,060000h
	mov ecx,offset in_data1
	add eax,ecx
	out dx,eax			;设置PCI接口端存储器地址，微机内存的地址
	mov dx,ioport_cent+88h
	mov eax,mem_data
	out dx,eax			;设置local存储器地址，PCI卡扩展的6116
	mov dx,ioport_cent+8ch
	mov eax,dmacount
	out dx,eax			;设置传输数据长度
	mov dx,ioport_cent+90h
	mov eax,dmadpr1
	out dx,eax			;设置传输方向等
	mov dx,ioport_cent+0a8h
	mov al,dmacsr
	out dx,al			;启动传送
next1:
	mov ah,1
	int 16h
        jnz exit		;按任意键退出
        in  al,dx
        and ax,10000b
        jz next1		;等待DMA传送结束

	call dispmem		;显示传送结束后的源数据区，目的数据区内容

exit:
	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al		;关闭DMA传送功能
        mov ax,4c00h
        int 21h			;退出

writemem proc
	pushad
	pushfd
	mov ax,extra
	mov ds,ax
        mov si,offset in_data
        mov cx,0100h
        mov edx,0F0h	;32位数据起始值
loopx1:
        mov dword ptr [si],edx
	ADD edx,10H	;数据自增
        add si,4	;地址自增
	loop loopx1	;向源存储空间写32位自增数据

	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,0FFh
        mov edx,0h
loopx4:
        mov dword ptr [si],edx
        add si,4
	loop loopx4	;向目标存储空间写0,清空
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
        mov cx,028h		;设置显示数据长度
loopx3:
        mov ax,word ptr [si]+2
	call dispword		;显示高16位数据
	mov ax,word ptr [si]
	call dispword		;显示低16位数据
        add si,4		;地址自增
        mov ah,02h
	mov dl,20h
	int 21h		;两个数据间插入空格
        loop loopx3	;从源存储空间读32位数据内容并显示
        mov ah,02h
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h		;显示回车、换行

	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,28h		;设置显示数据长度
loopx5:
        mov ax,word ptr [si]+2
	call dispword		;显示高16位数据
	mov ax,word ptr [si]
	call dispword		;显示低16位数据
        add si,4		;地址自增
        mov ah,02h
	mov dl,20h
	int 21h		;两个数据间插入空格
        loop loopx5	;从目标存储空间读32位数据内容并显示
        mov ah,02h
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h		;显示回车、换行
	popfd
	popad
	ret
dispmem endp

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
code ENDS
END start
