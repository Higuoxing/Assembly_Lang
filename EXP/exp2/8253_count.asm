ioport equ 0c00h-0280h
io8253a equ ioport+283h
io8253b equ ioport+280h ;count channel 0

stacks segment:
stack db 100 dup(?)
stacks ends

code segment
assume cs:code,ss:stacks
main proc far
start:	
		mov ax,stacks
		mov ss,ax
		mov al,10h
		mov dx,io8253a
		out dx,al
		mov dx,io8253b
		mov al,0fh
		out dx,al

zzz: 
		in al,dx
		call disp
		push dx
		mov ah,06h
		mov dl,0ffh
		int 21h
		pop dx
		jz zzz
		mov ah,04ch
		int 21h
main endp

disp proc near
		push dx
		and al,0fh
		mov dl,al
		cmp dl,9
		jle num
		add dl,7

num:
		mov ah,02h
		int 21h
		mov al,0dh
		int 21h
		mov dl,0ah
		int 21h
		pop dx
		ret

disp endp
code ends
end start
		
