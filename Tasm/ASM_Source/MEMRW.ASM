;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;***********************;
;*     �洢����д      *;
;***********************;
data SEGMENT
	mem_data	equ	0f6000000h	;tpc �����豸��mem��ַ
        msg1    DB      0dh,0ah,'TPC pci card memory!',0dh,0ah,'$'
	gdt_def	DW	00h,00h,00h,00h	;ȫ����������GDT����һ�ο�
		DW	0ffffh		;ȫ����������GDT���ڶ��Σ��ν��޵�16λ
		DW	00h		;����ַ��16λ
		DB	00H,92H		;����ַ�м�8λ��������
		DB	8FH,00H		;�ν��޵ĸ�4λ(���������Եĸ�4λ)������ַ�ĸ�8λ
	gdt_addr DW	00h	;���GDT�ĳ���(���ֽ�Ϊ��λ�ĳ���-1)
		DW	00H,00H	;���GDT�����Ի���ַ
data ENDS
code SEGMENT
        ASSUME CS:code,DS:data,SS:data,ES:data
start:
.386p
        call opena20	;��a20��ַ��
        mov ax,data
        mov ds,ax
        call set4gb	;���뱣��ģʽ����ν���Ϊ4GB�󷵻�ʵģʽ

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
	loop loop1	;��tpc���Ĵ洢�ռ䷴��д256��a-z

	mov ax,0
	mov ds,ax
        mov esi,mem_data
        mov cx,100h
loop3:
        mov dl,[esi]
        mov ah,02h
        int 21h
        add esi,1
        loop loop3	;��tpc���Ĵ洢�ռ��256���ֽ����ݲ���ʾ

	mov ax,data
	mov ds,ax
	MOV DX,OFFSET msg1
	MOV AH,09h
	INT 21h
        call closea20
	mov ax,4c00h
	int 21h

set4gb proc	;���뱣��ģʽ����ν���Ϊ4GB�󷵻�ʵģʽ
        CLI
        PUSH    DS
	PUSH	ES
        MOV     WORD PTR GDT_Addr[0], (2*8-1)	;   //GDT�ĳ��ȴ���GDT_Addr��
        MOV     EAX,DS		;  //����GDT�������������Ի���ַ31-0
        SHL	EAX,4		;  //�ε�ַeax=ds��16
        XOR	EBX,EBX		;  //ebx����
        MOV	BX,OFFSET GDT_def	;   //bx=GDT��ƫ�Ƶ�ַ
        ADD	EAX,EBX		;  //GDT�����Ի���ַ=eax+ebx
        MOV	dword PTR GDT_Addr[2],EAX	;   //GDT�����Ի���ַ����GDT_Addr��
        lgdt	qword PTR GDT_Addr
        MOV	BX,8		;  //�������ݶ���������ѡ����
        MOV	EAX,cr0
        OR	AL,1
        MOV	cr0,EAX
        JMP	flush1	;ʹ����ģʽ�´���ε�ѡ����װ��CS�����뱣��ģʽ
flush1:
        MOV	DS,BX	;       //DSװ�ؾ���4GB���޵����ݶ�������
        MOV	ES,BX	;       //ESװ�ؾ���4GB���޵����ݶ�������
        AND	AL,0feh
        MOV	cr0,EAX
        JMP	flush2	;��ָ��Ԥȡ���У�ʹʵģʽ�´���εĶ�ֵװ��CS������ʵģʽ
;              //����ʵ��ʽ
flush2:
        POP	ES
	POP	DS
        STI
	ret
set4gb endp

opena20 proc	;��a20��ַ��
                push    ax
                in      al,92h
                or      al,00000010b
                out     92h,al
                pop     ax
		ret
opena20 endp

closea20 proc	;�ر�a20��ַ��
                push    ax
                in      al,92h
                and     al,11111101b
                out     92h,al
                pop     ax
		ret
closea20 endp

code ENDS
END start