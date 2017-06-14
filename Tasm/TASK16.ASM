;4.0教材 实验A IA16分时调度；;任务相对独立，每次执行时间较短（有限）
;--------------------------------------------
;本程序接线：8253CS接280H， GATE0接+5V，OUT0接实验箱IRQ
;           8255CS接288H，PC0-PC7接开关K0-K7，PA0-PA7接数码管L0-L7
;           DAC0832CS接290H

;原理：中断来到时，通过判断中断计数单元的计数值来确定执行相应的任务
;设计三个任务，A任务2MS执行一次，B任务4MS执行一次，C任务4MS执行一次
;任务功能    A任务：在屏幕上显示其运行次数，B任务：用DAC0832产生正弦波；C任务：8255实现C口读入，A口输出
;开关K0打到1时返回DOS
;针对实验箱不同资源地址（中断号，TPC板卡地址，IO地址）需要改动四处：
;int_vect；irq_mask_2_7，irq_mask_9_15（两个中断掩码，相应为0时清屏蔽）
;ioport_cent（portr或点阵演示程序读取）
;另外修改ioport地址，核对8253，8255和DAC0832地址与接线相同（对应）
;-----------------------------------------------；
.286       ;为简短程序使用了PUSHA和POPA的80286指令
data segment
messstr   db 'the schedule task',0dh,0ah,'$'
messend   db 'set the k0 the "1" position to exit',0dh,0ah,'$'
msg1      db 'TPC PCI CARD INTERRUPT',0dh,0ah,'$'

  int_vect      EQU   72h;  0Bh;  071H      ;中断0-7的向量为:08h-0fh,中断8-15的向量为:70h-77h。这里用的是IRQ9，即中断号9   
 irq_mask_2_7   equ     011111011b      ;中断屏蔽字 中断0-7时从低至高相应位为零,中断8-15时第2位为零
 irq_mask_9_15  equ     011111011b      ;中断0-7时全一,中断8-15时从低至高相应位为零
;如中断号3则 中断屏蔽字分别为  011110111b和011111111b

 ioport_cent    equ     0E800h  ;tpc 卡中9054芯片的io地址

 csreg		dw	?
 ipreg		dw	?		;旧中断向量保存空间
 irq_times	dw	00h		;中断计数

dacpy           db      00h

pianyi  db  00h        ;行保存
colma   db  01h        ;列保存

;TASKA部分

tames1          db 'TaskA is running. ',0dh,0ah,'$'    
tames1len=$-tames1
ta_run_times    dw 00h                  ;taska运行次数
numbuff         db 30H,30H,30H,30H      ;次数ASCII码串
numbufflen=$-numbuff        ;长度（4）

ioport    equ  0EC00h-280h
io8253k   equ  ioport+283h
io82530   equ  ioport+280h
io82531   equ  ioport+281h
io8255a   equ  ioport+288h
io8255c   equ  ioport+28ah
io8255k   equ  ioport+28bh
io0832    equ  ioport+290H

tcmes1          db  'Hello from TaskC .',0dh,0ah,'$'

buff      DB  44h,54h,54h,7fh,54h,0dch,44h,24h


SINBUF    db    80h,96h,0aeh,0c5h,0d8h,0e9h,0f5h,0fdh
          db    0ffh,0fdh,0f5h,0e9h,0d8h,0c5h,0aeh,96h
          db    80h,66h,4eh,38h,25h,15h,09h,04h
          db    00h,04h,09h,15h,25h,38h,4eh,66h

cnt1      db  01h   ;TaskA控制计数器
cnt2      db  02h   ;TaskB控制计数器
cnt3      db  00h   ;TaskC控制计数器

data ends


stacks 	segment
		db 100 dup (?)
stacks ends

code segment
assume cs:code,ds:data
start:
        cli
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stacks
        mov ss,ax

        mov dx,ioport_cent+68h  ;设置 tpc 卡中9054芯片io口,使能中断
        in  ax,dx
        or  ax,0900h
        out dx,ax

        mov al,int_vect         ;保存原中断向量
	  mov ah,35h
        int 21h
	  mov ax,es
	  mov csreg,ax
	  mov ipreg,bx

        mov ax,cs               ;设置新中断向量
	  mov ds,ax
	  mov dx,offset int_proc
	  mov al,int_vect
	  mov ah,25h
        int 21h

        in      al, 21h         ;设置中断掩码
        and     al, irq_mask_2_7
        out     21h, al
        in      al, 0a1h
        and     al, irq_mask_9_15
        out     0a1h, al

        mov ax,data
        mov ds,ax
        lea dx,messstr       ;显示标题调度任务
        mov ah,09h
        int 21h

        lea dx,messend
        mov ah,09h
        int 21h
        mov dx,io8255k
        mov al,8bh
        out dx,al
        mov dx,io8253k        ;给计数器0写8253控制字，方式3，先写低字节，再写高字节
        mov al,36h
        out dx,al
        mov dx,io82530        ;给计数器0送初值1000
        mov ax,1000            ;8253的CLK0接1MHZ,1000分频后从OUT0输出的是1KHZ的方波
        out dx,al              ;将OUT0接到IRQ后，1ms产生一次中断
        mov al,ah
        out dx,al
        sti
;主程序---例行任务：循环执行直到K0高电平结束全部运行
loop1:
	cmp  cnt3,04h
     ; jnz   chka
      call  taskc
      mov   cnt3,00h
;     cmp irq_times,0            ;;终止方式2：中断若干次结束
 ;    jnz loop2
  ;   mov irq_times,06h
   ;  jmp loop1 

loop2:
     mov dx,io8255c                  ;从C口读数据，K0为1时返回DOS
     in  al,dx
     test al,01h
     jnz  exit
;    CALL  Taskn                    ;此处可插入任意任务
     jmp loop1           ;主循环

exit:                               ;终止程序运行
      cli
      mov     bl, irq_mask_2_7        ;恢复中断掩码
	not	bl
	in	al, 21h
	or	al, bl
	out	21h, al
	mov	bl, irq_mask_9_15
	not	bl
	in	al, 0a1h
	or	al, bl
	out	0a1h, al

      mov dx,ipreg                    ;恢复原中断向量
	mov ax,csreg
	mov ds,ax
	mov ah,25h
	mov al,int_vect
      int 21h

        mov dx,ioport_cent+68h          ;设置 tpc 卡中9054芯片io口,关闭中断
	in  ax,dx
      and ax,0f7ffh
	out dx,ax
  
     mov ah,4ch
     int 21h
;定时中断服务: 根据时间(软件定时器)调度
int_proc proc far
        cli
        pusha
        push ds
        push es

        inc cnt1
        inc cnt2
        inc cnt3
chka: cmp  cnt1,02h
      jnz  chkb
      call taska
      mov  cnt1,00h
      jmp  intend

chkb: cmp cnt2,04h
      jnz  chkc
      call taskb
      mov  cnt2,00h

chkc:; cmp  cnt3,04h
     ; jnz   chka
      call  taskc
      mov   cnt3,00h
    
intend:
      ;  mov ax,data             ;Interrupt to do
      ;  mov ds,ax
      ;	 mov dx,offset msg1
      ;	 mov ah,09h
      ;  int 21h

        mov al,20h              ;Send EOI
        out 0a0h,al
        out 20h,al
        pop es
        pop ds
;        pop dx
        popa
    sti
        iret
int_proc endp

;任务A
taska proc near

  push ax
  push bx
  push cx
  push dx
  push ds
  push es
  push bp
  push si
  push di
      MOV  AX,data 
      mov  ds,ax  
      MOV  ES,AX
;      MOV AH,0      ;清屏
;      MOV AL,03H
;      INT 10H

      LEA  BP,tames1
      MOV  DX,1700H
      MOV  BH,0
      MOV  CX,tames1len
      MOV  AL,0
      MOV  BL,0D2H
      MOV  AH,13H
      INT  10H      
;  lea dx,tames1
;  mov ah,09h
;  int 21h

  inc ta_run_times
  cmp ta_run_times,0ffffh
  jnz tdisp
 
  
zerot: mov ta_run_times,01h

tdisp:  mov ax,ta_run_times
        call disp ;convert to ASCII

      LEA  BP,numbuff
      MOV  DX,1740H
      MOV  BH,0
      MOV  CX,numbufflen
      MOV  AL,0
      MOV  BL,0D2H
      MOV  AH,13H
      INT  10H      ;display on VRAM：ROW=17H：Collum=40H
 
  pop di
   pop si
  pop bp
  pop es
  pop ds
  pop dx
  pop cx
  pop bx
  pop ax
    ret 
taska endp

;次数HEX转换成ASCII码串存入numbuff子程序
;入口: AX=运行次数

DISP PROC NEAR
   push dx
   push cx
   push bx
   push si

   mov  cx,4
   mov  bx,16
    lea si,numbuff
dloop1:
   push ax
   push cx
   sub  bx,4
   mov  cx,bx
   shr  ax,cl
   and  al,0fh     ;首先取低四位
   mov  dl,al
   
   cmp dl,9        ;30h-39h:0-9;A-F:41-46H;a-f:61-66h
   jle num1           
   ADD dl,7   
num1:
   ADD dl,30h
  
   mov [si],dl
   inc si

  ; mov ah,02h
  ; int 21h
   pop cx
   pop ax
   loop dloop1
   pop si
   pop  bx
   pop  cx
   pop  dx
   
   ret            ;子程序返回
DISP ENDP

taskb proc near
  ; push ax
  ; push dx
pusha
  ; lea dx,tbmes1
  ; mov ah,09h
  ; int 21h


          
   lll:     
            mov     dx,io0832          ;DAC0832地址
            lea     bx,SINBUF
            mov     al,dacpy
            xlat
            out      dx,al
         ;   call      WaveOutDelay
            mov   ah,dacpy   
            inc   ah   
            cmp    ah,32
            je    rsetdacpy
            jmp      setdacpy
rsetdacpy:   mov    ah,00h
setdacpy:    mov    dacpy,ah
          ;   jmp      lll
            


 popa  
 ;  pop dx
 ;  pop ax
    ret
taskb endp


taskc proc near
   push ax
   push dx
inout:    mov dx,io8255c             ;从C口输入一数据
	  in al,dx
	  mov dx,io8255a             ;从A口输出刚才自C口
	  out dx,al               ;所输入的数据
       ;   jmp aa1
   pop  dx
   pop  ax
   ret
taskc endp

code ends
end  start

