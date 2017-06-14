;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;*********************;
;* 字符液晶显示实验  *;
;*********************;
 ioport		equ 0d400h-0280h
 chlcdctlport	equ ioport+2b0H	;字符lcd指令端口地址
 chlcddataport	equ ioport+2b1H	;字符lcd数据端口地址
data segment
 mes1  db 0ah,0dh,'PRESS ANY KEY IN THE PC KEYBOARD! ',0ah,0dh
       db 'LCD''s DISPLAY WILL BE CHANGE! END WITH ANY KEY! ',0ah,0dh,'$'
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
        call char_lcd_reset	;复位及初始化
	call char_lcd_disp_all	;显示系统字库内容
        mov ax,4c00h
	int 21h			;退出

char_lcd_reset proc near	;复位及初始化
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
	call chlcd_write_ctr	;功能设置，工作方式设置（初始化）
	mov bl,00000001B
	call chlcd_write_ctr	;清屏,清DDRAM,AC
	mov bl,00000110B
	call chlcd_write_ctr	;输入方式设置，光标、画面移动方式
	mov bl,00000010B
	call chlcd_write_ctr	;复（归）位,AC=0,光标、画面回HOME位
	mov bl,00001111B
	call chlcd_write_ctr	;显示开关控制，打开
	ret
char_lcd_reset endp

char_lcd_disp_all proc near	;显示系统字库内容
	mov dx,offset mes1	;显示提示信息
	mov ah,09
	int 21h
	mov bl,20h
	mov cx,7
char_lcd_disp_all_loop2:
	push cx
	push bx
	mov bl,10000000B
	call chlcd_write_ctr	;设置第一行DDRAM地址
	mov cx,16
	pop bx
char_lcd_disp_all_loop:
	call chlcd_write_data	;向第一行DDRAM写系统字符数据
	inc bl
	loop char_lcd_disp_all_loop

	push bx
	mov bl,11000000B
	call chlcd_write_ctr	;设置第二行DDRAM地址
	mov cx,16
	pop bx
char_lcd_disp_all_loop1:
	call chlcd_write_data	;向第二行DDRAM写系统字符数据
	inc bl
	loop char_lcd_disp_all_loop1

char_lcd_disp_all_wait:
	mov ah,01h		;判断是否有键按下
	int 16h
	jz char_lcd_disp_all_wait	;若无则转，否则退出
	mov ah,0h
	int 16h
	pop cx
	loop char_lcd_disp_all_loop2
	ret
char_lcd_disp_all endp

chlcd_write_ctr proc near	;向lcd写控制命令(bl)
	pusha
	pushf
	MOV DX,chlcdctlport
	mov al,bl
	out dx,al		;向指令端口输出命令
	call delay2
	popf
	popa
	ret
chlcd_write_ctr endp

chlcd_write_data proc near	;向lcd写数据(bl)
	pusha
	pushf
	MOV DX,chlcddataport
	mov al,bl
	out dx,al		;向数据端口输出数据
	call delay2
	popf
	popa
	ret
chlcd_write_data endp

delay2 proc near		;延时
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
