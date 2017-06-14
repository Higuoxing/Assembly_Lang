data segment
blk1 db 47,81,32,-1,20,122,73,255,0,55h,0aah

data ends
code segment
assume cs:code,ds:data

start:
		mov ax,data
		mov ds,ax
		mov cx,7
		lea si,blk1
next:
		mov al,[si]
		inc si
		cmp al,0
		jz finish
		test al,81h
		jnz next
finish:
		mov bl,[si]
		xor si,si
		mov ah,04ch
		int 21h
code ends
end start
