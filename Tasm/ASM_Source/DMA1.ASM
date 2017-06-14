;386以上微机适用
;纯dos下可以用
;tasm4.1或以上编译
;***********************;
;*       DMA实验       *;
;*     Demand MODE     *;
;***********************;
 ioport_cent    equ 0d800h		;TPC卡PCI接口芯片IO寄存器基址
 io_data        equ 080000000h		;TPC卡逻辑端输入输出基址，PCI卡扩展的6116
 dmamode        equ 001000000b		;DMA通道模式字,块模式
 dmamode1       equ 01000001000000b	;DMA通道模式字,Demand模式
 dmacount       equ 40h                 ;传输数据长度，40h字节，10h双字
 dmadpr         equ 0000b		;数据传输方向，PCI->LOCAL，主机向TPC设备
 dmadpr1        equ 1000b		;数据传输方向，LOCAL->PCI，TPC设备向主机
 dmacsr	        equ 0011b		;启动DMA传输
extra segment at 6000h
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

	mov dx,ioport_cent+80h
        mov eax,dmamode
	out dx,eax			;设置dma通道0
	mov dx,ioport_cent+84h
	mov eax,060000h
	mov ecx,offset in_data
	add eax,ecx
	out dx,eax			;设置PCI接口端存储器地址，微机内存的地址
	mov dx,ioport_cent+88h
	mov eax,io_data
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

next3:
	mov ah,1
	int 16h
        jnz exit		;按任意键退出
        in al,dx
        and ax,10000b
        jz next3		;等待DMA传送结束

	mov dx,ioport_cent+80h
        mov eax,dmamode1
	out dx,eax			;设置DMA通道0模式
	mov dx,ioport_cent+84h
	mov eax,060000h
	mov ecx,offset in_data1
	add eax,ecx
	out dx,eax			;设置PCI接口端存储器地址，微机内存的地址
	mov dx,ioport_cent+88h
	mov eax,io_data
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
	call dispmem
	mov ah,1
	int 16h
        jnz exit		;按任意键退出
        in  al,dx
        and ax,10000b
        jz next1		;等待DMA传送结束

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
	loop loopx1	;向源存储空间反复写256个a-z

	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,100h
        mov dl,30h
loopx4:
        mov [si],dl
        add si,1
	loop loopx4	;向目标存储空间写256个0
	ret
writemem endp

dispmem proc
	mov ax,extra
	mov ds,ax
        mov si,offset in_data1
        mov cx,40h
loopx5:
        mov dl,[si]
        mov ah,02h
        int 21h
        add si,1
        loop loopx5	;从目标存储空间读256个字节内容并显示
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h
	ret
dispmem endp

code ENDS
	END start
