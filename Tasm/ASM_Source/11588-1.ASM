;***********************11588-1.ASM*************************
prot	equ       0dc00h-280h
proth	equ	  prot+280h
protlr	equ       prot+288h
protly	equ	  prot+290h
   
DATA      SEGMENT
MESS      DB  'Strike any key,return to DOS!',0AH,0DH,'$'
min1      DB  00h,01h,02h,03h,04h,05h,06h,07h
count     db  0
BUFF      DB  44h,54h,54h,7fh,54h,0dch,44h,24h
DATA      ENDS
;-----------------------------------------------------------
CODE      SEGMENT
ASSUME    CS:CODE,DS:DATA
;------------------------------------------------------------
START:    MOV   AX,DATA
          MOV   DS,AX
          MOV   DX,OFFSET MESS
          MOV   AH,09
          INT   21H                      ;显示提示信息
;------------------------------------------------------------
agn:	  mov	cx,80h
d2:	  mov	ah,01h
	  push	cx
	  mov	cx,0008h
	  mov	si,offset min1
next:     mov	al,[si]
	  mov	bx,offset buff
	  xlat                             ;得到第一行码
	  mov	dx,proth
	  out	dx,al
	  mov	al,ah
	  mov	dx,protlr
	  out	dx,al                       ;显示第一行红
	  shl	ah,01
	  inc	si
	  push	cx
	  mov	cx,0ffffh
delay2:	  loop  delay2                       ;延时
	  pop	cx
	  loop	next
	  pop	cx
	  call	delay
	  loop	d2
	  mov	al,00
	  mov	dx,protlr
	  out	dx,al
	  mov	ah,01                       ;有无键按下
	  int	16h
	  jnz	a2
	
agn1:	  mov	cx,80h                     ;agn1为显示黄色
d1:       mov	si,offset min1
	  mov	ah,01
	  push	cx
	  mov	cx,0008h
next1:	  mov	al,[si]
	  mov	bx,offset buff
	  xlat
	  mov	dx,proth
	  out	dx,al
	  mov	al,ah
	  mov	dx,protly
	  out	dx,al
	  shl	ah,01
	  inc	si
	  push	cx
	  mov	cx,0ffffh
delay1:	  loop  delay1
	  mov	cx,0ffffh
delay3:	  loop  delay3
	  pop	cx
	  loop	next1
	  pop	cx
	  call	delay
	  loop	d1
	  mov	al,00
	  mov	dx,protly
	  out	dx,al
	  mov	ah,01
	  int	16h
	  jnz	a2
	  jmp	agn                        ;黄色红色交替显示
;----------------------------------------------------------------	  
DELAY	  PROC	NEAR                           ;延迟子程序
	  push	cx
	  mov	cx,0ffffh
ccc:	  loop	ccc
	  pop	cx
	  ret
DELAY	  ENDP	  
;---------------------------------------------------------------------

a2:      MOV   AH,4CH                    ;返回
          INT   21H
CODE      ENDS
END       START
;----------------------------------------------------------
