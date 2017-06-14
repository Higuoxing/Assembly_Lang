;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;******************************;
;* 图形液晶显示实验(液晶自检) *;
;******************************;
data segment
 ioport			DW 0d400h-280h
 grlcdrightctlport	DW 2b2H	;图形lcd右半屏指令端口地址
 grlcdrightdataport	DW 2b3H	;图形lcd右半屏数据端口地址
 grlcdleftctlport	DW 2b4H	;图形lcd左半屏指令端口地址
 grlcdleftdataport	DW 2b5H	;图形lcd左半屏数据端口地址
 mes   db 0ah,0dh,'PRESS ANY KEY TO NEXT !',0ah,0dh,'$'
 mes1  db 0ah,0dh,'PRESS ANY KEY TO EXIT !',0ah,0dh,'$'
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
	call graph_lcd_check	;交替显示
	call graph_lcd_refresh	;清屏
	call graph_lcd_fullscr	;全屏显示
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

graph_lcd_check proc near		;交替显示，检查液晶点阵
	pusha
	pushf
	mov ah,0			;第零页
	mov cx,122
graph_lcd_check_loop1:
	mov al,cl
	dec al
	mov dl,055H
	call graph_lcd_disp_block	;显示055H
	dec cx
	dec al
	mov dl,0AAH
	call graph_lcd_disp_block	;显示0AAH
	loop graph_lcd_check_loop1
	inc ah				;第一页
	mov cx,122
graph_lcd_check_loop2:
	mov al,cl
	dec al
	mov dl,0FFH
	call graph_lcd_disp_block	;显示0FFH
	dec cx
	dec al
	mov dl,00H
	call graph_lcd_disp_block	;显示00H
	loop graph_lcd_check_loop2
	inc ah				;第二页
	mov cx,122
graph_lcd_check_loop3:
	mov al,cl
	dec al
	mov dl,05AH
	call graph_lcd_disp_block	;显示05AH
	dec cx
	dec al
	mov dl,0A5H
	call graph_lcd_disp_block	;显示0A5H
	loop graph_lcd_check_loop3
	inc ah				;第三页
	mov cx,122
graph_lcd_check_loop4:
	mov al,cl
	dec al
	mov dl,0F0H
	call graph_lcd_disp_block	;显示0F0H
	dec cx
	dec al
	mov dl,00FH
	call graph_lcd_disp_block	;显示00FH
	loop graph_lcd_check_loop4
	popf
	popa
	ret
graph_lcd_check endp

graph_lcd_refresh proc near		;清屏
	pusha
	pushf
	mov dx,offset mes		;显示提示信息
	mov ah,09
	int 21h
	xor cl,cl
graph_lcd_reset_loop2:
	mov ah,01h	;判断是否有键按下
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
	call graph_lcd_disp_block	;循环清屏122(0-121)列*4(0-3)页
	loop graph_lcd_refresh_loop1
	pop cx
	loop graph_lcd_refresh_loop
	popf
	popa
	ret
graph_lcd_refresh endp

graph_lcd_fullscr proc near		;全屏显示
	pusha
	pushf
	mov dx,offset mes1		;显示提示信息
	mov ah,09
	int 21h
	xor cl,cl
graph_lcd_fullscr_loop2:
	mov ah,01h	;判断是否有键按下
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
	call graph_lcd_disp_block	;循环全屏设置122(0-121)列*4(0-3)页
	loop graph_lcd_fullscr_loop1
	pop cx
	loop graph_lcd_fullscr_loop
	popf
	popa
	ret
graph_lcd_fullscr endp

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
