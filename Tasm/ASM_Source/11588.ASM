;***********************11588.ASM*************************
prot	  equ   0dc00h-280h
proth	  equ	prot+280h
protlr	  equ   prot+288h
protly	  equ	prot+290h
   
DATA      SEGMENT
MESS      DB  'Strike any key,return to DOS!',0AH,0DH,'$'
COUNT     DB  07
COUNT1    DW  0000
BUFF      DB  24h,22h,3bh,2ah,0feh,2ah,2ah,22h
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
agn:	  mov	al,0ffh
	  mov	dx,proth
	  out	dx,al
	  mov	ah,01
	  mov	cx,0008h
agn1:	  mov	dx,protlr
	  mov	al,ah
	  out	dx,al                     ;红行亮
	  push	cx
	  mov	cx,0030h
d5:	  call	delay1
	  loop	d5
	  pop	cx
	  shl	ah,01
	  loop	agn1
	  mov	ah,01
	  int	16h
	  jnz	a2
	 
;---------------------------------------------------------------------
	  mov	ah,01
	  mov	cx,0008h
agn2:	  mov	dx,protly
	  mov	al,ah
	  out	dx,al
	  push	cx
	  mov	cx,0050h                     ;黄行亮
d4:	  call	delay1
	  loop	d4
	  pop	cx
	  shl	ah,01
	  loop	agn2
	  mov	ah,01
	  int	16h
	  jnz	a2	  
;------------------------------------------------------------------------
	  mov	al,0ffh
	  mov	dx,protlr
	  out	dx,al                       ;红列亮
	  mov	ah,01
	  mov	cx,0008h
agn3:	  mov	dx,proth
	  mov	al,ah
	  out	dx,al
	  push	cx
	  mov	cx,0030h
d2:	  call	delay1
	  loop	d2
	  pop	cx
	  shl	ah,01
	  loop	agn3
	  mov	al,00h
	  mov	dx,protlr
	  out	dx,al
	  mov	ah,01
	  int	16h
	  jnz	a2
;----------------------------------------------------------------------
	  mov	al,0ffh
	  mov	dx,protly
	  out	dx,al                          ;黄列亮
	  mov	ah,01
	  mov	cx,0008h
agn4:	  mov	dx,proth
	  mov	al,ah
	  out	dx,al
	  push	cx
	  mov	cx,0050h
d1:	  call	delay1
	  loop	d1
	  pop	cx
	  shl	ah,01
	  loop	agn4
	  mov	ah,01
	  int	16h
	  jnz	a2
	  jmp	agn
;---------------------------------------------------------------------
DELAY1	  PROC	NEAR                           ;延迟子程序
	  push	cx
	  mov	cx,0ffffh
ccc:	  loop	ccc
	  pop	cx
	  ret
DELAY1	  ENDP	  
;--------------------------------------
a2:       MOV   AH,4CH                       ;返回
          INT   21H
CODE      ENDS
END       START
;----------------------------------------------------------
