;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;*********************;
;* �ַ�Һ����ʾʵ��  *;
;*********************;
 ioport		equ 0d400h-0280h
 chlcdctlport	equ ioport+2b0H	;�ַ�lcdָ��˿ڵ�ַ
 chlcddataport	equ ioport+2b1H	;�ַ�lcd���ݶ˿ڵ�ַ
data segment
 mes1  db 0ah,0dh,'PRESS ANY KEY IN THE PC KEYBOARD! ',0ah,0dh
       db 'LCD''s DISPLAY WILL BE CHANGE! END WITH ANY KEY! ',0ah,0dh,'$'
data ends
stacks segment stack	;��ջ�ռ�
 db 100 dup (?)
stacks ends
code segment
        assume cs:code,ds:data,ss:stacks,es:data
start:
.386
        cli
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stacks
        mov ss,ax
        call char_lcd_reset	;��λ����ʼ��
	call char_lcd_disp_all	;��ʾϵͳ�ֿ�����
        mov ax,4c00h
	int 21h			;�˳�

char_lcd_reset proc near	;��λ����ʼ��
	mov bl,00110000B
	call chlcd_write_ctr
	call delay2
	mov bl,00110000B
	call chlcd_write_ctr
	call delay2
	mov bl,00110000B
	call chlcd_write_ctr
	call delay2
	mov bl,00111100B
	call chlcd_write_ctr	;�������ã�������ʽ���ã���ʼ����
	mov bl,00000001B
	call chlcd_write_ctr	;����,��DDRAM,AC
	mov bl,00000110B
	call chlcd_write_ctr	;���뷽ʽ���ã���ꡢ�����ƶ���ʽ
	mov bl,00000010B
	call chlcd_write_ctr	;�����飩λ,AC=0,��ꡢ�����HOMEλ
	mov bl,00001111B
	call chlcd_write_ctr	;��ʾ���ؿ��ƣ���
	ret
char_lcd_reset endp

char_lcd_disp_all proc near	;��ʾϵͳ�ֿ�����
	mov dx,offset mes1	;��ʾ��ʾ��Ϣ
	mov ah,09
	int 21h
	mov bl,20h
	mov cx,7
char_lcd_disp_all_loop2:
	push cx
	push bx
	mov bl,10000000B
	call chlcd_write_ctr	;���õ�һ��DDRAM��ַ
	mov cx,16
	pop bx
char_lcd_disp_all_loop:
	call chlcd_write_data	;���һ��DDRAMдϵͳ�ַ�����
	inc bl
	loop char_lcd_disp_all_loop

	push bx
	mov bl,11000000B
	call chlcd_write_ctr	;���õڶ���DDRAM��ַ
	mov cx,16
	pop bx
char_lcd_disp_all_loop1:
	call chlcd_write_data	;��ڶ���DDRAMдϵͳ�ַ�����
	inc bl
	loop char_lcd_disp_all_loop1

char_lcd_disp_all_wait:
	mov ah,01h		;�ж��Ƿ��м�����
	int 16h
	jz char_lcd_disp_all_wait	;������ת�������˳�
	mov ah,0h
	int 16h
	pop cx
	loop char_lcd_disp_all_loop2
	ret
char_lcd_disp_all endp

chlcd_write_ctr proc near	;��lcdд��������(bl)
	pusha
	pushf
	MOV DX,chlcdctlport
	mov al,bl
	out dx,al		;��ָ��˿��������
	call delay2
	popf
	popa
	ret
chlcd_write_ctr endp

chlcd_write_data proc near	;��lcdд����(bl)
	pusha
	pushf
	MOV DX,chlcddataport
	mov al,bl
	out dx,al		;�����ݶ˿��������
	call delay2
	popf
	popa
	ret
chlcd_write_data endp

delay2 proc near		;��ʱ
	pusha
	pushf
	mov cx,010h
delay2_2:
	push cx
	mov cx,0ffffh
delay2_1:
	nop
	loop delay2_1
	pop cx
	nop
	loop delay2_2
	popf
	popa
	ret
delay2 endp
code ends
end start
