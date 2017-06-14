assume cs:code
code segment
start:
loop1:
		mov dl,0dh
		mov ah,02h
		int 21h

		mov dl,0ah
		mov ah,02h
		int 21h

		mov dx,2a0h
		in al,dx
		mov dl,al
		mov al,02h
		int 21h

		cmp al,0ffh
		jnz loop1
		mov ah,04ch
		int 21h
code ends
end start
