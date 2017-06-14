;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;*************************************;
;* 8255A���пڼ���ɨ��ʵ��(�жϷ�ʽ) *;
;*************************************;
 ioport	equ 0d400h-280H
 pa8255	equ ioport+288H	;8255�˿�,a��
 pc8255	equ ioport+28aH	;8255�˿�,c��
 p8255ctl	equ	ioport+28bH	;8255�˿�,���ƿ�
 int_vect	EQU	071H		;�ж�0-7������Ϊ:08h-0fh,�ж�8-15������Ϊ:70h-77h
 irq_mask_2_7	equ	011111011b	;�ж�����,�ж�0-7ʱ�ӵ�������ӦλΪ��,�ж�8-15ʱ��2λΪ��
 irq_mask_9_15	equ	011111101b	;�ж�0-7ʱȫһ,�ж�8-15ʱ�ӵ�������ӦλΪ��
 ioport_data	equ	0d400h-280h	;tpc �����豸��io��ַ
 ioport_cent	equ	0d800h		;tpc ����9054оƬ��io��ַ
data segment
 csreg	dw	?
 ipreg	dw	?	;���ж���������ռ�
 key_in_val db 0	;�жϳ����л�ȡ�ļ�������ֵ����ռ�
 table1	dw 0101h,0102h,0104h,0108h,0110h,0120h,0140h,0180h
	dw 0201h,0202h,0204h,0208h,0210h,0220h,0240h,0280h
	dw 0401h,0402h,0404h,0408h,0410h,0420h,0440h,0480h	;����ɨ�����
 char  db '89ABCDEF01234567GMPRWXY '				;�ַ���
 mes   db 0ah,0dh
       db 'PLAY ANY KEY IN THE SMALL KEYBOARD! ',0ah,0dh
       db 'IT WILL BE ON THE SCREEN! END WITH R or E or ANY KEY',0ah,0dh,'$'
data ends
stacks segment stack	;��ջ�ռ�
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

	mov dx,offset mes	;��ʾ��ʾ��Ϣ
	mov ah,09
	int 21h

	mov al,010000011b	;��ʼ��8255a
	MOV DX,p8255ctl
	out dx,al               ;set command word of 8255a
	                        ;port a for output,port c for input
	mov al,00
	MOV DX,pa8255
	out dx,al               ;port a output 00

	mov dx,ioport_cent	;���� tpc ����9054оƬio��,ʹ���ж�
        add dx,068h
        in ax,dx
        or ax,0900h
        out dx,ax

	mov al,int_vect		;����ԭ�ж�����
	mov ah,35h
        int 21h
	mov ax,es
	mov csreg,ax
	mov ipreg,bx

        mov al,int_vect		;�������ж�����
        mov cx,cs
        mov ds,cx
	mov dx,offset int_key
	mov ah,25h
        int 21h

	mov ax,data
	mov ds,ax
	mov es,ax
        in al, 21h		;�����ж�����
	mov ah,irq_mask_2_7
	and al,ah
        out 21h, al
        in al, 0a1h
	mov ah,irq_mask_9_15
	and al,ah
        out 0a1h, al
	sti			;���ж�
ky:
        cmp byte ptr key_in_val,'E'
        jz exit                 ;if key_in='E' return to EXIT!
        cmp byte ptr key_in_val,'R'
        jz exit                 ;if key_in='R' return to EXIT!
	mov ah,1
	int 16h
        jz ky			;��������˳�

exit:   cli
	mov ah,irq_mask_2_7
	not ah
	in al,21h
	or al,ah
	out 21h,al
	mov ah,irq_mask_9_15
	not ah
	in al,0a1h
	or al,ah
	out 0a1h,al

	mov al,int_vect
        mov dx,ipreg
	mov cx,csreg
	mov ds,cx
	mov ah,25h
        int 21h

	mov ax,data	;���� tpc ����9054оƬio��,�ر��ж�
        mov ds,ax
	mov dx,ioport_cent
        add dx,068h
	in ax,dx
        and ax,0f7ffh
	out dx,ax

	mov ax,4c00h
	int 21h		;�˳�

int_key proc near
        cli
        pusha			;����Ĵ���ֵ
	MOV DX,pc8255
	in al,dx                ;get col data from port c
	or al,0f8h		;���θ�5λ����Ϊ1
	cmp al,0ffh
	jz quit                 ;no key is closed ,quit
	push ax                 ;save the col data
	push ax
        call delay		;delay for amoment
	MOV DX,p8255ctl
	mov al,010010000b	;set command word of 8255a
	out dx,al               ;port a for input,port c for output
	MOV DX,pc8255
        pop ax
	out dx,al               ;output col data to port c
	MOV DX,pa8255
	in al,dx                ;(al) is row data from port a
        pop bx
	mov ah,bl               ;(ah) is col data
	not ax
	mov si,offset table1	;����ɨ�������ַ
	mov di,offset char	;�ַ�����ַ
	mov cx,24		;������ı���С
tt:
	cmp ax,[si]		;cmp (col,row) with every word
	jz nn			;in the table
	dec cx
	jz quit			;δ�ҵ���Ӧɨ�����˳�
	add si,2
	inc di
	jmp tt
nn:
	mov dl,[di]
	mov ah,02
	int 21h
        mov byte ptr key_in_val,dl	;��ȡ�ļ�������ֵ����
	mov al,010000011b
	MOV DX,p8255ctl
	out dx,al               ;set command word of 8255a
	                        ;port a for output,port c for input
	mov al,00
	MOV DX,pa8255
	out dx,al               ;port a output 00
wait2:
	MOV DX,pc8255
	in al,dx                ;get col data from port c
	or al,0f8h		;���θ�5λ����Ϊ1
	cmp al,0ffh
	jnz wait2               ;wait until the key is up
QUIT:
	mov al,010000011b
	MOV DX,p8255ctl
	out dx,al               ;set command word of 8255a
	                        ;port a for output,port c for input
	mov al,00
	MOV DX,pa8255
	out dx,al               ;port a output 00

	mov al,20h		;Send EOI
	out 0a0h,al
        mov cx,03fffh
loopx1: loop loopx1             ;��ʱ
	out 20h,al
        mov cx,03fffh
loopx:  loop loopx              ;��ʱ
        popa                    ;�ָ��Ĵ���ֵ
	sti
	iret			;�жϷ���
int_key endp

delay proc near
        pusha       ;delay 50ms--100ms
        mov ah,0
        int 1ah
        mov bx,dx
delay1:
	mov ah,0
	int 1ah
	cmp bx,dx
	jz delay1
	mov bx,dx
delay2:
	mov ah,0
	int 1ah
	cmp bx,dx
	jz delay2
	popa
        ret
delay endp
code ends
end start