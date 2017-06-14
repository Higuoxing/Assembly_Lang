;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;**********************;
;* 字符液晶显示实验1  *;
;**********************;
 ioport		equ 0d400h-0280h
 chlcdctlport	equ ioport+2b0H	;字符lcd指令端口地址
 chlcddataport	equ ioport+2b1H	;字符lcd数据端口地址
data segment
 mes2  db 0ah,0dh,'DISPLAY USERLIB CHAR TO LCD !',0ah,0dh,'$'
 userlib   DB  08H,0FH,12H,0FH,0AH,1FH,02H,02H		;"年"代码=00H
           DB  0FH,09H,0FH,09H,0FH,09H,11H,00H		;"月"代码=01H
           DB  1FH,11H,11H,1FH,11H,11H,1FH,00H		;"日"代码=02H
           DB  11H,0AH,04H,1FH,04H,1FH,04H,00H		;"$"代码=03H
           DB  0EH,00H,1FH,0AH,0AH,0AH,13H,00H		;"元"代码=04H
           DB  18H,18H,07H,08H,08H,08H,07H,00H		;"℃"代码=05H
           DB  04H,0AH,15H,04H,04H,04H,04H,00H		;"↑"代码=06H
           DB  17H,15H,15H,15H,15H,15H,17H,00H		;"10"代码=07H
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
	call char_lcd_userlib	;显示自定义字符
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

char_lcd_userlib proc near
	mov dx,offset mes2	;显示提示信息
	mov ah,09
	int 21h

	mov bl,01000000B
	call chlcd_write_ctr	;设置CGRAM地址
	mov si,offset userlib
	mov cx,64
char_lcd_userlib_loop1:
	mov bl,byte ptr [si]
	call chlcd_write_data	;向CGRAM写自定义字符点阵数据
	inc si
	loop char_lcd_userlib_loop1

	mov bl,10000000B
	call chlcd_write_ctr	;设置第一行DDRAM地址
	mov cx,16
	mov bl,0h
char_lcd_userlib_loop:
	call chlcd_write_data	;向第一行DDRAM写自定义字符数据
	inc bl
	loop char_lcd_userlib_loop

	ret
char_lcd_userlib endp

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

delay2 proc near
	pusha       ;delay
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
