;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;****************;
;* 薄膜按键实验 *;
;****************;
 ioport		equ 0d400h-0280h
 smkeyport6	equ ioport+2b6H	;行扫描口地址
 smkeyport7	equ ioport+2b7H	;列扫描口地址
data segment
 table1	dw 0E1Fh,0E2Fh,0E4Fh,0E8Fh,0D1Fh,0D2Fh,0D4Fh,0D8Fh
	dw 0B1Fh,0B2Fh,0B4Fh,0B8Fh,071Fh,072Fh,074Fh,078Fh	;键盘扫描码表
 char  db '0123456789ABCDEF'					;字符表
 mes   db 0ah,0dh,'PLAY ANY KEY IN THE SMALL KEYBOARD! ',0ah,0dh
       db 'IT WILL BE ON THE SCREEN! END WITH E or ANY KEY',0ah,0dh,'$'
 key_in db 0h
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
	mov dx,offset mes	;显示提示信息
	mov ah,09
	int 21h
main_key:
        call key                ;get a char in (key_in) and display it
	cmp byte ptr key_in,'E'
        jnz main_key
        mov ax,4c00h            ;if (dl)='E' return to EXIT!
	int 21h			;退出

key proc near
key_loop:
	mov ah,1
	int 16h
        jnz exit		;pc键盘有键按下则退出
	MOV DX,smkeyport6
	in al,dx		;读行扫描值
	cmp al,0fh
	jz key_loop		;未发现有键按下则转
        call delay		;delay for amoment
	mov ah,al
	MOV DX,smkeyport7
	in al,dx		;读列扫描值
	cmp al,0fh
	jz key_loop		;未发现有键按下则转
	mov si,offset table1	;键盘扫描码表首址
	mov di,offset char	;字符表首址
	mov cx,16		;待查表的表大小
key_tonext:
	cmp ax,[si]		;cmp (col,row) with every word
	jz key_findkey		;in the table
	dec cx
	jz key_loop		;未找到对应扫描码
	add si,2
	inc di
	jmp key_tonext
key_findkey:
	mov dl,[di]
	mov ah,02
	int 21h			;显示查找到的键盘码
	mov byte ptr key_in,dl
key_waitup:
	MOV DX,smkeyport6
	in al,dx		;读行扫描值
	xor ah,ah
	cmp al,0fh
	jnz key_waitup		;按键未抬起转
        call delay		;delay for amoment
	ret
exit:
	mov byte ptr key_in,'E'
	ret
key endp

delay proc near
        pusha       ;delay 50ms--100ms
        mov ah,0
        int 1ah
        mov bx,dx
delay1:
	mov ah,0
	int 1ah
	cmp bx,dx
	jz delay1
	mov bx,dx
delay2:
	mov ah,0
	int 1ah
	cmp bx,dx
	jz delay2
	popa
        ret
delay endp
code ends
end start
