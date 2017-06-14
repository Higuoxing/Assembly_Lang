;386以上微机适用
;纯dos下可以用
;tasm4.1或以上编译
;***********************;
;*       DMA实验       *;
;*     244 输入电路    *;
;***********************;
 ioport_cent    equ 0d800h		;TPC卡PCI接口芯片IO寄存器基址
 io_data        equ 080000000h          ;TPC卡逻辑端输入输出基址，PCI卡扩展
 dmamode        equ 01000001000000b     ;DMA通道模式字,Demand模式
 dmacount       equ 32			;传输数据长度，32字节，8双字
 dmadpr         equ 1000b               ;数据传输方向，LOCAL->PCI，TPC设备向主机
 dmacsr         equ 0011b		;启动DMA传输
data SEGMENT
 in_data db      dmacount dup(0)
data ENDS
extra segment at 6000h
 ext db dmacount dup(?)		;数据缓冲区
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
        lea si,in_data
        lea di,ext
        cld
        mov cx,dmacount
        rep movsb		;清空数据区

	mov dx,ioport_cent+80h
        mov eax,dmamode
	out dx,eax			;设置dma通道0
	mov dx,ioport_cent+84h
	mov eax,060000h
        mov ecx,offset ext
	add eax,ecx
	out dx,eax			;设置PCI接口端存储器地址，微机内存的地址
	mov dx,ioport_cent+88h
	mov eax,io_data
	out dx,eax			;设置local存储器地址，PCI卡扩展
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
	mov ax,6000h
	mov ds,ax
        mov si,offset ext
        mov cx,8
loop3:
        mov ax,[si+2]
        call disp
        mov ax,[si]
	call disp
        add si,4
	mov ah,02h
	mov dl,20h
	int 21h
        loop loop3		;从数据区读8个双字内容并显示
	mov ah,02h
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h			;显示回车、换行

        mov ah,1
	int 16h
        jz next3                ;按任意键退出

	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al
        mov ax,4c00h
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
	and al,0fh       ;首先取低四位
	mov dl,al
	cmp dl,9         ;判断是否<=9
	jle num          ;若是则为'0'-'9',ASCII码加30H
	add dl,7         ;否则为'A'-'F',ASCII码加37H
num:	add dl,30h
	mov ah,02h       ;显示
	int 21h
	pop cx
	pop ax
	loop loop1
	pop bx
	pop cx
	pop dx
	ret              ;子程序返回
disp endp

code ENDS
	END start
