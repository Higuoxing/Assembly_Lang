;***********************************;
;*    十字路口红绿灯模拟演示程序   *;
;* 端口各灯的设置:                 *;
;*   1红 1黄 1绿 0 0 2红 2黄 2绿   *;
;***********************************;
data segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+28ah
io8255b		equ ioport+28bh
portc1  db  24h,44h,04h,44h,04h,44h,04h   ;六个灯可能
	db  81h,82h,80h,82h,80h,82h,80h   ;的状态数据
	db  0ffh                          ;结束标志
data ends
code  segment
      assume  cs:code,ds:data
start:
	mov   ax,data
	mov   ds,ax
	mov   dx,io8255b
	mov   al,90h
	out   dx,al           ;设置8255为C口输出
	mov   dx,io8255a
re_on:	mov   bx,0
on:	mov   al,portc1[bx]
	cmp   al,0ffh
	jz    re_on
	out   dx,al           ;点亮相应的灯
	inc   bx
	mov   cx,20           ;参数赋初值
	test  al,21h          ;是否有绿灯亮
	jz    de1             ;没有,短延时
	mov   cx,2000         ;有,长延时
de1:	mov   di,9000         ;di赋初值5000
de0:	dec   di              ;减1计数
	jnz   de0             ;di不为0
	loop  de1
	push dx
	mov ah,06h
	mov dl,0ffh
	int 21h
	pop dx
	jz  on                ;没有,转到on
exit:	mov   ah,4ch          ;返回
	int   21h
code ends
	end start
