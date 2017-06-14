;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;***********************************;
;* LED段位控制计时显示实验（中断） *;
;***********************************;
 ioport	equ 0d400h-280H
 TIM_CTL	EQU ioport+283H	;8253端口地址,控制端口
 TIMER0		EQU ioport+280H
 TIMER1		EQU ioport+281H
 MODE03		EQU 36H		;8253端口数据
 MODE12		EQU 74H
 PORTSEG	EQU ioport+2b1H	;数码管端口地址,段码地址
 PORTBIT	EQU ioport+2b0H	;数码管端口地址,位码地址
 int_vect	EQU	071H		;中断0-7的向量为:08h-0fh,中断8-15的向量为:70h-77h
 irq_mask_2_7	equ	011111011b	;中断掩码,中断0-7时从低至高相应位为零,中断8-15时第2位为零
 irq_mask_9_15	equ	011111101b	;中断0-7时全一,中断8-15时从低至高相应位为零
 ioport_cent	equ	0d800h		;tpc 卡中9054芯片的io地址
data segment
 csreg	dw	?
 ipreg	dw	?	;旧中断向量保存空间
 MESS	 DB	   '8253A TIMER0 IN MODE3! COUNT=0400H',0AH,0DH
         DB        '8253A TIMER1 IN MODE2! COUNT=0400H',0AH,0DH,'$'
 MIN1     DB        0   ;10
 MIN2     DB        0   ;1
 GAP1     DB        10
 GAP2     DB        10
 SEC1     DB        0   ;10
 SEC2     DB        0   ;1
 INTMASK  DB        ?
 LED      DB        3FH,06,5BH,4FH,66H,6DH,7DH,07,7FH,6FH,40H	;LED段码表，1,2,3,4,5,6,7,8,9,0,-
 MES      DB        'DISPLAY THE LEDS,PRESS ANY KEY TO EXIT!'
	  DB        0AH,0DH,'$'
data ends
stacks segment stack	;堆栈空间
 db 100 dup (?)
 STA      DW        512 DUP (?)
 TOP      EQU       LENGTH STA
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

	MOV  DX,TIM_CTL
	MOV  AL,MODE03
	OUT  DX,AL			;初始化计数器0
	MOV  DX,TIMER0
        MOV  AL,00H
	OUT  DX,AL
        MOV  AL,04H
	OUT  DX,AL			;设计数器初值，0400h，1024分频
	MOV  DX,TIM_CTL
	MOV  AL,MODE12
	OUT  DX,AL			;初始化计数器1
	MOV  DX,TIMER1
        MOV  AL,0H
	OUT  DX,AL
        MOV  AL,04H
	OUT  DX,AL			;设计数器初值，0400h，1024分频
	MOV  DX,OFFSET MESS
	MOV  AH,09
	INT  21H

	MOV  DX,OFFSET MES	;显示提示
	MOV  AH,09
	INT  21H

	mov  dx,ioport_cent
	add  dx,68h  ;设置 tpc 卡中9054芯片io口,使能中断
        in ax,dx
        or ax,0900h
        out dx,ax

	mov al,int_vect			;保存原中断向量
	mov ah,35h
        int 21h
	mov ax,es
	mov csreg,ax
	mov ipreg,bx

        mov al,int_vect			;设置新中断向量
        mov cx,cs
        mov ds,cx
	mov dx,offset int_proc
	mov ah,25h
        int 21h

	mov ax,data
	mov ds,ax
	mov es,ax
        in al, 21h         ;设置中断掩码
	mov ah,irq_mask_2_7
	and al,ah
        out 21h, al
        in al, 0a1h
	mov ah,irq_mask_9_15
	and al,ah
        out 0a1h, al
	sti                ;开中断

loop1:
        call disp_proc
	mov ah,1
	int 16h
        jz loop1           ;按任意键退出

exit:   cli
        mov ah,irq_mask_2_7		;恢复中断掩码
	not ah
	in al,21h
	or al,ah
	out 21h,al
	mov ah,irq_mask_9_15
	not ah
	in al,0a1h
	or al,ah
	out 0a1h,al

        mov al,int_vect		;恢复原中断向量
        mov dx,ipreg
	mov cx,csreg
	mov ds,cx
	mov ah,25h
        int 21h

	mov ax,data	;设置 tpc 卡中9054芯片io口,关闭中断
        mov ds,ax
	mov dx,ioport_cent
	add dx,68h
	in  ax,dx
        and ax,0f7ffh
	out dx,ax

	mov ax,4c00h
	int 21h		;退出

disp_proc proc near
        pusha
        push ds
	MOV AX,DATA
	MOV DS,AX
	MOV DI,OFFSET MIN1
	MOV CL,01
disp_proc_disp:
        MOV AL,[DI]
	MOV BX,OFFSET LED
	XLAT
	MOV DX,PORTSEG
	OUT DX,AL
	MOV AL,CL
	MOV DX,PORTBIT
	OUT DX,AL
	PUSH CX
        MOV CX,0A000H     ;时间延迟
disp_proc_delay:
        LOOP disp_proc_delay
	POP CX
        CMP CL,20H
        JZ disp_proc_exit
	INC DI
        SHL CL,1
	MOV AL,00
	OUT DX,AL
        JMP disp_proc_disp
disp_proc_exit:
        MOV DX,PORTBIT
	MOV AL,00
	OUT DX,AL
        pop ds
        popa
        ret
disp_proc endp

int_proc proc far	;中断调用
        cli
        pusha
	push ds		;保存寄存器值
	MOV AX,DATA
	MOV DS,AX
	INC SEC2
	CMP SEC2,10
	JL QUIT
	MOV SEC2,0
	INC SEC1
	CMP SEC1,6
	JL QUIT
        MOV SEC2,1
	MOV SEC1,0
	INC MIN2
	CMP MIN2,10
	JL QUIT
	MOV MIN2,0
	INC MIN1
	CMP MIN1,6
	JL QUIT
	MOV MIN1,0
QUIT:
	mov al,20h		;Send EOI
	out 0a0h,al
        mov cx,0ffffh
loopx1: loop loopx1             ;延时
	out 20h,al
        mov cx,0ffffh
loopx:  loop loopx              ;延时
	pop ds
        popa                    ;恢复寄存器值
	sti
	iret			;中断返回
int_proc endp
code ends
end start
