;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;******************************;
;* ͼ��Һ����ʾʵ��(������ʾ) *;
;******************************;
data segment
 ioport			DW 0d400h-280h
 grlcdrightctlport	DW 2b2H	;ͼ��lcd�Ұ���ָ��˿ڵ�ַ
 grlcdrightdataport	DW 2b3H	;ͼ��lcd�Ұ������ݶ˿ڵ�ַ
 grlcdleftctlport	DW 2b4H	;ͼ��lcd�����ָ��˿ڵ�ַ
 grlcdleftdataport	DW 2b5H	;ͼ��lcd��������ݶ˿ڵ�ַ
 mes   db 0ah,0dh,'DISPLAY HZ TO LCD !',0ah,0dh,'$'
; ����16x16
hz_dots DB 000H,0FEH,042H,042H,022H,01EH,0AAH,04AH ; ͼ
DB 0AAH,09AH,00AH,002H,002H,0FEH,000H,000H
DB 000H,0FFH,042H,042H,041H,041H,048H,072H
DB 054H,040H,041H,043H,041H,0FFH,000H,000H
DB 040H,042H,042H,0FEH,042H,042H,0FEH,042H ; ��
DB 042H,040H,010H,088H,0E4H,047H,002H,000H
DB 080H,040H,030H,00FH,000H,000H,07FH,000H
DB 084H,042H,021H,010H,008H,00EH,004H,000H
DB 010H,061H,006H,0E0H,018H,084H,0E4H,01CH ; Һ
DB 084H,065H,0BEH,024H,0A4H,064H,004H,000H
DB 004H,004H,0FFH,000H,001H,000H,0FFH,041H
DB 021H,012H,00CH,01BH,061H,0C0H,040H,000H
DB 000H,000H,000H,000H,07EH,02AH,02AH,02AH ; ��
DB 02AH,02AH,02AH,07EH,000H,000H,000H,000H
DB 000H,07FH,025H,025H,025H,025H,07FH,000H
DB 000H,07FH,025H,025H,025H,025H,07FH,000H
DB 000H,000H,000H,03EH,02AH,0EAH,02AH,02AH ; ��
DB 02AH,0EAH,02AH,03EH,000H,000H,000H,000H
DB 020H,021H,022H,02CH,020H,03FH,020H,020H
DB 020H,03FH,028H,024H,023H,020H,020H,000H
DB 000H,020H,020H,022H,022H,022H,022H,0E2H ; ʾ
DB 022H,022H,022H,022H,022H,020H,020H,000H
DB 010H,008H,004H,003H,000H,040H,080H,07FH
DB 000H,000H,001H,002H,00CH,018H,000H,000H
DB 040H,040H,04FH,049H,049H,0C9H,0CFH,070H ; ��
DB 0C0H,0CFH,049H,059H,069H,04FH,000H,000H
DB 002H,002H,07EH,045H,045H,044H,07CH,000H
DB 07CH,044H,045H,045H,07EH,006H,002H,000H
DB 000H,000H,000H,03EH,02AH,0EAH,02AH,02AH ; ��
DB 02AH,0EAH,02AH,03EH,000H,000H,000H,000H
DB 020H,021H,022H,02CH,020H,03FH,020H,020H
DB 020H,03FH,028H,024H,023H,020H,020H,000H
DB 000H,020H,020H,022H,022H,022H,022H,0E2H ; ʾ
DB 022H,022H,022H,022H,022H,020H,020H,000H
DB 010H,008H,004H,003H,000H,040H,080H,07FH
DB 000H,000H,001H,002H,00CH,018H,000H,000H
DB 010H,060H,001H,086H,060H,004H,01CH,0E4H ; ��
DB 004H,004H,004H,0E4H,01CH,004H,000H,000H
DB 004H,004H,07EH,001H,040H,020H,020H,010H
DB 00BH,004H,00BH,010H,030H,060H,020H,000H
DB 000H,010H,00CH,024H,024H,024H,025H,026H ; ��
DB 0A4H,064H,024H,004H,014H,00CH,000H,000H
DB 000H,002H,002H,002H,002H,042H,082H,07FH
DB 002H,002H,002H,002H,002H,002H,002H,000H
DB 000H,0F8H,08CH,08BH,088H,0F8H,040H,030H ; ��
DB 08FH,008H,008H,008H,008H,0F8H,000H,000H
DB 000H,07FH,010H,010H,010H,03FH,000H,000H
DB 000H,003H,026H,040H,020H,01FH,000H,000H
DB 000H,008H,0C8H,039H,00EH,018H,0A8H,048H ; Ч
DB 040H,0F0H,01FH,012H,010H,0F0H,010H,000H
DB 040H,041H,021H,012H,00CH,00AH,051H,040H
DB 020H,020H,013H,00CH,033H,060H,020H,000H
DB 000H,000H,000H,03EH,02AH,02AH,02AH,0FEH ; ��
DB 02AH,02AH,02AH,03EH,000H,000H,000H,000H
DB 021H,021H,011H,011H,009H,005H,003H,0FFH
DB 003H,005H,009H,009H,011H,031H,011H,000H
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
	call graph_lcd_refresh	;����
	call graph_lcd_disp_hz_string	;��ʾ���ִ�
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

graph_lcd_refresh proc near		;����
	pusha
	pushf
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

graph_lcd_disp_hz_string proc near	;��ʾ���ִ�
	mov dx,offset mes		;��ʾ��ʾ��Ϣ
	mov ah,09
	int 21h
	mov ax,0002h			;���õ�һ�����ֵ���ʼҳ(ah)/��ʼ��(al)
	mov si,offset hz_dots
	mov cx,2
graph_lcd_disp_hz_string_loop1:
	push cx
	mov cx,7
graph_lcd_disp_hz_string_loop:
	call graph_lcd_disp_hz		;ѭ����ʾ2��*7������
	add al,11h			;���ú����м��
	add si,20h
	loop graph_lcd_disp_hz_string_loop
	mov ax,0202h
	pop cx
	loop graph_lcd_disp_hz_string_loop1
	ret
graph_lcd_disp_hz_string endp

graph_lcd_disp_hz proc near		;��ָ����ҳ��ַ(ah)/�е�ַ(al)��ʾһ��16*16������
	pusha
	pushf
	mov cx,2
graph_lcd_disp_hz_loop:
	push ax
	push cx
	mov cx,16
graph_lcd_disp_hz_loop1:
	mov dl,byte ptr [si]
	call graph_lcd_disp_block	;ѭ����ʾ���ֵ���16*16��16��*2ҳ
	inc al
	inc si
	loop graph_lcd_disp_hz_loop1
	pop cx
	pop ax
	inc ah
	loop graph_lcd_disp_hz_loop
	popf
	popa
	ret
graph_lcd_disp_hz endp

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
