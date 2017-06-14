;386以上微机适用
;纯dos下可以用
;tasm4.1或以上编译
;***********************;
;*       DMA实验       *;
;*     244 输入电路    *;
;* 使用DMA结束产生中断 *;
;***********************;
 ioport_cent	equ 0d800h	;TPC卡PCI接口芯片IO寄存器基址
 io_data        equ 080000000h	;TPC卡逻辑端输入输出基址，PCI卡扩展
 dmamode        equ 100001010001000000b ;DMA通道模式字,Demand模式,DMA结束产生中断
 dmacount       equ 32		;传输数据长度，32字节，8双字
 dmadpr         equ 1100b	;数据传输方向，LOCAL->PCI，TPC设备向主机，DMA结束产生中断
 dmacsr         equ 0011b	;启动DMA传输
 int_vect	EQU 071H	;新的中断向量,中断0-7的向量为:08h-0fh,中断8-15的向量为:70h-77h
 irq_mask_2_7	equ 011111011b	;新的中断掩码,中断0-7时从低至高相应位为零,中断8-15时第2位为零
 irq_mask_9_15	equ 011111101b	;新的中断掩码,中断0-7时全一,中断8-15时从低至高相应位为零
data SEGMENT
 csreg		dw ?		;
 ipreg		dw ?		;旧中断向量保存空间
 irq_times      db 00h		;DMA传输结束标志位,为1时表示DMA传送结束
 msg1    db 'DMA Transfare finished! Press any key to exit!',0dh,0ah,'$'
 in_data db dmacount dup(0)
data ENDS
extra segment at 6000h
 ext db dmacount dup(?)
extra ends
stacks segment
 db 100h dup(?)
stacks ends
code SEGMENT
        ASSUME CS:code,DS:data,SS:stacks,ES:data
start:
.386p
        cli
        mov ax,stacks
        mov ss,ax
        mov ax,data
        mov ds,ax
        mov ax,extra
        mov es,ax
        lea si,in_data
        lea di,ext
        cld
        mov cx,dmacount
        rep movsb		;清空数据区

        mov irq_times,0h

        mov dx,ioport_cent+68h  ;设置TPC卡中9054芯片io口,使能DMA传输结束中断
        in eax,dx
        or eax,040100h
        out dx,eax

        mov al,int_vect         ;保存原中断向量
	mov ah,35h
        int 21h
	mov ax,es
	mov csreg,ax
	mov ipreg,bx

        mov ax,cs               ;设置新中断向量
	mov ds,ax
	mov dx,offset int_proc
	mov al,int_vect
	mov ah,25h
        int 21h

        in      al, 21h         ;设置中断掩码
        and     al, irq_mask_2_7
        out     21h, al
        in      al, 0a1h
        and     al, irq_mask_9_15
        out     0a1h, al

	mov dx,ioport_cent+80h
        mov eax,dmamode
	out dx,eax		;设置dma通道0
	mov dx,ioport_cent+84h
	mov eax,060000h
        mov ecx,offset ext
	add eax,ecx
	out dx,eax		;设置PCI接口端存储器地址，微机内存的地址
	mov dx,ioport_cent+88h
	mov eax,io_data
	out dx,eax		;设置local存储器地址，PCI卡扩展
	mov dx,ioport_cent+8ch
        mov eax,dmacount
	out dx,eax		;设置传输数据长度
	mov dx,ioport_cent+90h
        mov eax,dmadpr
	out dx,eax		;设置传输方向等
	mov dx,ioport_cent+0a8h
        mov al,dmacsr
	out dx,al		;启动传送
	sti			;开中断
next3:
	mov ax,6000h
	mov ds,ax
        mov si,offset ext
        mov cx,8
        cli
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

        mov ax,data
        mov ds,ax
        cmp irq_times,1h
        jnz next2
        mov dx,offset msg1
	mov ah,09h
        int 21h			;显示DMA传送结束信息
next2:
	mov ah,1
	int 16h
        jz next3                ;按任意键退出

exit:
	cli
	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al
	mov dx,ioport_cent+80h
        mov ebx,dmamode
        not ebx
        in  eax,dx
        and eax,ebx
        out dx,eax		;恢复dma通道0设置

        mov     bl, irq_mask_2_7	;恢复中断掩码
	not	bl
	in	al, 21h
	or	al, bl
	out	21h, al
	mov	bl, irq_mask_9_15
	not	bl
	in	al, 0a1h
	or	al, bl
	out	0a1h, al

        mov dx,ipreg		;恢复原中断向量
	mov ax,csreg
	mov ds,ax
	mov ah,25h
	mov al,int_vect
        int 21h

        mov dx,ioport_cent+68h	;设置 tpc 卡中9054芯片io口,关闭中断
	in  eax,dx
        and eax,0bfeffh
	out dx,eax

        mov ax,4c00h
        int 21h		;退出

disp proc near		;显示子程序
        cli
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
        sti
	ret              ;子程序返回
disp endp

int_proc proc far	;中断程序
        cli
        push ax
        push cx
        push dx
        push ds

	mov ax,data
        mov ds,ax
        mov irq_times,1h	;设置DMA传输结束标志位

        mov dx,ioport_cent+0a8h
        in al,dx
        mov bl,8h
        or al,bl
        out dx,al	;清除DMA结束中断标志位

        mov al,20h      ;Send EOI
        out 0a0h,al
        out 20h,al
        mov cx,0ffffh
loopx:
        nop
        loop loopx      ;延时

        pop ds
        pop dx
        pop cx
        pop ax
        sti
        iret
int_proc endp

code ENDS
	END start
