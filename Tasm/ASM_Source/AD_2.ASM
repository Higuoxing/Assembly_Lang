;****************************;
;*     AD转换器2--示波器    *;
;*   采集数据在屏幕是作图   *;
;****************************;
ioport		equ 0d400h-0280h
io0809b		equ ioport+299h
code segment
	assume    cs:code
start:	mov ax,0012h          ;设屏幕显示方式为VGA 640X480模示
	int 10h
start1:
	mov ax,0600h
	int 10h			;清屏
	and cx,0              ;cx为横坐标
draw:	mov dx,io0809b           ;启动A/D转换器通道1
	out dx,al
	mov bx,500            ;延时
delay:	dec bx
	jnz delay
	in al,dx              ;读入数据
	mov ah,0
	mov dx,368           ;dx为纵坐标
	sub dx,ax
	mov al,0ah            ;设置颜色
	mov ah,0ch            ;画点
	int 10h
	cmp cx,639            ;一行是否满
	jz start1             ;是则转start
	inc cx                ;继续画点
	push dx
	mov ah,06h            ;是否有键按下
	mov dl,0ffh
	int 21h
	pop dx
	je draw               ;无,则继续画点
	mov ax,0003           ;有恢复屏幕为字符方式
	int 10h
	mov ah,4ch            ;返回
	int 21h
code ends
end start
