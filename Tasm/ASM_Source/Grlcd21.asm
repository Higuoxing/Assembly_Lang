;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;******************************;
;* 图形液晶显示实验(图形显示) *;
;******************************;
 io_plx_device_id	equ 05406h	;TPC卡设备ID
 io_plx_vendor_id	equ 010b5h	;TPC卡厂商ID
 IO_PLX_SUB_ID		EQU 0905410B5H	;TPC卡子设备及厂商ID
 grlcdrightctlport	equ 2b2H-280H	;图形lcd右半屏指令端口地址
 grlcdrightdataport	equ 2b3H-280H	;图形lcd右半屏数据端口地址
 grlcdleftctlport	equ 2b4H-280H	;图形lcd左半屏指令端口地址
 grlcdleftdataport	equ 2b5H-280H	;图形lcd左半屏数据端口地址
data segment
 io_base_address	db 4 DUP(0)	;TPC卡I/O基地址暂存空间
 pcicardnotfind		db 0dh,0ah,'TPC pci card not find or address/interrupt error !!!',0dh,0ah,'$'
 iobaseaddress		db 0dh,0ah,'TPC pci card I/O Base Address : ','$'
 enter_return		db 0dh,0ah,'$'
 ; 图形点阵
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
stacks segment stack	;堆栈空间
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
	call	findtpc		;查找TPC卡资源并显示

	call graph_lcd_reset	;复位及初始化
	call graph_lcd_disp_picture	;显示图形
        mov ax,4c00h
	int 21h			;退出

graph_lcd_reset proc near
	call graph_lcd_reset1	;右半屏液晶复位及初始化
	add io_base_address,2
	call graph_lcd_reset1	;左半屏液晶复位及初始化
	sub io_base_address,2
	ret
graph_lcd_reset endp

graph_lcd_reset1 proc near
	mov bl,11100010B
	call graph_lcd_write_ctr	;复位
	call delay2
	mov bl,10101110B
	call graph_lcd_write_ctr	;显示开关控制，关闭
	mov bl,11101110B
	call graph_lcd_write_ctr	;结束修正
	mov bl,11000000B
	call graph_lcd_write_ctr	;显示起始行, COM寄存器
	mov bl,10100100B
	call graph_lcd_write_ctr	;活动状态设置
	mov bl,00000000B
	call graph_lcd_write_ctr	;行地址设置
	mov bl,10111000B
	call graph_lcd_write_ctr	;页地址设置
	mov bl,10101001B
	call graph_lcd_write_ctr	;图形占空比设置
	mov bl,10100000B
	call graph_lcd_write_ctr	;ADC选择
	mov bl,10101111B
	call graph_lcd_write_ctr	;显示开关控制，打开
	ret
graph_lcd_reset1 endp

graph_lcd_disp_picture proc near		;显示一个122*32点阵图形
	pusha
	pushf
	mov si,offset picture_dots
	mov ax,00H			;从零页、零列开始
	mov cx,4
graph_lcd_disp_picture_loop:
	push ax
	push cx
	mov cx,122
graph_lcd_disp_picture_loop1:
	mov dl,byte ptr [si]
	call graph_lcd_disp_block	;循环显示图形点阵122*32，122列*4页
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

graph_lcd_disp_block proc near		;向指定的页地址(ah)/列地址(al)送指定的数据(dl)
	pusha
	pushf
	and ah,003h
	and al,07fh
	cmp al,61
	jc graph_lcd_disp_block_rightlcd	;列地址值超过60表示为右半屏数据，否则为左半屏
	sub al,61
	mov bl,10111000B
	add bl,ah
	call graph_lcd_write_ctr	;右半屏页地址设置
	mov bl,00000000B
	add bl,al
	call graph_lcd_write_ctr	;右半屏列地址设置
	mov bl,dl
	call graph_lcd_write_data	;向右半屏显存送数据
	jmp graph_lcd_disp_block_exit
graph_lcd_disp_block_rightlcd:
	add io_base_address,2
	mov bl,10111000B
	add bl,ah
	call graph_lcd_write_ctr	;左半屏页地址设置
	mov bl,00000000B
	add bl,al
	call graph_lcd_write_ctr	;左半屏列地址设置
	mov bl,dl
	call graph_lcd_write_data	;向左半屏显存送数据
	sub io_base_address,2
graph_lcd_disp_block_exit:
	popf
	popa
	ret
graph_lcd_disp_block endp

graph_lcd_write_ctr proc near		;向lcd写控制命令(bl)
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

graph_lcd_write_data proc near		;向lcd写数据(bl)
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

delay2 proc near		;延时
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

findtpc proc near			;查找TPC卡资源并显示
	pushad
	pushfd
	MOV	AX,0B101H
	INT	1AH
	JC	findtpc_notfind		;检查PCI BIOS是否存在

	MOV	AX,0B102H
	MOV	CX,io_plx_device_id
	MOV	DX,io_plx_vendor_id
	MOV	SI,0
	INT	1AH
	JC	findtpc_notfind		;检查TPC卡是否安装,设备号、厂商号

	MOV	AX,0B10AH
	MOV	DI,02CH
	INT	1AH
	JC	findtpc_notfind
	CMP	ECX,IO_PLX_SUB_ID
	JNZ	findtpc_notfind		;检查TPC卡是否安装,子设备号、厂商号

	MOV	AX,0B10AH
	MOV	DI,18H
	INT	1AH
	JC	findtpc_notfind		;读TPC卡I/O基址信息
	mov	dword ptr io_base_address,ecx
	and	ecx,1
	jz	findtpc_notfind		;检查是否为i/o基址信息
	mov	ecx,dword ptr io_base_address
	and	ecx,0fffffffeh
	mov	dword ptr io_base_address,ecx	;去除i/o指示位并保存

	mov	dx,offset iobaseaddress		;显示i/o提示信息
	mov	ah,09h
	int	21h
	mov	ax,word ptr io_base_address
	call	dispword			;显示i/o基地址

	mov	dx,offset enter_return		;加回车符,换行符
	mov	ah,09h
	int	21h
	popfd
	popad
	ret
findtpc_notfind:
	mov dx,offset pcicardnotfind		;显示未找到tpc卡提示信息
	mov ah,09h
	int 21h
	mov ax,4c00h
	int 21h		;退出
findtpc endp

dispword proc near	;显示子程序
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
	and al,0fh	;首先取低四位
	mov dl,al
	cmp dl,9	;判断是否<=9
	jle dispword_num	;若是则为'0'-'9',ASCII码加30H
	add dl,7	;否则为'A'-'F',ASCII码加37H
dispword_num:
	add dl,30h
	mov ah,02h	;显示
	int 21h
	pop cx
	pop ax
	loop dispword_loop1
	popf
	popa
	ret		;子程序返回
dispword endp
code ends
end start
