data segment
org 1000h
vx dw 1280h
py dw vx
fpz dd py
data ends

code segment
assume cs:code,ds:data

start:
		mov ax,data
		mov ds,ax
		mov si,offset fpz
		mov cx,fpz

		mov si,[si]
		push [si+2]
		jmp word ptr [si]
code ends
end start
