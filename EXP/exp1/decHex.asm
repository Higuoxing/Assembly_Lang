data segment
right db 1
input db 6,7 dup(0)
output dw 0000h
ten dw 000ah
string1 db 0dh,0ah,'Please input your number(0-65535)',0dh,0ah,'$'
string2 db 0dh,0ah,'The number you input is (0000h-ffffh):',0dh,0ah,'$'
string3 db 0dh,0ah,'Do you want to continue?(Y/N)',0dh,0ah,'$'
string4 db 0dh,0ah,'ERROR,the number should be in range(0-65535)',0dh,0ah,'$'
data ends

stacks segment
	db 256 dup(0)
stacks ends

code segment
assume cs:code,ds:data,ss:stacks
main proc far
start:  mov ax,data
		mov ds,ax
		mov ax,stacks
		mov ss,ax
loop1:	mov output,0000h
		mov dx,offset string1
		mov ah,09h
		int 21h
		mov dx,offset input
    	mov ah,0ah
		int 21h
		mov right,1
		call change
		cmp right,0
		jz error
		mov dx,offset string2
		mov ah,09h
		int 21h
		mov ax,output
		mov dl,ah
		mov cl,4
		shr dl,cl
		call disp
		mov dl,ah
		and dl,0fh
		call disp
		mov dl,al
		mov cl,4
		shr dl,cl
		call disp
		mov dl,al
		and dl,0fh
		call disp
		jmp go
error:	mov dx,offset string4
		mov ah,09h
		int 21h
go:		mov dx,offset string3
		mov ah,09h
		int 21h
		mov ah,1
		int 21h
		cmp al,'y'
		jz loop1
		cmp al,'Y'
		jz loop1
		mov ah,4ch
		int 21h
main endp
change proc near
		clc
		xor ax,ax
		xor bx,bx
		xor dx,dx
		xor cx,cx
		mov cl,input[1]
		mov si,2
again:	mov bl,input[si]
		cmp bl,30h
		jb error1
		cmp bl,39h
		ja error1
		sub bl,30h
		dec cl
		cmp cl,0
		jz over
		mov ax,1
		push cx
loop2:	mul ten
		loop loop2
		pop cx
		mul bx
		add output,ax
		jc error
		inc si
		jmp again
over:	add output,bx
		jnc over1
error1: mov right,0
over1:	ret
change endp
disp proc near
		push dx
		push ax
		cmp dl,9
		jbe num
		add dl,7
num:	add dl,30h
		mov ah,02h
		int 21h
		pop ax
		pop dx
		ret
disp endp
		code ends
end start

