data segment 
menu db 0dh,0ah,'>>>>>>>>>>>>>>menu<<<<<<<<<<<<<',0dh,0ah
	 db 0dh,0ah,'1.Show the sequential pictures press "S".'
	 db 0dh,0ah,'2.Show the pictures by hand press "H".'
	 db 0dh,0ah,'3.Get out press "Q".'
	 db 0dh,0ah,'powered by keven.gao.',0dh,0ah
n	 equ $-menu
menusec db 0dh,0ah,'=>Notice:',0dh,0ah,'If you want to continue press "Enter"'
	 db 0dh,0ah,'If you want to quit press "Q"'
	 db 0dh,0ah,'press any key back to menu',0dh,0ah
n2   equ $-menusec
square dw 20,30,100,50,100
row equ 200
column equ 320
color equ 256
data ends

;******************code segment******************
code segment
	assume ds:data,cs:code,es:data
main proc near
;------------------------------------------------
start:	mov ax,data
		mov ds,ax
		mov es,ax
;------------------------------------------------
again:
		mov ah,0    ;defined as 640*480 16 color mode
		mov al,12h
		int 10h

		lea bp,menu ;show the menu

		mov ah,13h
		mov al,01
		mov cx,n
		mov bl,04h  ;black body,red word
		mov bh,0
		mov dx,0
		int 10h

		mov ah,0    ;get instruction
		int 16h		;get word from keyboard


		cmp al,'Q' 
		jz next
		cmp al,'H'
		jz hand
		mov cx,5
		cmp al,'S'

		jz sequence

hand:
		call random
		call SQUAR
		mov ah,01h	;
		int 21h
		cmp al,0dh
		jz hand
		cmp al,'Q'
		jz next
		jmp again

sequence:
		call random
		call SQUAR
		call delay

		loop sequence

	;	mov ax,0600h
	;	mov al,200
	;	mov cx,0
	;	mov dh,200
	;	mov bh,0
	;	int 10h

	;	lea dx,menusec
	;	mov ah,09h
	;	int 21h
		mov ah,0
		mov al,12h
		int 10h
		lea bp,menusec
		;
		mov ah,13h
		mov al,01
		mov cx,n2
		mov bl,04h
		mov bh,0
		mov dx,0
		int 10h
		mov ah,01
		int 21h
		cmp al,0dh
		mov cx,5
		jz sequence
		cmp al,'Q'
		jz next
		jmp again



next:
		mov ax,4c00h
		int 21h

main endp
;---------------------------------------------
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
random proc near
		push ax
		push bx
		push dx
;---------------------generate row-----------
hang:
		mov ah,0
		in al,40h	;generate random number
		cmp al,200
		ja hang
		mov square,ax
;---------------------generate column-------
lie:
		in al,40h
		cmp al,250
		ja lie
		mov square+2,ax
;---------------------generate rec-length--
chang:
		mov ah,0
		in al,40h
		cmp al,30
		jb chang
		mov bx,square+2
		mov dx,column
		sub dx,bx
		cmp dx,ax
		jae nextc
		sub dx,2
		mov ax,dx
nextc:
		mov square+4,ax
;---------------------generate rec-width--
kuan:
		mov ah,0
		in al,40h
		cmp al,20
		jb kuan
		mov bx,square
		mov dx,row
		sub dx,bx
		cmp dx,ax
		jae nextk
		sub dx,2
		mov ax,dx
nextk:
		mov square+6,ax
;---------------------generate color---
rcolor:
		in al,40h
		cmp al,250
		ja rcolor
		mov square+8,ax
		pop dx
		pop bx
		pop ax
		ret
random endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;------------------------------------
;--------------------generate rec----
SQUAR proc near
		push ax
		push dx
		push cx
		push di
		push si

		mov ah,0
		mov al,13h
		int 10h

		mov dx,square
		mov cx,square+2
		mov al,byte ptr square+8
		mov di,square+4
		add di,cx
		mov si,square+6
		add si,dx
hline:
		mov cx,square+2

hagain:
		mov ah,0ch
		mov bh,0
		int 10h
		inc cx
		cmp cx,di
		jl hagain
		add dx,1
		cmp dx,si
		jl hline
		pop si
		pop di
		pop cx
		pop dx
		pop ax
	ret
SQUAR endp
;---------------------------------------
delay proc near
		push dx
		push cx
		mov dx,50000
ynext:
		mov cx,50000
yagain:
		loop yagain
		dec dx
		jnz ynext
		pop cx
		pop dx
		ret
delay endp

;--------------------------------------
code ends
	end start



