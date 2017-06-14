STACKS  SEGMENT   STACK  
              DW        256 DUP(?)
      STACKS  ENDS
       DATAS  SEGMENT           
      STRING1  DB        'please input an integer between 0-9:N=','$'
     STRING2  DB        0AH,0DH,'The result is:N!=','$'
        FLAG  DW        ?
       DATAS  ENDS
       CODES  SEGMENT              
              ASSUME    CS:CODES,DS:DATAS  ,SS:STACKS
      START:  MOV       AX,DATAS    
              MOV       DS,AX

              MOV       AH, 9H
              MOV       DX,OFFSET STRING1
              INT       21H
              MOV       AH,1      
              INT       21H
              SUB       AL,30H     
              CBW                
              MOV       CX,AX
              CALL      FACT
              MOV       AX, DX
              CALL      SHOW_DEC 
       EXIT:  MOV       AH, 4CH
              INT       21H
   SHOW_DEC:
              MOV       BX,AX    
              MOV       DX, OFFSET STRING2
              MOV       AH, 9     
              INT       21H
              MOV       FLAG,0     
              MOV       CX,10000D  
              CALL      DEC_DIV
              MOV       CX,1000D
              CALL      DEC_DIV
              MOV       CX,100D
              CALL      DEC_DIV
              MOV       CX,10D
              CALL      DEC_DIV
              MOV       CX,1D
              CALL      DEC_DIV
              MOV       DL,20H    
              MOV       AH,2
              INT       21H
              RET
              
        FACT  PROC      NEAR
              CMP       AX, 0    
              JNZ       NEXT    
              MOV       DX, 1
              RET
       NEXT:  PUSH      AX
              DEC       AX
              CALL      FACT
              POP       CX
              MOV       AX, DX
              MUL       CX
              MOV       DX, AX
              RET
        FACT  ENDP
                            
     DEC_DIV  PROC      NEAR
              MOV       DX,0
              MOV       AX,BX      
              DIV       CX         
              MOV       CX,DX       
              MOV       DL,AL  
              MOV       BX,CX   
              CMP       DL,0H    
              JA        USEFUL
              CMP       FLAG, 0
              JNZ       SHOW_ZERO 
              RET
     USEFUL:  MOV       FLAG,1
              ADD       DL,30H     
              MOV       AH,2
              INT       21H
              RET
  SHOW_ZERO:
              ADD       DL,30H      
              MOV       AH,2
              INT       21H
              RET
              RET
              
     DEC_DIV  ENDP
       CODES  ENDS
              END       START
