data segment
tip1 db 0dh,0ah,'Please input your hex number(4bits):',0dh,0ah,'$'
tip2 db 0dh,0ah,'The result is:',0dh,0ah,'$'
tip3 db 0dh,0ah,'continue?(Y/N)',0dh,0ah,'$'
tip4 db 0dh,0ah,'restart?(Y/N)',0dh,0ah,'$'
warning db 0dh,0ah,'ERROR',0dh,0ah,'$'
input db 5,6 dup(0)	;get number from keyboard
res	db 5,6	dup(0)	;store the trans result
output db 17,18 dup(0);print the result
rflag db 1			;indicates the number is allowed
data ends

stacks segment
stack db 256 dup(0)
stacks ends

code segment
assume cs:code,ds:data
start:
		mov ax,data
		mov ds,ax
		mov ax,stacks
		mov ss,ax
;>>>>>>>>>>>init>>>>>>>>>>>>>>>>
main proc far
mainLoop:
		mov dx,offset tip1
		mov ah,09h
		int 21h

		mov dx,offset input
    	mov ah,0ah
		int 21h

		call check
		cmp rflag,0
		jz error
		call trans
		call print

		mov dx,offset tip3
		mov ah,09h
		int 21h

		mov ah,01h
		int 21h
		cmp al,'y'
		jz mainLoop
		cmp al,'Y'
		jz mainLoop
		jmp quit

error:
		mov rflag,0
		mov dx,offset warning
		mov ah,09h
		int 21h
		mov dx,offset tip4
		mov ah,09h
		int 21h
		mov ah,01h
		int 21h
		cmp al,'y'
		jz mainLoop
		cmp al,'Y'
		jz mainLoop
		jmp quit
quit:		
		mov ah,04ch
		int 21h
main endp
;>>>>>>>>>>>>sub proc_check>>>>>>>>>>>>
check proc near
		mov si,1
checkLoop:
		inc si
;-----------cmp 1-9---------------------
		mov dl,input[si]
		cmp dl,00110000b
		jb checkError
		cmp dl,00111010b
		jb match
;-----------cmp A-Z---------------------
		cmp dl,01000001b
		jb checkError
		cmp dl,01000111b
		jb match
;-----------cmp a-z---------------------
		cmp dl,01100001b
		jb checkError
		cmp dl,01100110b
		ja checkError
match:
		mov rflag,1
		cmp si,5
		jb checkLoop
		ret
checkError:
		mov rflag,0
		ret
check endp
;>>>>>>>>>>>>sub proc_trans>>>>>>>>>>>>
trans proc near
		mov si,1
transLoop:
		inc si
		mov dl,input[si]
;------------cmp 1-9-------------------
		cmp dl,00111010b
		jb numTrans
;------------cmp A-Z-------------------
		cmp dl,01000111b
		jb charCapTrans
;------------cmp a-z-------------------
		cmp dl,01100111b
		jb charLowTrans
;------------trans---------------------
numTrans:
		sub dl,30h
		mov res[si],dl
		jmp done
charCapTrans:
		sub dl,37h
		mov res[si],dl
		jmp done
charLowTrans:
		sub dl,57h
		mov res[si],dl
		jmp done
;----------------done------------------
done:
		cmp si,5
		jb transLoop
		ret
trans endp
;>>>>>>>>>>>>>sub proc_print>>>>>>>>>>>
print proc near
		mov si,1
		mov di,1
divMainLoop:
		xor dx,dx
		xor ax,ax
		
		mov cl,4
		inc si
		mov al,res[si]
divSubLoop:
		mov bl,2
		xor ah,ah
		div bl
		push ax
		dec cl
		cmp cl,0
		ja divSubLoop
		mov cx,4
		jmp subDone
subDone:
		inc di
		pop dx
		add dh,30h
		mov output[di],dh
		loop subDone
		cmp si,5
		jb divMainLoop
		jmp printBin
printBin:
		mov output[20],'$'
		mov dx,offset output
		mov ah,09h
		int 21h
		ret
print endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
code ends
end start
