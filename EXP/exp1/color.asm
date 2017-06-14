;>>>>>>>>>>>>>>data segment>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
data segment
db 'welcome to masm!'
db 16 dup(00000010b)
db 16 dup(00100100b)
db 16 dup(11000010b)
data ends
;>>>>>>>>>>>>>>code segment>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
code segment
assume cs:code,ds:data
start:
		mov ax,data
		mov ds,ax
		mov bx,0
		mov cx,3
		mov di,0
;>>>>>>>>>>>>>>>>>>>init>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		mov ax,1011100000000000b
		mov es,ax
		mov si,1000
		mov dl,1

		mov ax,0003h
		int 10h

s0:		
		mov cx,16

s:		mov al,ds:[bx]
		mov es:[si],al
		mov al,ds:[bx+16+di]
		mov es:[si+1],al
		add si,2
		inc bx
		loop s

		add si,128
		add di,16
		mov bx,0
		inc dl
		cmp dl,4
		jz over
		loop s0
over:
		mov ah,04ch
		int 21h
code ends
end start
