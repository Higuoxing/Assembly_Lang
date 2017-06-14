data segment
ioport equ 0c00h-0280h
io8253a equ ioport+0283h
io8253b equ ioport+0280h ;count channel 0
led db 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh
buffer1 db 5,6
bz dw ?
data ends

stacks segment:
stack db 100 dup(?)
stacks ends

code segment
assume cs:code,ss:stacks,ds:data
main proc far
start:	
		mov ax,stacks
		mov ss,ax
		mov ax,data
		mov dx,ax
		mov dx,io8255k
		mov al,80h
		out dx,al
		mov dx,offset buffer1

loop2:
		mov bh,02
lll:
		mov al,0
		mov dx,io8255a
		out dx,al
		mov byte ptr bz,bh
		push di
		dec di
		add di,bz
		mov bl,[di]
		pop di
		mov bh,0
		mov si,0ffset led
		add si,bx
		mov al,byte ptr bz
		mov dx,io8255c
		out dx,al
		mov cx,3000

delay:
		loop delay
		mov bh,byte ptr bz
		shr bh,1
		jnz lll
		mov dx,0ffh
		mov ah,06
		int 21h
		je loop2
		mov dx,io8255c
		mov al,0
		out dx,al
		mov ah,04ch
		int 21h
code ends
end start
