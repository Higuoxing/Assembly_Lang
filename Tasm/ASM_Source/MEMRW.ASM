;386以上微机适用
;纯dos下才能使用
;tasm4.1或以上编译
;***********************;
;*     存储器读写      *;
;***********************;
data SEGMENT
	mem_data	equ	0f6000000h	;tpc 卡中设备的mem地址
        msg1    DB      0dh,0ah,'TPC pci card memory!',0dh,0ah,'$'
	gdt_def	DW	00h,00h,00h,00h	;全局描述符表GDT，第一段空
		DW	0ffffh		;全局描述符表GDT，第二段，段界限低16位
		DW	00h		;基地址低16位
		DB	00H,92H		;基地址中间8位，段属性
		DB	8FH,00H		;段界限的高4位(包括段属性的高4位)，基地址的高8位
	gdt_addr DW	00h	;存放GDT的长度(以字节为单位的长度-1)
		DW	00H,00H	;存放GDT的线性基地址
data ENDS
code SEGMENT
        ASSUME CS:code,DS:data,SS:data,ES:data
start:
.386p
        call opena20	;打开a20地址线
        mov ax,data
        mov ds,ax
        call set4gb	;进入保护模式重设段界限为4GB后返回实模式

	mov ax,0
	mov ds,ax
        mov esi,mem_data
        mov cx,100h
        mov dl,40h
loop1:
	inc dl
        mov [esi],dl
        add esi,1
        cmp dl,5ah
        jnz loop2
        mov dl,40h
loop2:
	loop loop1	;向tpc卡的存储空间反复写256个a-z

	mov ax,0
	mov ds,ax
        mov esi,mem_data
        mov cx,100h
loop3:
        mov dl,[esi]
        mov ah,02h
        int 21h
        add esi,1
        loop loop3	;从tpc卡的存储空间读256个字节内容并显示

	mov ax,data
	mov ds,ax
	MOV DX,OFFSET msg1
	MOV AH,09h
	INT 21h
        call closea20
	mov ax,4c00h
	int 21h

set4gb proc	;进入保护模式从设段界限为4GB后返回实模式
        CLI
        PUSH    DS
	PUSH	ES
        MOV     WORD PTR GDT_Addr[0], (2*8-1)	;   //GDT的长度存入GDT_Addr中
        MOV     EAX,DS		;  //计算GDT描述符表的线性基地址31-0
        SHL	EAX,4		;  //段地址eax=ds×16
        XOR	EBX,EBX		;  //ebx清零
        MOV	BX,OFFSET GDT_def	;   //bx=GDT的偏移地址
        ADD	EAX,EBX		;  //GDT的线性基地址=eax+ebx
        MOV	dword PTR GDT_Addr[2],EAX	;   //GDT的线性基地址存入GDT_Addr中
        lgdt	qword PTR GDT_Addr
        MOV	BX,8		;  //设置数据段描述符的选择字
        MOV	EAX,cr0
        OR	AL,1
        MOV	cr0,EAX
        JMP	flush1	;使保护模式下代码段的选择子装入CS，进入保护模式
flush1:
        MOV	DS,BX	;       //DS装载具有4GB界限的数据段描述符
        MOV	ES,BX	;       //ES装载具有4GB界限的数据段描述符
        AND	AL,0feh
        MOV	cr0,EAX
        JMP	flush2	;清指令预取队列，使实模式下代码段的段值装入CS，进入实模式
;              //返回实方式
flush2:
        POP	ES
	POP	DS
        STI
	ret
set4gb endp

opena20 proc	;打开a20地址线
                push    ax
                in      al,92h
                or      al,00000010b
                out     92h,al
                pop     ax
		ret
opena20 endp

closea20 proc	;关闭a20地址线
                push    ax
                in      al,92h
                and     al,11111101b
                out     92h,al
                pop     ax
		ret
closea20 endp

code ENDS
END start
