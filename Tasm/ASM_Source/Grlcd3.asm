;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;******************************;
;* 图形液晶显示实验(特效显示) *;
;******************************;
data segment
 ioport			DW 0d400h-280h
 grlcdrightctlport	DW 2b2H	;图形lcd右半屏指令端口地址
 grlcdrightdataport	DW 2b3H	;图形lcd右半屏数据端口地址
 grlcdleftctlport	DW 2b4H	;图形lcd左半屏指令端口地址
 grlcdleftdataport	DW 2b5H	;图形lcd左半屏数据端口地址
 mes1  db 0ah,0dh,'PRESS UP or DOWN KEY IN THE PC KEYBOARD! ',0ah,0dh
       db 'LCD''s DISPLAY WILL BE MOVE! END WITH ANY KEY! ',0ah,0dh,'$'
 ; 图形点阵
picture_dots  DB 000H,000H,000H,000H,000H,000H,000H,07CH ;7*0
DB 082H,001H,061H,0B1H,052H,05CH,024H,002H ;15*0
DB 041H,081H,061H,052H,082H,004H,018H,0E0H ;23*0
DB 000H,000H,000H,000H,000H,000H,000H,000H ;31*0
DB 000H,000H,000H,000H,000H,000H,080H,060H ;39*0
DB 018H,006H,001H,000H,0C0H,020H,000H,080H ;47*0
DB 0C1H,022H,01CH,004H,002H,001H,080H,040H ;55*0
DB 040H,001H,002H,004H,018H,070H,008H,004H ;63*0
DB 002H,001H,000H,000H,0C0H,020H,040H,081H ;71*0
DB 006H,038H,0C0H,000H,000H,000H,000H,000H ;79*0
DB 080H,060H,018H,004H,002H,081H,040H,020H ;87*0
DB 020H,040H,081H,002H,004H,0F8H,000H,000H ;95*0
DB 000H,007H,00CH,033H,04CH,093H,07CH,003H ;103*0
DB 07CH,020H,050H,0A0H,0A0H,070H,008H,0A4H ;111*0
DB 052H,02AH,029H,015H,016H,015H,00AH,009H ;119*0
DB 004H,002H
DB 000H,080H,080H,080H,070H,088H,0F6H,019H ;7*1
DB 0C8H,0A8H,0F0H,000H,000H,000H,0F0H,0A8H ;15*1
DB 0E8H,010H,0FDH,012H,00DH,0F2H,020H,020H ;23*1
DB 0DFH,0B0H,028H,028H,008H,0F8H,000H,000H ;31*1
DB 000H,000H,000H,0C0H,030H,008H,047H,0A0H ;39*1
DB 0A0H,080H,000H,002H,003H,002H,002H,0A3H ;47*1
DB 0A0H,0C0H,040H,00CH,013H,061H,081H,002H ;55*1
DB 004H,018H,020H,040H,080H,080H,060H,020H ;63*1
DB 020H,020H,010H,008H,007H,000H,0C0H,020H ;71*1
DB 017H,008H,0CCH,027H,022H,022H,0E2H,083H ;79*1
DB 002H,0C2H,024H,02AH,0B1H,0C0H,041H,081H ;87*1
DB 002H,004H,008H,010H,008H,007H,000H,000H ;95*1
DB 000H,000H,000H,0C0H,030H,00CH,0CBH,024H ;103*1
DB 024H,0C8H,000H,000H,000H,0C8H,025H,026H ;111*1
DB 0C8H,030H,0C0H,000H,000H,000H,000H,000H ;119*1
DB 000H,000H
DB 065H,080H,080H,080H,001H,001H,009H,01AH ;7*2
DB 013H,0E3H,0C5H,039H,045H,0C2H,0E5H,0E7H ;15*2
DB 035H,01AH,013H,022H,023H,003H,002H,003H ;23*2
DB 00AH,014H,0E1H,002H,002H,003H,018H,0A8H ;31*2
DB 048H,048H,004H,007H,008H,008H,00FH,020H ;39*2
DB 03FH,033H,03FH,040H,0C0H,040H,01FH,021H ;47*2
DB 03FH,033H,03FH,010H,010H,008H,00FH,008H ;55*2
DB 088H,088H,090H,090H,060H,000H,000H,000H ;63*2
DB 000H,058H,0A4H,084H,0CAH,055H,029H,050H ;71*2
DB 0A8H,004H,027H,048H,0C8H,0CFH,04EH,047H ;79*2
DB 0DCH,077H,054H,0CFH,0C6H,027H,004H,028H ;87*2
DB 015H,0AAH,064H,054H,028H,080H,050H,028H ;95*2
DB 008H,008H,008H,08FH,088H,048H,06FH,0D0H ;103*2
DB 09FH,09FH,008H,014H,024H,017H,08FH,04CH ;111*2
DB 06FH,024H,007H,004H,002H,002H,002H,014H ;119*2
DB 0E8H,000H
DB 000H,000H,000H,000H,001H,0C1H,021H,012H ;7*3
DB 01EH,028H,057H,0AFH,0AFH,097H,04BH,034H ;15*3
DB 00AH,00AH,014H,014H,024H,0C4H,004H,002H ;23*3
DB 001H,002H,001H,000H,000H,000H,001H,002H ;31*3
DB 002H,004H,004H,004H,004H,008H,010H,0A0H ;39*3
DB 061H,021H,063H,0A5H,02BH,02BH,025H,0A3H ;47*3
DB 061H,021H,020H,050H,088H,008H,004H,004H ;55*3
DB 004H,002H,001H,000H,000H,000H,000H,000H ;63*3
DB 000H,000H,000H,000H,000H,001H,081H,042H ;71*3
DB 022H,014H,028H,040H,088H,011H,0A2H,042H ;79*3
DB 041H,0A2H,012H,089H,074H,024H,044H,082H ;87*3
DB 001H,000H,000H,000H,000H,007H,008H,004H ;95*3
DB 008H,010H,010H,010H,010H,010H,010H,008H ;103*3
DB 013H,02FH,05FH,0B9H,0BBH,059H,027H,018H ;111*3
DB 010H,008H,008H,004H,004H,002H,002H,001H ;119*3
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
	call graph_lcd_reset	;复位及初始化
	call graph_lcd_disp_picture	;显示图形
	call graph_lcd_disp_move	;图形上下滚动特效
        mov ax,4c00h
	int 21h			;退出

graph_lcd_reset proc near
	call graph_lcd_reset1	;右半屏液晶复位及初始化
	add ioport,2
	call graph_lcd_reset1	;左半屏液晶复位及初始化
	sub ioport,2
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

graph_lcd_disp_picture proc near	;显示一个122*32点阵图形
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

graph_lcd_disp_move proc near		;图形上下滚动特效
	mov dx,offset mes1		;显示提示信息
	mov ah,09
	int 21h
	xor cl,cl
graph_lcd_disp_move_loop:
	mov ah,01h	;判断是否有键按下
	int 16h
	jz graph_lcd_disp_move_loop
	mov ah,0h
	int 16h
	cmp ah,48h
	jnz graph_lcd_disp_move_loop1
	inc cl
	jmp graph_lcd_disp_move_loop2
graph_lcd_disp_move_loop1:
	cmp ah,50h
	jnz graph_lcd_disp_move_exit
	dec cl
graph_lcd_disp_move_loop2:
	and cl,01fh
	mov bl,cl
	or bl,0c0h
	add ioport,2
	call graph_lcd_write_ctr	;显示起始行, COM寄存器
	sub ioport,2
	call graph_lcd_write_ctr	;显示起始行, COM寄存器
	jmp graph_lcd_disp_move_loop
graph_lcd_disp_move_exit:
	ret
graph_lcd_disp_move endp

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
	add ioport,2
	mov bl,10111000B
	add bl,ah
	call graph_lcd_write_ctr	;左半屏页地址设置
	mov bl,00000000B
	add bl,al
	call graph_lcd_write_ctr	;左半屏列地址设置
	mov bl,dl
	call graph_lcd_write_data	;向左半屏显存送数据
	sub ioport,2
graph_lcd_disp_block_exit:
	popf
	popa
	ret
graph_lcd_disp_block endp

graph_lcd_write_ctr proc near		;向lcd写控制命令(bl)
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

graph_lcd_write_data proc near		;向lcd写数据(bl)
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
code ends
end start
