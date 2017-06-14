;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;*********************;
;* 中断 IRQ5/INT 0DH *;
;*********************;
data segment
 int_vect EQU 0DH      ;IRQ0-7的向量为:08h-0fh,中断8-15的向量为:70h-77h
 irq_mask_2_7 equ 011011111b    ;中断掩码,中断0-7时从低至高相应位为零,中断8-15时第2位为零
 irq_mask_9_15 equ 011111111b   ;中断0-7时全一,中断8-15时从低至高相应位为零
 ioport_cent equ 0c000h ;tpc 卡中9054芯片的卡地址
 csreg	dw	?
 ipreg	dw	?	;旧中断向量保存空间
 irq_times      db      5     ;中断计数
 msg1    db      0dh,0ah,'TPC pci card Interrupt',0dh,0ah,'$'
 msg2    db      0dh,0ah,'Press any key to exit!',0dh,0ah,'$'
 msg3    db      0dh,0ah,'Press DMC to interrupt 5 times and exit!',0dh,0ah,'$'
data ends
stacks segment
	db 100 dup (?)
stacks ends
code segment
        assume cs:code,ds:data,ss:stacks,es:data
start:
;Enable Local Interrupt Input
.386
        cli
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stacks
        mov ss,ax

        mov dx,ioport_cent+68h  ;设置 tpc 卡中9054芯片io口,使能中断
        in ax,dx
        or ax,0900h
        out dx,ax

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

        mov ax,data
        mov ds,ax
        mov dx,offset msg2
	mov ah,09h
	int 21h
        mov dx,offset msg3
	mov ah,09h
	int 21h
;        mov irq_times,5
	sti

loop1:
        cmp irq_times,0		;等待中断并判断中断10次后退出
        jz exit
	mov ah,1
	int 16h
        jnz exit		;按任意键退出
        jmp loop1

exit:   cli
        mov     bl, irq_mask_2_7        ;恢复中断掩码
	not	bl
	in	al, 21h
	or	al, bl
	out	21h, al
	mov	bl, irq_mask_9_15
	not	bl
	in	al, 0a1h
	or	al, bl
	out	0a1h, al

        mov dx,ipreg                    ;恢复原中断向量
	mov ax,csreg
	mov ds,ax
	mov ah,25h
	mov al,int_vect
        int 21h

        mov dx,ioport_cent+68h          ;设置 tpc 卡中9054芯片io口,关闭中断
	in  ax,dx
        and ax,0f7ffh
	out dx,ax

	mov ax,4c00h
	int 21h

int_proc proc far
        cli
        push ax
        push dx
        push ds
        dec irq_times
        mov ax,data             ;Interrupt to do
        mov ds,ax
	mov dx,offset msg1
	mov ah,09h
	int 21h

        mov al,20h              ;Send EOI
        out 0a0h,al
        out 20h,al
        pop ds
        pop dx
        pop ax
        sti
        iret
int_proc endp

code ends
	end start
