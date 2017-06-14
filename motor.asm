
;-------------------------------------------------------------
;@Author    : GUO.XING(61015122)
;             Copyright(C) GuoXing 2017 all rights reserved
;@Date      : 2017/5/1 4:50PM
;-------------------------------------------------------------

;-------------------------------------------------------------
;						MACRO DEFINITIONS
;-------------------------------------------------------------

;-------------------------------------------------------------
;						SET POSITION
;-------------------------------------------------------------
setPos macro top,left  
		mov ah,02h  
		mov bx,0  
		mov dh,top  
		mov dl,left  
		int 10h  
		endm  

;-------------------------------------------------------------
;						SET MENU ATTR
;-------------------------------------------------------------
changeMenu macro top,left,width,attr  
		local chg  
		mov dl,left  
chg:  
		setPos top,dl  
		mov bh,0  
		mov ah,08h  
		int 10h  
		mov bl,attr  
		mov cx,1  
		mov ah,09h  
		int 10h  
		inc dl  
		mov al,left  
		add al,width  
		cmp dl,al  
		jne chg  
		setPos top,left  
		endm  

;-------------------------------------------------------------
;						DRAW WINDOW
;-------------------------------------------------------------
drawWindow macro attr,top,left,bottom,right  
		push ax  
		push bx  
		push cx  
		push dx  
		mov ah,06h  
		mov al,0  
		mov bh,attr  
		mov ch,top  
		mov cl,left  
		mov dh,bottom  
		mov dl,right  
		int 10h  
		pop dx  
		pop cx  
		pop bx  
		pop ax  
		endm  

;-------------------------------------------------------------
;						DRAW WINDOW SIDELINES(T,B)
;-------------------------------------------------------------
windowtandb macro l,m,r,top,left,width,attr  
		setPos top,left  
		outPutChar l,attr,1  
		setPos top,left+1  
		outPutChar m,attr,width-2  
		setPos top,left+width-1  
		outPutChar r,attr,1  
		endm  

;-------------------------------------------------------------
;						DRAW WINDOW SIDELINES(L,R) 
;-------------------------------------------------------------
windowlandr macro char,top,left,width,attr  
		setPos top,left  
		outPutChar char,attr,1  
		setPos top,left+width-1  
		outPutChar char,attr,1  
		endm  

;-------------------------------------------------------------
;						PRINT A CHAR
;-------------------------------------------------------------
outPutChar macro char,attr,num  
		push ax  
		mov bh,0  
		mov ah,09h  
		mov al,char  
		mov bl,attr  
		mov cx,num  
		int 10h  
		pop ax  
		endm  

;-------------------------------------------------------------
;						PRINT A STRING
;-------------------------------------------------------------
outPutStr macro str,num,top,left,attr  
		push ax  
		push bx  
		push bp  
		push cx  
		push dx  
		mov ah,13h  
		lea bp,str  
		mov cx,num  
		mov dh,top  
		mov dl,left  
		mov bh,0  
		mov al,1  
		mov bl,attr  
		int 10h  
		pop dx  
		pop cx  
		pop bp  
		pop bx  
		pop ax  
		endm  

;-------------------------------------------------------------
;						SUB-MENU
;-------------------------------------------------------------
subMenu macro left,menu1,num1,menu2,num2,menu3,num3,width  
		local menu  
		drawWindow 70h,1,left,5,left+width  
		windowtandb 0dah,0c4h,0bfh,1,left,width+1,70h  
		mov al,2  
menu:  
		windowlandr 0b3h,al,left,width+1,70h  
		inc al  
		cmp al,5;==================  
		jne menu  
		windowtandb 0c0h,0c4h,0d9h,5,left,width+1,70h  
		outPutStr menu1,num1,2,left+2,0fh  
		changeMenu 2,left+1,8,0fh  
		outPutStr menu2,num2,3,left+2,70h  
		changeMenu 3,left+2,1,74h  
		outPutStr menu3,num3,4,left+2,70h  
		changeMenu 4,left+2,1,74h  
		setPos 2,left+2  
		endm  

;-------------------------------------------------------------
;						READ SCREEN
;-------------------------------------------------------------
readScr macro left,memory  
		local read  
		sub ax,ax  
		mov si,ax  
read:  
		add ah,left  
		inc al  
		inc si  
		mov ch,ah  
		setPos al,ch  
		mov ah,08h  
		mov bh,0  
		int 10h  
		mov memory[si],al  
		mov memory[si+50],ah  
		mov ax,si  
		mov bl,10  
		div bl  
		cmp si,50  
		jne read  
		endm  

;-------------------------------------------------------------
;						WRITE SCREEN
;-------------------------------------------------------------
writScr macro left,memory  
		local read  
		sub ax,ax  
		mov si,ax  
read:  
		add ah,left  
		inc al  
		inc si  
		mov ch,ah  
		setPos al,ch  
		mov al,memory[si]  
		mov ah,memory[si+50]  
		mov dl,al  
		mov dh,ah  
		outPutChar dl,dh,1  
		mov ax,si  
		mov bl,10  
		div bl  
		cmp si,50  
		jne read  
		endm  

;-------------------------------------------------------------
;						SET CURSOR ATTR
;-------------------------------------------------------------
showCur macro show  
		push ax  
		push cx  
		mov ah,1  
		mov cl,0  
		mov ch,show  
		int 10h  
		pop cx  
		pop ax  
		endm

;-------------------------------------------------------------
;						DATA SEGMENT
;-------------------------------------------------------------
data segment
		ioport equ 0000h-280h
		io0832a equ ioport+2a0h
		io8255c equ ioport+282h
		io8255t equ ioport+283h
		speed db 0
		up db 'up',0dh,0ah,'$'
		down db 'down',0dh,0ah,'$'
		stop db 'stop',0dh,0ah,'$'
		licience db 'licience',0dh,0ah,'$'
data ends
;-------------------------------------------------------------
;						STACKS SEGMENT
;-------------------------------------------------------------
stacks segment
		stack db 100 dup(0)
stacks ends
;-------------------------------------------------------------
;						CODE SEGMENT
;-------------------------------------------------------------
code segment
assume cs:code,ds:data,ss:stacks
start:	
		mov ax,data
		mov ds,ax
		mov ax,stacks
		mov ss,ax

;-------------------------------------------------------------
;>>>>>>>>>>>>>>>>>>>>>>>MAIN LOOP<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;-------------------------------------------------------------
mainLoop:
;-------------------------------------------------------------
;						INITIALISE REGISTERS
;-------------------------------------------------------------
		xor ax,ax
		xor dx,dx
		xor cx,cx
		xor bx,bx
;-------------------------------------------------------------
;						LISTEN KEY INTERRUPT
;-------------------------------------------------------------
		mov dl,0ffh
		mov ah,06h
		int 21h
		cmp al,'a'				;shift up
		jz shiftUp
		cmp al,'z'				;shift down
		jz shiftDown
		cmp al,'s'				;stop
		jz stopP
		cmp al,'q'				;quit
		jz quit
		cmp al,'w'
		jz showLicience
		cmp al,'b'
		jz back
		cmp al,'l'
		jz licienceLoop
		jmp mainLoop


shiftUp:
;-------------------------------------------------------------
;						ADD CODE HERE
;-------------------------------------------------------------
		mov dx,offset up
		mov ah,09h
		int 21h
		jmp mainLoop

shiftDown:
;-------------------------------------------------------------
;						ADD CODE HERE
;-------------------------------------------------------------
		mov dx,offset down
		mov ah,09h
		int 21h
		jmp mainLoop

stopP:
;-------------------------------------------------------------
;						ADD CODE HERE
;-------------------------------------------------------------
		mov dx,offset stop
		mov ah,09h
		int 21h
		jmp mainLoop

showLicience:
		jmp mainLoop

back:
		jmp mainLoop

quit:
		mov ah,04ch
		int 21h

;-------------------------------------------------------------
;>>>>>>>>>>>>>>>>>>>>>>>LICIENCE LOOP<<<<<<<<<<<<<<<<<<<<<<<<<
;-------------------------------------------------------------
licienceLoop:
;-------------------------------------------------------------
;						DRAW WINDOWS HERE::ADD CODE
;-------------------------------------------------------------
;-------------------------------------------------------------
;						LISTEN KEY INTERRUPT
;-------------------------------------------------------------	
		mov dl,0ffh
		mov ah,06h
		int 21h
		cmp al,'b'
		jz mainLoop
		jmp licienceLoop

;-------------------------------------------------------------
;>>>>>>>>>>>>>>>>>>>>>>>HELP LOOP<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;-------------------------------------------------------------
helpLoop:
;-------------------------------------------------------------
;						DRAW WINDOWS HERE::ADD CODE
;-------------------------------------------------------------
;-------------------------------------------------------------
;						LISTEN KEY INTERRUPT
;-------------------------------------------------------------
		mov dl,0ffh
		mov ah,06h
		int 21h
		cmp al,'b'
		jz mainLoop
		jmp helpLoop

code ends
end start