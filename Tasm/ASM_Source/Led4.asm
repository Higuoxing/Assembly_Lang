;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;***********************************;
;* LED��λ���Ƽ�ʱ��ʾʵ�飨�жϣ� *;
;***********************************;
 ioport	equ 0d400h-280H
 TIM_CTL	EQU ioport+283H	;8253�˿ڵ�ַ,���ƶ˿�
 TIMER0		EQU ioport+280H
 TIMER1		EQU ioport+281H
 MODE03		EQU 36H		;8253�˿�����
 MODE12		EQU 74H
 PORTSEG	EQU ioport+2b1H	;����ܶ˿ڵ�ַ,�����ַ
 PORTBIT	EQU ioport+2b0H	;����ܶ˿ڵ�ַ,λ���ַ
 int_vect	EQU	071H		;�ж�0-7������Ϊ:08h-0fh,�ж�8-15������Ϊ:70h-77h
 irq_mask_2_7	equ	011111011b	;�ж�����,�ж�0-7ʱ�ӵ�������ӦλΪ��,�ж�8-15ʱ��2λΪ��
 irq_mask_9_15	equ	011111101b	;�ж�0-7ʱȫһ,�ж�8-15ʱ�ӵ�������ӦλΪ��
 ioport_cent	equ	0d800h		;tpc ����9054оƬ��io��ַ
data segment
 csreg	dw	?
 ipreg	dw	?	;���ж���������ռ�
 MESS	 DB	   '8253A TIMER0 IN MODE3! COUNT=0400H',0AH,0DH
         DB        '8253A TIMER1 IN MODE2! COUNT=0400H',0AH,0DH,'$'
 MIN1     DB        0   ;10
 MIN2     DB        0   ;1
 GAP1     DB        10
 GAP2     DB        10
 SEC1     DB        0   ;10
 SEC2     DB        0   ;1
 INTMASK  DB        ?
 LED      DB        3FH,06,5BH,4FH,66H,6DH,7DH,07,7FH,6FH,40H	;LED�����1,2,3,4,5,6,7,8,9,0,-
 MES      DB        'DISPLAY THE LEDS,PRESS ANY KEY TO EXIT!'
	  DB        0AH,0DH,'$'
data ends
stacks segment stack	;��ջ�ռ�
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
	OUT  DX,AL			;��ʼ��������0
	MOV  DX,TIMER0
        MOV  AL,00H
	OUT  DX,AL
        MOV  AL,04H
	OUT  DX,AL			;���������ֵ��0400h��1024��Ƶ
	MOV  DX,TIM_CTL
	MOV  AL,MODE12
	OUT  DX,AL			;��ʼ��������1
	MOV  DX,TIMER1
        MOV  AL,0H
	OUT  DX,AL
        MOV  AL,04H
	OUT  DX,AL			;���������ֵ��0400h��1024��Ƶ
	MOV  DX,OFFSET MESS
	MOV  AH,09
	INT  21H

	MOV  DX,OFFSET MES	;��ʾ��ʾ
	MOV  AH,09
	INT  21H

	mov  dx,ioport_cent
	add  dx,68h  ;���� tpc ����9054оƬio��,ʹ���ж�
        in ax,dx
        or ax,0900h
        out dx,ax

	mov al,int_vect			;����ԭ�ж�����
	mov ah,35h
        int 21h
	mov ax,es
	mov csreg,ax
	mov ipreg,bx

        mov al,int_vect			;�������ж�����
        mov cx,cs
        mov ds,cx
	mov dx,offset int_proc
	mov ah,25h
        int 21h

	mov ax,data
	mov ds,ax
	mov es,ax
        in al, 21h         ;�����ж�����
	mov ah,irq_mask_2_7
	and al,ah
        out 21h, al
        in al, 0a1h
	mov ah,irq_mask_9_15
	and al,ah
        out 0a1h, al
	sti                ;���ж�

loop1:
        call disp_proc
	mov ah,1
	int 16h
        jz loop1           ;��������˳�

exit:   cli
        mov ah,irq_mask_2_7		;�ָ��ж�����
	not ah
	in al,21h
	or al,ah
	out 21h,al
	mov ah,irq_mask_9_15
	not ah
	in al,0a1h
	or al,ah
	out 0a1h,al

        mov al,int_vect		;�ָ�ԭ�ж�����
        mov dx,ipreg
	mov cx,csreg
	mov ds,cx
	mov ah,25h
        int 21h

	mov ax,data	;���� tpc ����9054оƬio��,�ر��ж�
        mov ds,ax
	mov dx,ioport_cent
	add dx,68h
	in  ax,dx
        and ax,0f7ffh
	out dx,ax

	mov ax,4c00h
	int 21h		;�˳�

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
        MOV CX,0A000H     ;ʱ���ӳ�
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

int_proc proc far	;�жϵ���
        cli
        pusha
	push ds		;����Ĵ���ֵ
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
loopx1: loop loopx1             ;��ʱ
	out 20h,al
        mov cx,0ffffh
loopx:  loop loopx              ;��ʱ
	pop ds
        popa                    ;�ָ��Ĵ���ֵ
	sti
	iret			;�жϷ���
int_proc endp
code ends
end start
