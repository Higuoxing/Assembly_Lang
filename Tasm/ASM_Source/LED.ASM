;386以上微机适用
;tasm4.1或以上编译
;****************************;
;* LED段位控制显示实验(I/O) *;
;****************************;
 ioport	equ 0d400h-280H
 PORTSEG	EQU ioport+2b1H	;数码管端口地址,段码地址
 PORTBIT	EQU ioport+2b0H	;数码管端口地址,位码地址
data segment
 BIT6     DB        0   ;1段显示数字
 BIT5     DB        0   ;2段显示数字
 BIT4     DB        0   ;3段显示数字
 BIT3     DB        0   ;4段显示数字
 BIT2     DB        0   ;5段显示数字
 BIT1     DB        0   ;6段显示数字
 LED      DB        3FH,06,5BH,4FH,66H,6DH,7DH,07,7FH,6FH   ;LED段码表，1,2,3,4,5,6,7,8,9,0
 MES      DB        'DISPLAY THE LEDS,PRESS ANY KEY TO EXIT!',0AH,0DH,'$'
data ends
stacks segment stack	;堆栈空间
 db 100 dup (?)
stacks ends
code segment
        assume cs:code,ds:data,ss:stacks,es:data
start:
.386
        cli
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stacks
        mov ss,ax
	MOV  DX,OFFSET MES	;显示提示
	MOV  AH,09
	INT  21H
loop1:
	call DISP_proc		;调用显示程序
	mov ah,1
	int 16h
        jz loop1                ;按任意键退出
	mov ax,4c00h
	int 21h		;退出

DISP_proc proc near
	pusha
	push ds		;保存寄存器值
	MOV       AX,DATA
	MOV       DS,AX
        MOV       DI,OFFSET BIT6        ;获取显示段起始地址
	MOV       CL,01			;设置显示位码
DIS1:   MOV       AL,[DI]		;获取显示数字
	MOV       BX,OFFSET LED		;获取段码表起始地址
	XLAT				;获取待显示数字的段码
	MOV  DX,PORTSEG
        OUT       DX,AL		;输出显示数据，段码
        MOV       AL,CL
        MOV  DX,PORTBIT
	OUT       DX,AL		;输出显示数据，位码，打开显示
	PUSH      CX
        MOV       CX,0A000H     ;显示时间延迟
DELAY:  LOOP      DELAY
	POP       CX
        CMP       CL,020H	;段码显示完否,6位
	JZ        CHG
	INC       DI
	SHL       CL,1
	MOV       AL,00
	OUT       DX,AL		;关闭显示
	JMP       DIS1		;显示下一段码
CHG:    INC       BIT1		;1段数字自增
	CMP       BIT1,10	;进位否
	JL        QUIT		;不进位则退出
	MOV       BIT1,0	;进位，1段数字清零
	INC       BIT2		;进位，2段数字自增
	CMP       BIT2,10
	JL        QUIT
	MOV       BIT2,0	;进位，2段数字清零
	INC       BIT3		;进位，3段数字自增
	CMP       BIT3,10
	JL        QUIT
	MOV       BIT3,0	;进位，3段数字清零
	INC       BIT4		;进位，4段数字自增
	CMP       BIT4,10
	JL        QUIT
	MOV       BIT4,0	;进位，4段数字清零
	INC       BIT5		;进位，5段数字自增
	CMP       BIT5,10
	JL        QUIT
	MOV       BIT5,0	;进位，5段数字清零
	INC       BIT6		;进位，6段数字自增
	CMP       BIT6,10
	JL        QUIT
	MOV       BIT6,0	;进位，6段数字清零	
QUIT:
        MOV  DX,PORTBIT
        MOV       AL,00
        OUT       DX,AL		;关闭显示
        pop ds
	popa			;恢复寄存器值
	ret
DISP_proc endp
code ends
end start
