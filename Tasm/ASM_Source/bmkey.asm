;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;****************;
;* ��Ĥ����ʵ�� *;
;****************;
 ioport		equ 0d400h-0280h
 smkeyport6	equ ioport+2b6H	;��ɨ��ڵ�ַ
 smkeyport7	equ ioport+2b7H	;��ɨ��ڵ�ַ
data segment
 table1	dw 0E1Fh,0E2Fh,0E4Fh,0E8Fh,0D1Fh,0D2Fh,0D4Fh,0D8Fh
	dw 0B1Fh,0B2Fh,0B4Fh,0B8Fh,071Fh,072Fh,074Fh,078Fh	;����ɨ�����
 char  db '0123456789ABCDEF'					;�ַ���
 mes   db 0ah,0dh,'PLAY ANY KEY IN THE SMALL KEYBOARD! ',0ah,0dh
       db 'IT WILL BE ON THE SCREEN! END WITH E or ANY KEY',0ah,0dh,'$'
 key_in db 0h
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
main_key:
        call key                ;get a char in (key_in) and display it
	cmp byte ptr key_in,'E'
        jnz main_key
        mov ax,4c00h            ;if (dl)='E' return to EXIT!
	int 21h			;�˳�

key proc near
key_loop:
	mov ah,1
	int 16h
        jnz exit		;pc�����м��������˳�
	MOV DX,smkeyport6
	in al,dx		;����ɨ��ֵ
	cmp al,0fh
	jz key_loop		;δ�����м�������ת
        call delay		;delay for amoment
	mov ah,al
	MOV DX,smkeyport7
	in al,dx		;����ɨ��ֵ
	cmp al,0fh
	jz key_loop		;δ�����м�������ת
	mov si,offset table1	;����ɨ�������ַ
	mov di,offset char	;�ַ�����ַ
	mov cx,16		;�����ı��С
key_tonext:
	cmp ax,[si]		;cmp (col,row) with every word
	jz key_findkey		;in the table
	dec cx
	jz key_loop		;δ�ҵ���Ӧɨ����
	add si,2
	inc di
	jmp key_tonext
key_findkey:
	mov dl,[di]
	mov ah,02
	int 21h			;��ʾ���ҵ��ļ�����
	mov byte ptr key_in,dl
key_waitup:
	MOV DX,smkeyport6
	in al,dx		;����ɨ��ֵ
	xor ah,ah
	cmp al,0fh
	jnz key_waitup		;����δ̧��ת
        call delay		;delay for amoment
	ret
exit:
	mov byte ptr key_in,'E'
	ret
key endp

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
