;*************************
;������Ϊ����������ٳ���
;ǰ��Ϊ�������ת�ٿ��ƣ�
;��Ϊ�ٶȲ���
;*************************
data   segment
ioport		equ 0ec00h-0280h
io8255k		equ ioport+28bh   ;8255���ƿ�
io8255a		equ ioport+288h   ;8255 A��
io8255c		equ ioport+28ah   ;8255 C
io8253k		equ ioport+283h   ;8253����
io82532		equ ioport+282h   ;8253������2
io82531		equ ioport+281h   ;8253������1
io82530		equ ioport+280h   ;8253������0
iot8253k		equ ioport+293h   ;ͨ�ò���8253����
iot82530		equ ioport+290h   ;ͨ�ò���8253������0

mess    db 'Strike any key,return to DOS!',0AH,0DH,'$'
cou	 db 0
cou1	 db 0
count   db 0
count1	 db 0
count2	 db 0
count3	 db 0
count4	 db 0
buf     dw 0
data   ends
code   segment
assume cs:code,ds:data
start:    mov	ax,data
	  mov	ds,ax
	  mov	dx,offset mess
	  mov	ah,09h
	  int	21h                ;��ʾ��ʾ��Ϣ
	  
int82531: mov   dx,io8253k
	  mov   al,36h             ;������0����ʽ3���ȶ�д��8λ���ٶ�д��8λ
	  out   dx,al               ;����ʱ�ӣ�1MHZ
	  mov   dx,io82530
	  mov   ax,50000           ;��ֵ50000�����ʱ������50ms
	  out   dx,al
	  mov   al,ah
	  out   dx,al
	  mov	dx,io8253k
	  mov	al,96h
	  out	dx,al               ;������2����ʽ3��ֻ��д��8λ
	  mov	dx,io82532
	  mov	al,200
	  out	dx,al               ;��ֵ200��10����һ�Σ����5��
	  
int8255:  mov	dx,io8255k      ;8255,Aͨ�����룬C��λ�������λ����
          mov	al,98h
          out	dx,al
          mov	al,00
          out	dx,al            ;C0(GATE1)�͵�ƽ��ֹͣ����
readc:    mov	dx,io8255c
          in	al,dx                ;��C�� 
          and	al,0f0h            
          test al,10h              ;����
          jnz	k4
          test al,20h
          jnz	k5
          test al,40h
          jnz	k6
          test al,80h              ;����
          jnz	k7
          jmp	readc
k4:       mov	buf,4000
          jmp	int8253
k5:       mov	buf,5000
          jmp	int8253
k6:	  mov	buf,6000
	  jmp	int8253
k7:	  mov	buf,8000
int8253:  mov   dx,iot8253k          ;����չ8253д������
	  mov   al,36h                 ;ʹ0ͨ��Ϊ������ʽ3
	  out   dx,al
	  mov   ax,buf                 ;д��ѭ��������ֵbuf
	  mov   dx,iot82530
	  out   dx,al                    ;��д����ֽ�
	  mov   al,ah
	  out   dx,al                    ;��д����ֽ�
	  mov	dx,io8255k
	  mov	al,03h
	  out	dx,al                    ;��ʼ�����λ����                                                                                                                                                                             
         mov	dx,io8255k
	  mov	al,04h
	  out	dx,al                     ;Ԥ��195 
         mov  cx,0a000h
loop2:   nop
         loop loop2                   ;��ʱ����֤Ԥ�óɹ�
         mov	dx,io8255k
	  mov	al,05h
	  out	dx,al                    ;�������
                                    
ll:	  mov	ah,01h                   ;���޼���
	  int	16h
	  jnz	quit1                    ;�м�������
	  jmp	a0
quit1:	  jmp	quit
	
a0:	  mov   dx,io8253k            
	  mov   al,70h
	  out   dx,al                    ;������1����ʽ0���ȶ�д��8λ���ٶ�д��8λ��
	  mov   dx,io82531              ;����ʱ��Ϊ��翪�������
	  mov   ax,0ffffh
	  out   dx,al
	  mov   al,ah
	  out   dx,al
      	  mov	dx,io8255a             
a1:	  in	al,dx
	  and	al,01h
	  cmp	al,00h
	  jnz	a1                      ;8255 PA0�Ƿ�Ϊ0
a2:	  in	al,dx
         and	al,01h
	  cmp	al,00h
	  jz	a2                          ;8255 PA0�Ƿ�Ϊ1
	  mov	dx,io8255k
	  mov	al,01h
	  out	dx,al                    ;��ʼ����
	  
	  mov	dx,io8255a
a3:	  in	al,dx
	  and	al,01h
	  cmp	al,00h         
	  jnz	a3                      ;8255 PA0�Ƿ�Ϊ1
	  mov	dx,io8255k
	  mov	al,00h
	  out	dx,al                    ;ֹͣ����	  
        
          mov	dx,io82531
          in	al,dx
          mov	bl,al
          in	al,dx
          mov	bh,al               ;����ֵ��bx
          mov	ax,0ffffh
          sub	ax,bx              ;�����������
	   call	disp                   ;��ʾ
	  mov	dl,0dh
	  mov	ah,02
	  int	21h
	  mov	dl,0ah
	  mov	ah,02
	  int	21h
         jmp int8255                ;�޼�������

;------------------------------------------------------------
disp	  PROC	NEAR                  ;BCDת������ʾ�ӳ���
	  mov	dx,0000h
	  mov	cx,1000
	  div	cx
	  mov	count1,al
	  mov	ax,dx
	  mov	cl,100
	  div	cl
	  mov	count2,al
	  mov	al,ah
	  mov	ah,00h
	  mov	cl,10
	  div	cl
	  mov	count3,al
	  mov	count4,ah
          mov	al,count1
          call	disp1
          mov	al,count2
          call	disp1
          mov	al,count3
          call	disp1
          mov	al,count4
          call	disp1
          ret
DISP	  ENDP
;--------------------------------------------------------------------
disp1	  PROC	NEAR                ;��ʾһ���ַ�           
          and	al,0fh
          add	al,30h
          mov	dl,al
          mov	ah,02
          int	21h                 
          ret
disp1	  endp
;-------------------------------------------------------------
quit:	  mov	dx,io8255k
	  mov	al,02h
	  out	dx,al                        	 
	  mov ah,4ch                     ;����DOS
	  int 21h	  
code    ends
	end start
