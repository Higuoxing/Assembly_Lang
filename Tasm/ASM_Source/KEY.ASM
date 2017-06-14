;386以上微机适用
;tasm4.1或以上编译
;*************************************;
;* 8255A并行口键盘扫描实验(I/O方式) *;
;*************************************;
 ioport	equ 0d400h-280H
 pa8255	equ ioport+288H	;8255端口,a口
 pc8255	equ ioport+28aH	;8255端口,c口
 p8255ctl	equ ioport+28bH	;8255端口,控制口
data segment
 table1	dw 0101h,0102h,0104h,0108h,0110h,0120h,0140h,0180h
	dw 0201h,0202h,0204h,0208h,0210h,0220h,0240h,0280h
	dw 0401h,0402h,0404h,0408h,0410h,0420h,0440h,0480h	;键盘扫描码表
 char  db '89ABCDEF01234567GMPRWXY '				;字符表
 mes   db 0ah,0dh
       db 'PLAY ANY KEY IN THE SMALL KEYBOARD! ',0ah,0dh
       db 'IT WILL BE ON THE SCREEN! END WITH R or ANY KEY',0ah,0dh,'$'
data ends
stacks segment stack	;堆栈空间
 db 100 dup (0)
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
        mov ss,ax		;设置数据段

	mov dx,offset mes	;显示提示信息
	mov ah,09
	int 21h
ky:
        call key                ;get a char in (dl) and display it
	cmp dl,'R'
        jnz ky
        mov ax,4c00h            ;if (dl)='R' return to EXIT!
	int 21h			;退出

key proc near
kst:
	mov al,010000011b
	mov dx,p8255ctl
	out dx,al               ;set command word of 8255a
	                        ;port a for output,port c for input
wait1:
	mov ah,1
	int 16h
        jnz exit1               ;按任意键退出
        jmp next
exit1:
        mov ax,4c00h            ;return to EXIT!
	int 21h
next:
	mov al,00
	mov dx,pa8255
	out dx,al               ;port a output 00
	mov dx,pc8255
	in al,dx                ;get col data from port c
	or al,0f8h		;屏蔽高5位，置为1
	cmp al,0ffh
	jz wait1                ;no key is closed ,wait
	push ax                 ;save the col data
	push ax
        call delay		;delay for amoment
	mov dx,p8255ctl
	mov al,010010000b	;set command word of 8255a
	out dx,al               ;port a for input,port c for output
	mov dx,pc8255
        pop ax
	out dx,al               ;output col data to port c
	mov dx,pa8255
	in al,dx                ;(al) is row data from port a
        pop bx
	mov ah,bl               ;(ah) is col data
	not ax
	mov si,offset table1	;键盘扫描码表首址
	mov di,offset char	;字符表首址
	mov cx,24		;待查表的表大小
tt:
	cmp ax,[si]		;cmp (col,row) with every word
	jz nn			;in the table
	dec cx
	jz kst			;未找到对应扫描码
	add si,2
	inc di
	jmp tt
nn:
	mov dl,[di]
	mov ah,02
	int 21h
	push dx
	mov al,010000011b
	mov dx,p8255ctl
	out dx,al               ;set command word of 8255a
	                        ;port a for output,port c for input
	mov al,00
	mov dx,pa8255
	out dx,al               ;port a output 00
wait2:
	mov dx,pc8255
	in al,dx                ;get col data from port c
	or al,0f8h		;屏蔽高5位，置为1
	cmp al,0ffh
	jnz wait2               ;wait until the key is up
	pop dx
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
