;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;******************************;
;* ͼ��Һ����ʾʵ��(Һ���Լ�) *;
;******************************;
data segment
 ioport			DW 0d400h-280h
 grlcdrightctlport	DW 2b2H	;ͼ��lcd�Ұ���ָ��˿ڵ�ַ
 grlcdrightdataport	DW 2b3H	;ͼ��lcd�Ұ������ݶ˿ڵ�ַ
 grlcdleftctlport	DW 2b4H	;ͼ��lcd�����ָ��˿ڵ�ַ
 grlcdleftdataport	DW 2b5H	;ͼ��lcd��������ݶ˿ڵ�ַ
 mes   db 0ah,0dh,'PRESS ANY KEY TO NEXT !',0ah,0dh,'$'
 mes1  db 0ah,0dh,'PRESS ANY KEY TO EXIT !',0ah,0dh,'$'
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
	call graph_lcd_reset	;��λ����ʼ��
	call graph_lcd_check	;������ʾ
	call graph_lcd_refresh	;����
	call graph_lcd_fullscr	;ȫ����ʾ
        mov ax,4c00h
	int 21h			;�˳�

graph_lcd_reset proc near
	call graph_lcd_reset1	;�Ұ���Һ����λ����ʼ��
	add ioport,2
	call graph_lcd_reset1	;�����Һ����λ����ʼ��
	sub ioport,2
	ret
graph_lcd_reset endp

graph_lcd_reset1 proc near
	mov bl,11100010B
	call graph_lcd_write_ctr	;��λ
	call delay2
	mov bl,10101110B
	call graph_lcd_write_ctr	;��ʾ���ؿ��ƣ��ر�
	mov bl,11101110B
	call graph_lcd_write_ctr	;��������
	mov bl,11000000B
	call graph_lcd_write_ctr	;��ʾ��ʼ��, COM�Ĵ���
	mov bl,10100100B
	call graph_lcd_write_ctr	;�״̬����
	mov bl,00000000B
	call graph_lcd_write_ctr	;�е�ַ����
	mov bl,10111000B
	call graph_lcd_write_ctr	;ҳ��ַ����
	mov bl,10101001B
	call graph_lcd_write_ctr	;ͼ��ռ�ձ�����
	mov bl,10100000B
	call graph_lcd_write_ctr	;ADCѡ��
	mov bl,10101111B
	call graph_lcd_write_ctr	;��ʾ���ؿ��ƣ���
	ret
graph_lcd_reset1 endp

graph_lcd_check proc near		;������ʾ�����Һ������
	pusha
	pushf
	mov ah,0			;����ҳ
	mov cx,122
graph_lcd_check_loop1:
	mov al,cl
	dec al
	mov dl,055H
	call graph_lcd_disp_block	;��ʾ055H
	dec cx
	dec al
	mov dl,0AAH
	call graph_lcd_disp_block	;��ʾ0AAH
	loop graph_lcd_check_loop1
	inc ah				;��һҳ
	mov cx,122
graph_lcd_check_loop2:
	mov al,cl
	dec al
	mov dl,0FFH
	call graph_lcd_disp_block	;��ʾ0FFH
	dec cx
	dec al
	mov dl,00H
	call graph_lcd_disp_block	;��ʾ00H
	loop graph_lcd_check_loop2
	inc ah				;�ڶ�ҳ
	mov cx,122
graph_lcd_check_loop3:
	mov al,cl
	dec al
	mov dl,05AH
	call graph_lcd_disp_block	;��ʾ05AH
	dec cx
	dec al
	mov dl,0A5H
	call graph_lcd_disp_block	;��ʾ0A5H
	loop graph_lcd_check_loop3
	inc ah				;����ҳ
	mov cx,122
graph_lcd_check_loop4:
	mov al,cl
	dec al
	mov dl,0F0H
	call graph_lcd_disp_block	;��ʾ0F0H
	dec cx
	dec al
	mov dl,00FH
	call graph_lcd_disp_block	;��ʾ00FH
	loop graph_lcd_check_loop4
	popf
	popa
	ret
graph_lcd_check endp

graph_lcd_refresh proc near		;����
	pusha
	pushf
	mov dx,offset mes		;��ʾ��ʾ��Ϣ
	mov ah,09
	int 21h
	xor cl,cl
graph_lcd_reset_loop2:
	mov ah,01h	;�ж��Ƿ��м�����
	int 16h
	jz graph_lcd_reset_loop2
	mov ah,0h
	int 16h
	xor dl,dl
	mov cx,4
graph_lcd_refresh_loop:
	push cx
	mov ah,4
	sub ah,cl
	mov cx,122
graph_lcd_refresh_loop1:
	mov al,cl
	dec al
	call graph_lcd_disp_block	;ѭ������122(0-121)��*4(0-3)ҳ
	loop graph_lcd_refresh_loop1
	pop cx
	loop graph_lcd_refresh_loop
	popf
	popa
	ret
graph_lcd_refresh endp

graph_lcd_fullscr proc near		;ȫ����ʾ
	pusha
	pushf
	mov dx,offset mes1		;��ʾ��ʾ��Ϣ
	mov ah,09
	int 21h
	xor cl,cl
graph_lcd_fullscr_loop2:
	mov ah,01h	;�ж��Ƿ��м�����
	int 16h
	jz graph_lcd_fullscr_loop2
	mov ah,0h
	int 16h
	mov dl,0FFH
	mov cx,4
graph_lcd_fullscr_loop:
	push cx
	mov ah,4
	sub ah,cl
	mov cx,122
graph_lcd_fullscr_loop1:
	mov al,cl
	dec al
	call graph_lcd_disp_block	;ѭ��ȫ������122(0-121)��*4(0-3)ҳ
	loop graph_lcd_fullscr_loop1
	pop cx
	loop graph_lcd_fullscr_loop
	popf
	popa
	ret
graph_lcd_fullscr endp

graph_lcd_disp_block proc near		;��ָ����ҳ��ַ(ah)/�е�ַ(al)��ָ��������(dl)
	pusha
	pushf
	and ah,003h
	and al,07fh
	cmp al,61
	jc graph_lcd_disp_block_rightlcd	;�е�ֵַ����60��ʾΪ�Ұ������ݣ�����Ϊ�����
	sub al,61
	mov bl,10111000B
	add bl,ah
	call graph_lcd_write_ctr	;�Ұ���ҳ��ַ����
	mov bl,00000000B
	add bl,al
	call graph_lcd_write_ctr	;�Ұ����е�ַ����
	mov bl,dl
	call graph_lcd_write_data	;���Ұ����Դ�������
	jmp graph_lcd_disp_block_exit
graph_lcd_disp_block_rightlcd:
	add ioport,2
	mov bl,10111000B
	add bl,ah
	call graph_lcd_write_ctr	;�����ҳ��ַ����
	mov bl,00000000B
	add bl,al
	call graph_lcd_write_ctr	;������е�ַ����
	mov bl,dl
	call graph_lcd_write_data	;��������Դ�������
	sub ioport,2
graph_lcd_disp_block_exit:
	popf
	popa
	ret
graph_lcd_disp_block endp

graph_lcd_write_ctr proc near		;��lcdд��������(bl)
	pusha
	pushf
	MOV DX,word ptr ioport
	add dx,grlcdrightctlport
	mov al,bl
	out dx,al
	call delay2
	popf
	popa
	ret
graph_lcd_write_ctr endp

graph_lcd_write_data proc near		;��lcdд����(bl)
	pusha
	pushf
	MOV DX,word ptr ioport
	add dx,grlcdrightdataport
	mov al,bl
	out dx,al
	call delay2
	popf
	popa
	ret
graph_lcd_write_data endp

delay2 proc near		;��ʱ
	pusha
	pushf
	mov cx,01h
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
