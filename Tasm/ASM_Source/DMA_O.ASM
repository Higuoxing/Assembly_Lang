;386以上微机适用
;纯dos下可以用
;tasm4.1或以上编译
;***********************;
;*       DMA实验       *;
;*     273 输出电路    *;
;***********************;
 ioport_cent    equ 0d800h		;TPC卡PCI接口芯片IO寄存器基址
 io_data        equ 080000000h		;TPC卡逻辑端输入输出基址，PCI卡扩展
 dmamode        equ 01000001000000b	;DMA通道模式字,Demand模式
 dmacount       equ 40			;传输数据长度，40字节，10双字
 dmadpr         equ 0000b		;数据传输方向，PCI->LOCAL，主机向TPC设备
 dmacsr         equ 0011b		;启动DMA传输
data SEGMENT
 out_data db    0,0,0,01h,0,0,0,02h,0,0,0,04h,0,0,0,08h,0,0,0,10h
          db    0,0,0,20h,0,0,0,40h,0,0,0,80h,0,0,0,0ffh,0,0,0,0h
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
        lea si,out_data
        lea di,ext
        cld
        mov cx,dmacount
        rep movsb		;将数据写入缓冲区

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
	mov ah,1
	int 16h
        jnz exit		;按任意键退出
        in al,dx
        and ax,10000b
        jz next3		;等待DMA传送结束

exit:
	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al
        mov ax,4c00h
        int 21h

code ENDS
	END start
