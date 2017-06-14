ioport equ 0d400h-280h
io8255a equ ioport+288h
io8255c equ ioport+28ah
io8255k equ ioport+28bh

stacks segment:
stack db 100 dup(?)
stacks ends

code segment
assume cs:code,ss:stacks

main proc far
start:
		mov ax,stack
		mov ss,ax
		mov dx,io8255k
		mov al,8bh
		out dx,al

input:
		mov dx,io8255c
		in al,dx
		mov dx,io8255a
		out dx,al
		mov dl,0ffh
		mov ah,06h
		int 21h
		jz input
		mov ah,04ch
		int 21h
main endp
code ends
end start
