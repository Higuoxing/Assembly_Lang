data segment

data ends

code segment
assume cs:code,ds:data,ss:stacks
start:
loop1:
		mov dl,0dh
		mov ah,02h
		int 21h

		mov dl,0bh
		mov ah,02h
		int 21h

		mov ah,01h
		int 21h
		mov dx,2a8h
		out dx,al
		jmp loop1
		
quit:
		mov ah,04ch
		int 21h

code ends
end start

