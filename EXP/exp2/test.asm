data segment

data ends

stacks segment

stacks ends

code segment
assume cs:code,ds:data,ss:stacks
start:
		mov ax,data
		mov ds,ax
		mov ax,stacks
		mov ds,ax

main proc far
s:		
		mov bl,0001b
		mov dl,bl
		mov ah,02h
		int 21h
		shl	bl,1
		mov dl,bl
		mov ah,02h
		int 21h	
		mov ah,04ch
		int 21h
main endp

code ends
end start
