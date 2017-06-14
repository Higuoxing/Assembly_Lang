data segment
tip1 db 0dh,0ah,'Please input the factorized number',0dh,0ah,'$'
tip2 db 0dh,0ah,'The result is:',0dh,0ah,'$'
tip3 db 0dh,0ah,'continue?(Y/N)',0dh,0ah,'$'
tip4 db 0dh,0ah,'restart?(Y/N)',0dh,0ah,'$'
warning db 0dh,0ah,'ERROR',0dh,0ah,'$'
res db 256 dup(0)
output db 256 dup(0)
i dw 0
j dw 0
k dw 0
carry dw 0
len dw 1
temp db 0
n dw 0
data ends

stacks segment
stack db 256 dup(0)
stacks ends

code segment
assume cs:code,ds:data
start:

;>>>>>>>>>>>init>>>>>>>>>>>>>>>>
		mov ax,data
		mov ds,ax
		mov ax,stacks
		mov ss,ax

;>>>>>>>>>>>main proc>>>>>>>>>>>
main proc far

mainLoop:
		mov dx,offset tip1
		mov ah,09h
		int 21h

		call inProc
		call factor
		mov dx,offset output
		mov ah,09h
		int 21h
		jmp continue

over:
		mov ah,04ch
		int 21h

main endp

;>>>>>>>>>>input proc>>>>>>>>>>
inProc proc near

		xor ax,ax
		xor bx,bx
		xor cx,cx
		mov cl,0
		push bx

inLoop:
		mov ah,01h
		int 21h

		mov dl,al
		cmp dl,0dh			;check return
		jz done

        cmp dl,30h			;check number
		jb inError
		cmp dl,39h
		ja inError

		sub dl,30h
		pop bx
		mov al,10
		mul bl
		mov bl,al
		xor bh,bh
		add bl,dl
		push bx
		jmp inLoop

inError:
		mov dx,offset warning
		mov ah,09h
		int 21h
		jmp continue
		
done:
		pop ax
		cmp ax,0
		jz zeroC
		
		dec ax
		mov n,ax
		ret
zeroC:
		mov output[1],31h
		mov output[2],'$'
		mov dx,offset output
		mov ah,09h
		int 21h
		jmp continue

restart:
		jmp mainLoop

continue:
		mov dx,offset tip4
		mov ah,09h
		int 21h
		mov ah,01h
		int 21h
		cmp al,'y'
		jz restart
		jmp over

inProc endp

;>>>>>>>>>>>>factor>>>>>>>>>>>>>>
factor proc near
;-----------0 - 1 case------------
		cmp n,31h
		ja znext

znext:
;----------init------------------
		mov i,0
		mov j,0
		mov k,0

		mov carry,0
		mov len,1
		mov temp,0
		mov res[1],1

		mov i,0
		mov si,i

prepLoop:
		inc si
		mov i,si
		mov carry,0

		mov j,0
		mov di,j

prepSubLoop:
		inc di

		mov bl,res[di]
		mov ax,si
		mul bl
		add ax,carry
		mov bl,10
		div bl
		mov res[di],ah
		xor ah,ah
		mov carry,ax

		mov j,di
		cmp di,len
		jb prepSubLoop	

whileLoop:
		cmp carry,0
		jz pass
		mov ax,carry
		mov bl,10
		div bl
		mov di,len
		inc di
		mov res[di],ah
		mov len,di
		xor ah,ah
		mov carry,ax
		mov di,j
		jmp whileLoop
		
pass:
		cmp si,n
		jbe prepLoop

store:
		mov si,len
		mov di,1

printLoop:
		mov dl,res[si]
		add dl,30h
		mov output[di],dl
		inc di
		dec si
		cmp si,0
		ja printLoop
		inc di
		mov output[di],'$'
		ret

factor endp

code ends
end start
