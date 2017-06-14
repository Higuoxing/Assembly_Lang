data segment
tip1 db 0dh,0ah,'Please input your string1:',0dh,0ah,'$'
tip2 db 0dh,0ah,'Please input your string2:',0dh,0ah,'$'
res1 db 0dh,0ah,'Match',0dh,0ah,'$'
res2 db 0dh,0ah,'No Match',0dh,0ah,'$'
tip3 db 0dh,0ah,'Continue?(Y/N)',0dh,0ah,'$'
string1 db 40,256 dup(0)
string2 db 40,42 dup(0)
key db 'y'
mat db 1 
data ends

code segment
assume cs:code,ds:data
main proc far
start:	mov ax,data
		mov ds,ax
looper:
		mov dx,offset tip1 
		mov ah,09h
		int 21h

		mov dx,offset string1
		mov ah,0ah
		int 21h

		mov dx,offset tip2
		mov ah,09h
		int 21h

		mov dx,offset string2
		mov ah,0ah
		int 21h
		mov mat,1
		call check
		cmp mat,1
		jz match
		jmp noMatch
noMatch:
		mov dx,offset res2
		mov ah,09h
		int 21h
		jmp go
match:	
		mov dx,offset res1
		mov ah,09h
		int 21h
		jmp go
go:
		mov dx,offset tip3
		mov ah,09h
		int 21h
		
		mov dx,offset key
		mov ah,01h
		int 21h
		cmp al,'y'
		jz looper
		jnz quit
quit:
		mov ah,04ch
		int 21h
		
main endp

check proc near:
		clc
		xor dx,dx
		xor ax,ax
		xor cx,cx
		xor bx,bx
		mov dl,string1[1]
		mov bl,string2[1]
		cmp dl,bl
		jnz nomat
		mov cl,string1[1]		
		mov si,2
loop1:	
		mov dl,string1[si]
		mov bl,string2[si]
		cmp dl,bl
		jnz nomat
		dec cl
		inc si
		cmp cl,0
		jnz loop1
		jmp maty

nomat:	mov mat,0
		ret
maty:   mov mat,1
		ret
check endp

code ends
end start
