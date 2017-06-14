data segment
input db 256 dup(0)
tip1 db 0dh,0ah,'Please input you numbers:',0dh,0ah,'$'
tip2 db 0dh,0ah,'continue?(Y/N)',0dh,0ah,'$'
data ends

stacks segment
stack db 256 dup(0)
stacks ends

code segment
assume ds:data,ss:stacks,cs:code
start:
;------------init-------------
		mov ax,data
		mov ds,ax
		mov ax,stacks
		mov ss,ax
;-------------main------------
main proc far
		mov dx,offset tip1
		mov ah,09h
		int 21h

		call getNum

		mov ah,04ch
		int 21h
main endp

getNum proc near
		mov dx,offset input
		mov ah,0ah
		int 21h
		ret
getNum endp
code ends
end start
