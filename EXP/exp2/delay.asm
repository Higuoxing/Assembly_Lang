data segment
tip db 0dh,0ah,'1',0dh,0ah,'$'
tip2 db 0dh,0ah,'done',0dh,0ah,'$'
data ends

stacks segment
stack db 256 dup(0)
stacks ends

code segment
assume cs:code,ds:data,ss:stacks
start:
		mov ax,data
		mov ds,ax
main proc far
		call delay
		mov ah,04ch
		int 21h
main endp

delay proc near
		mov cx,10000
s:
		mov bx,2
s1:
		dec bx
		cmp bx,1
		jnz s1
		dec cx
		cmp cx,1
		jnz s
		ret
delay endp

code ends
end start
