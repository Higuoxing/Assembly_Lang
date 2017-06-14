data segment
inport equ 2a0h
outport equ 2a8h
spd db 1
dir db 1
data ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
stacks segment

stacks ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
code segment
assume cs:code,ds:data,ss:stacks
start:
		mov ax,data
		mov ds,ax
		mov ax,stacks
		mov ss,ax
;------------main------------------
main proc far
		
		
main endp
;-----------delay------------------
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
;---------------------------------
code ends
end start
