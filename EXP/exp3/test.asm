data segment
ta db 00h,01h,02h,93h
data ends

code segment
assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	mov dx,offset ta
	mov di,00h
	add bl,[bx+di]10h
	mov ah,04ch
	int 21h
code ends
end start
