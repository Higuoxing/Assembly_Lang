;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;******************************;
;* ͼ��Һ����ʾʵ��(ͼ����ʾ) *;
;******************************;
 io_plx_device_id	equ 05406h	;TPC���豸ID
 io_plx_vendor_id	equ 010b5h	;TPC������ID
 IO_PLX_SUB_ID		EQU 0905410B5H	;TPC�����豸������ID
 grlcdrightctlport	equ 2b2H-280H	;ͼ��lcd�Ұ���ָ��˿ڵ�ַ
 grlcdrightdataport	equ 2b3H-280H	;ͼ��lcd�Ұ������ݶ˿ڵ�ַ
 grlcdleftctlport	equ 2b4H-280H	;ͼ��lcd�����ָ��˿ڵ�ַ
 grlcdleftdataport	equ 2b5H-280H	;ͼ��lcd��������ݶ˿ڵ�ַ
data segment
 io_base_address	db 4 DUP(0)	;TPC��I/O����ַ�ݴ�ռ�
 pcicardnotfind		db 0dh,0ah,'TPC pci card not find or address/interrupt error !!!',0dh,0ah,'$'
 iobaseaddress		db 0dh,0ah,'TPC pci card I/O Base Address : ','$'
 enter_return		db 0dh,0ah,'$'
 ; ͼ�ε���
picture_dots DB 000H,000H,000H,000H,000H,00CH,012H,012H ;7*0
DB 012H,021H,021H,041H,041H,041H,041H,081H ;15*0
DB 081H,082H,082H,084H,004H,018H,010H,010H ;23*0
DB 008H,008H,008H,008H,008H,008H,008H,008H ;31*0
DB 008H,008H,008H,008H,008H,010H,010H,018H ;39*0
DB 004H,084H,082H,082H,081H,081H,041H,041H ;47*0
DB 041H,041H,021H,021H,012H,012H,012H,00CH ;55*0
DB 000H,000H,000H,000H,000H,000H,000H,000H ;63*0
DB 000H,00CH,012H,012H,012H,021H,021H,041H ;71*0
DB 041H,041H,041H,081H,081H,082H,082H,084H ;79*0
DB 004H,018H,010H,010H,008H,008H,008H,008H ;87*0
DB 008H,008H,008H,008H,008H,008H,008H,008H ;95*0
DB 008H,010H,010H,018H,004H,084H,082H,082H ;103*0
DB 081H,081H,041H,041H,041H,041H,021H,021H ;111*0
DB 012H,012H,012H,00CH,000H,000H,000H,000H ;119*0
DB 000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H ;7*1
DB 000H,000H,000H,000H,000H,000H,000H,000H ;15*1
DB 0F0H,00CH,003H,000H,000H,000H,000H,000H ;23*1
DB 03FH,039H,03FH,000H,000H,080H,000H,080H ;31*1
DB 000H,000H,03FH,039H,03FH,000H,000H,000H ;39*1
DB 000H,000H,003H,00CH,0F0H,000H,000H,000H ;47*1
DB 000H,000H,000H,000H,000H,000H,000H,000H ;55*1
DB 000H,000H,000H,000H,000H,000H,000H,000H ;63*1
DB 000H,000H,000H,000H,000H,000H,000H,000H ;71*1
DB 000H,000H,000H,000H,0F0H,00CH,003H,000H ;79*1
DB 000H,000H,000H,000H,03FH,039H,03FH,000H ;87*1
DB 000H,080H,000H,080H,000H,000H,03FH,039H ;95*1
DB 03FH,000H,000H,000H,000H,000H,003H,00CH ;103*1
DB 0F0H,000H,000H,000H,000H,000H,000H,000H ;111*1
DB 000H,000H,000H,000H,000H,000H,000H,000H ;119*1
DB 000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H ;7*2
DB 000H,000H,000H,000H,000H,000H,000H,000H ;15*2
DB 001H,006H,008H,070H,088H,004H,004H,004H ;23*2
DB 008H,0F0H,040H,040H,040H,040H,041H,040H ;31*2
DB 040H,040H,040H,0F0H,008H,004H,004H,004H ;39*2
DB 088H,070H,018H,007H,000H,000H,000H,000H ;47*2
DB 000H,000H,000H,000H,000H,000H,000H,000H ;55*2
DB 000H,000H,000H,000H,000H,000H,000H,000H ;63*2
DB 000H,000H,000H,000H,000H,000H,000H,000H ;71*2
DB 000H,000H,000H,000H,001H,006H,008H,070H ;79*2
DB 088H,004H,004H,004H,008H,0F0H,040H,040H ;87*2
DB 040H,040H,041H,040H,040H,040H,040H,0F0H ;95*2
DB 008H,004H,004H,004H,088H,070H,018H,007H ;103*2
DB 000H,000H,000H,000H,000H,000H,000H,000H ;111*2
DB 000H,000H,000H,000H,000H,000H,000H,000H ;119*2
DB 000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H ;7*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;15*3
DB 000H,000H,000H,000H,000H,041H,041H,063H ;23*3
DB 0E4H,0F3H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H ;31*3
DB 0F0H,0F0H,0F0H,0F3H,0E4H,063H,041H,041H ;39*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;47*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;55*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;63*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;71*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;79*3
DB 000H,041H,041H,063H,0E4H,0F3H,0F0H,0F0H ;87*3
DB 0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F3H ;95*3
DB 0E4H,063H,041H,041H,000H,000H,000H,000H ;103*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;111*3
DB 000H,000H,000H,000H,000H,000H,000H,000H ;119*3
DB 000H,000H
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
	call	findtpc		;����TPC����Դ����ʾ

	call graph_lcd_reset	;��λ����ʼ��
	call graph_lcd_disp_picture	;��ʾͼ��
        mov ax,4c00h
	int 21h			;�˳�

graph_lcd_reset proc near
	call graph_lcd_reset1	;�Ұ���Һ����λ����ʼ��
	add io_base_address,2
	call graph_lcd_reset1	;�����Һ����λ����ʼ��
	sub io_base_address,2
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

graph_lcd_disp_picture proc near		;��ʾһ��122*32����ͼ��
	pusha
	pushf
	mov si,offset picture_dots
	mov ax,00H			;����ҳ�����п�ʼ
	mov cx,4
graph_lcd_disp_picture_loop:
	push ax
	push cx
	mov cx,122
graph_lcd_disp_picture_loop1:
	mov dl,byte ptr [si]
	call graph_lcd_disp_block	;ѭ����ʾͼ�ε���122*32��122��*4ҳ
	inc al
	inc si
	loop graph_lcd_disp_picture_loop1
	pop cx
	pop ax
	inc ah
	loop graph_lcd_disp_picture_loop
	popf
	popa
	ret
graph_lcd_disp_picture endp

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
	add io_base_address,2
	mov bl,10111000B
	add bl,ah
	call graph_lcd_write_ctr	;�����ҳ��ַ����
	mov bl,00000000B
	add bl,al
	call graph_lcd_write_ctr	;������е�ַ����
	mov bl,dl
	call graph_lcd_write_data	;��������Դ�������
	sub io_base_address,2
graph_lcd_disp_block_exit:
	popf
	popa
	ret
graph_lcd_disp_block endp

graph_lcd_write_ctr proc near		;��lcdд��������(bl)
	pusha
	pushf
	MOV DX,word ptr io_base_address
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
	MOV DX,word ptr io_base_address
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

findtpc proc near			;����TPC����Դ����ʾ
	pushad
	pushfd
	MOV	AX,0B101H
	INT	1AH
	JC	findtpc_notfind		;���PCI BIOS�Ƿ����

	MOV	AX,0B102H
	MOV	CX,io_plx_device_id
	MOV	DX,io_plx_vendor_id
	MOV	SI,0
	INT	1AH
	JC	findtpc_notfind		;���TPC���Ƿ�װ,�豸�š����̺�

	MOV	AX,0B10AH
	MOV	DI,02CH
	INT	1AH
	JC	findtpc_notfind
	CMP	ECX,IO_PLX_SUB_ID
	JNZ	findtpc_notfind		;���TPC���Ƿ�װ,���豸�š����̺�

	MOV	AX,0B10AH
	MOV	DI,18H
	INT	1AH
	JC	findtpc_notfind		;��TPC��I/O��ַ��Ϣ
	mov	dword ptr io_base_address,ecx
	and	ecx,1
	jz	findtpc_notfind		;����Ƿ�Ϊi/o��ַ��Ϣ
	mov	ecx,dword ptr io_base_address
	and	ecx,0fffffffeh
	mov	dword ptr io_base_address,ecx	;ȥ��i/oָʾλ������

	mov	dx,offset iobaseaddress		;��ʾi/o��ʾ��Ϣ
	mov	ah,09h
	int	21h
	mov	ax,word ptr io_base_address
	call	dispword			;��ʾi/o����ַ

	mov	dx,offset enter_return		;�ӻس���,���з�
	mov	ah,09h
	int	21h
	popfd
	popad
	ret
findtpc_notfind:
	mov dx,offset pcicardnotfind		;��ʾδ�ҵ�tpc����ʾ��Ϣ
	mov ah,09h
	int 21h
	mov ax,4c00h
	int 21h		;�˳�
findtpc endp

dispword proc near	;��ʾ�ӳ���
	pusha
	pushf
	mov cx,4
	mov bx,16
dispword_loop1:
	push ax
	push cx
	sub bx,4
	mov cx,bx
	shr ax,cl
	and al,0fh	;����ȡ����λ
	mov dl,al
	cmp dl,9	;�ж��Ƿ�<=9
	jle dispword_num	;������Ϊ'0'-'9',ASCII���30H
	add dl,7	;����Ϊ'A'-'F',ASCII���37H
dispword_num:
	add dl,30h
	mov ah,02h	;��ʾ
	int 21h
	pop cx
	pop ax
	loop dispword_loop1
	popf
	popa
	ret		;�ӳ��򷵻�
dispword endp
code ends
end start
