
code segment
assume cs:code
start:
		mov al,13h
		mov ah,0
		int 10h
		mov cx,10
		mov dx,20
		int 10h
		mov ah,04ch
		int 21h
code ends
end start
