data segment
input db 100,101 dup(0)
string1 db 0dh,0ah,'please input your strings',0dh,0ah,'$'
string2 db 0dh,0ah,'the strings you input is:',0dh,0ah,'$'
string3 db 0dh,0ah,'Do you want to continue?(Y/N)',0dh,0ah,'$'
data ends

stacks segment
stack db 256 dup(0)
stacks ends

code segment 
assume cs:code,ds:data,ss:stacks
main proc far
start: mov ax,data
    mov ds,ax

loop1:mov dx,offset string1
	mov ah,09h
	int 21h
	mov dx,offset input
	mov ah,0ah
	int 21h
	mov dx,offset string2
	mov ah,09h
	int 21h
	call disp
    mov dx,offset string3
    mov ah,09h
	int 21h
	mov ah,01h
	int 21h
	cmp al,'y'
	jz loop1
	mov ah,4ch
	int 21h
main endp

disp proc near
	xor cx,cx
	mov cl,input[1]
	mov si,2

again:mov dl,input[si]
	cmp dl,61h
	jb next
	cmp dl,7ah
	ja next
	sub dl,20h
next:mov ah,02h
	int 21h
	inc si
	loop again
	ret

disp endp
	code ends
end start

