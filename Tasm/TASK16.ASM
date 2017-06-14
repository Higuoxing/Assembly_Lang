;4.0�̲� ʵ��A IA16��ʱ���ȣ�;������Զ�����ÿ��ִ��ʱ��϶̣����ޣ�
;--------------------------------------------
;��������ߣ�8253CS��280H�� GATE0��+5V��OUT0��ʵ����IRQ
;           8255CS��288H��PC0-PC7�ӿ���K0-K7��PA0-PA7�������L0-L7
;           DAC0832CS��290H

;ԭ�����ж�����ʱ��ͨ���ж��жϼ�����Ԫ�ļ���ֵ��ȷ��ִ����Ӧ������
;�����������A����2MSִ��һ�Σ�B����4MSִ��һ�Σ�C����4MSִ��һ��
;������    A��������Ļ����ʾ�����д�����B������DAC0832�������Ҳ���C����8255ʵ��C�ڶ��룬A�����
;����K0��1ʱ����DOS
;���ʵ���䲻ͬ��Դ��ַ���жϺţ�TPC�忨��ַ��IO��ַ����Ҫ�Ķ��Ĵ���
;int_vect��irq_mask_2_7��irq_mask_9_15�������ж����룬��ӦΪ0ʱ�����Σ�
;ioport_cent��portr�������ʾ�����ȡ��
;�����޸�ioport��ַ���˶�8253��8255��DAC0832��ַ�������ͬ����Ӧ��
;-----------------------------------------------��
.286       ;Ϊ��̳���ʹ����PUSHA��POPA��80286ָ��
data segment
messstr   db 'the schedule task',0dh,0ah,'$'
messend   db 'set the k0 the "1" position to exit',0dh,0ah,'$'
msg1      db 'TPC PCI CARD INTERRUPT',0dh,0ah,'$'

  int_vect      EQU   72h;  0Bh;  071H      ;�ж�0-7������Ϊ:08h-0fh,�ж�8-15������Ϊ:70h-77h�������õ���IRQ9�����жϺ�9   
 irq_mask_2_7   equ     011111011b      ;�ж������� �ж�0-7ʱ�ӵ�������ӦλΪ��,�ж�8-15ʱ��2λΪ��
 irq_mask_9_15  equ     011111011b      ;�ж�0-7ʱȫһ,�ж�8-15ʱ�ӵ�������ӦλΪ��
;���жϺ�3�� �ж������ֱַ�Ϊ  011110111b��011111111b

 ioport_cent    equ     0E800h  ;tpc ����9054оƬ��io��ַ

 csreg		dw	?
 ipreg		dw	?		;���ж���������ռ�
 irq_times	dw	00h		;�жϼ���

dacpy           db      00h

pianyi  db  00h        ;�б���
colma   db  01h        ;�б���

;TASKA����

tames1          db 'TaskA is running. ',0dh,0ah,'$'    
tames1len=$-tames1
ta_run_times    dw 00h                  ;taska���д���
numbuff         db 30H,30H,30H,30H      ;����ASCII�봮
numbufflen=$-numbuff        ;���ȣ�4��

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

cnt1      db  01h   ;TaskA���Ƽ�����
cnt2      db  02h   ;TaskB���Ƽ�����
cnt3      db  00h   ;TaskC���Ƽ�����

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

        mov dx,ioport_cent+68h  ;���� tpc ����9054оƬio��,ʹ���ж�
        in  ax,dx
        or  ax,0900h
        out dx,ax

        mov al,int_vect         ;����ԭ�ж�����
	  mov ah,35h
        int 21h
	  mov ax,es
	  mov csreg,ax
	  mov ipreg,bx

        mov ax,cs               ;�������ж�����
	  mov ds,ax
	  mov dx,offset int_proc
	  mov al,int_vect
	  mov ah,25h
        int 21h

        in      al, 21h         ;�����ж�����
        and     al, irq_mask_2_7
        out     21h, al
        in      al, 0a1h
        and     al, irq_mask_9_15
        out     0a1h, al

        mov ax,data
        mov ds,ax
        lea dx,messstr       ;��ʾ�����������
        mov ah,09h
        int 21h

        lea dx,messend
        mov ah,09h
        int 21h
        mov dx,io8255k
        mov al,8bh
        out dx,al
        mov dx,io8253k        ;��������0д8253�����֣���ʽ3����д���ֽڣ���д���ֽ�
        mov al,36h
        out dx,al
        mov dx,io82530        ;��������0�ͳ�ֵ1000
        mov ax,1000            ;8253��CLK0��1MHZ,1000��Ƶ���OUT0�������1KHZ�ķ���
        out dx,al              ;��OUT0�ӵ�IRQ��1ms����һ���ж�
        mov al,ah
        out dx,al
        sti
;������---��������ѭ��ִ��ֱ��K0�ߵ�ƽ����ȫ������
loop1:
	cmp  cnt3,04h
     ; jnz   chka
      call  taskc
      mov   cnt3,00h
;     cmp irq_times,0            ;;��ֹ��ʽ2���ж����ɴν���
 ;    jnz loop2
  ;   mov irq_times,06h
   ;  jmp loop1 

loop2:
     mov dx,io8255c                  ;��C�ڶ����ݣ�K0Ϊ1ʱ����DOS
     in  al,dx
     test al,01h
     jnz  exit
;    CALL  Taskn                    ;�˴��ɲ�����������
     jmp loop1           ;��ѭ��

exit:                               ;��ֹ��������
      cli
      mov     bl, irq_mask_2_7        ;�ָ��ж�����
	not	bl
	in	al, 21h
	or	al, bl
	out	21h, al
	mov	bl, irq_mask_9_15
	not	bl
	in	al, 0a1h
	or	al, bl
	out	0a1h, al

      mov dx,ipreg                    ;�ָ�ԭ�ж�����
	mov ax,csreg
	mov ds,ax
	mov ah,25h
	mov al,int_vect
      int 21h

        mov dx,ioport_cent+68h          ;���� tpc ����9054оƬio��,�ر��ж�
	in  ax,dx
      and ax,0f7ffh
	out dx,ax
  
     mov ah,4ch
     int 21h
;��ʱ�жϷ���: ����ʱ��(������ʱ��)����
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

;����A
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
;      MOV AH,0      ;����
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
      INT  10H      ;display on VRAM��ROW=17H��Collum=40H
 
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

;����HEXת����ASCII�봮����numbuff�ӳ���
;���: AX=���д���

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
   and  al,0fh     ;����ȡ����λ
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
   
   ret            ;�ӳ��򷵻�
DISP ENDP

taskb proc near
  ; push ax
  ; push dx
pusha
  ; lea dx,tbmes1
  ; mov ah,09h
  ; int 21h


          
   lll:     
            mov     dx,io0832          ;DAC0832��ַ
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
inout:    mov dx,io8255c             ;��C������һ����
	  in al,dx
	  mov dx,io8255a             ;��A������ղ���C��
	  out dx,al               ;�����������
       ;   jmp aa1
   pop  dx
   pop  ax
   ret
taskc endp

code ends
end  start
