		SETB P3.7                      // sensor

BACK:	JB P3.7,NOPRESS
		CLR P3.6
		LCALL RPT1	 
NOPRESS:LCALL RPT               //no moisture
     	MOV TMOD,#20H                          
		MOV TH1,#0FDH                               
		MOV SCON,#50H   
		CLR P3.6                //pump off
        SETB TR1                                          
HERE:	JNB RI,HERE		                 
		MOV A,SBUF		         
		CLR RI                    
		CJNE A,#'1',ONE                 
		SETB P3.6
        ACALL RPT2  
        SJMP BACK		//pump is on
ONE:	CLR P3.6
		ACALL RPT1	
        SJMP BACK		//pump is off			
			
RPT:	MOV DPTR,#CMD 
		ACALL L1
		MOV DPTR,#MSG	
		ACALL L2			
        RET

RPT1:	MOV DPTR,#CMD1 
		ACALL L1
		MOV DPTR,#MSG1	
		ACALL L2			
		SJMP BACK
		
RPT2:	MOV DPTR,#CMD2 
	    ACALL L1
		MOV DPTR,#MSG2	
		ACALL L2			
		SJMP BACK

L1: 	CLR A 
		MOVC A,@A+DPTR
		JZ EXIT
		INC DPTR
		MOV P2,#00H
		MOV P1,A
		MOV P2,#80H
		ACALL DELAY
		MOV P2,#00H
		SJMP L1
EXIT: 	RET
L2: 	CLR A 
		MOVC A,@A+DPTR
		JZ EXIT1
		INC DPTR
		MOV P2,#40H
		MOV P1,A
		MOV P2,#0C0H
		ACALL DELAY
		MOV P2,#40H
		SJMP L2
EXIT1: 	RET


DELAY: 	MOV R0, #0FFH ; Delay function
GO: 	MOV R1, #0FFH
HERE1:	DJNZ R1, HERE1
		DJNZ R0, GO
		RET
		

CMD: DB 01H,80H,06H,0C0H,02H,0EH,0
MSG: DB "NO_MOISTURE",0
	


CMD1: DB 01H,80H,06H,0C0H,02H,0EH,0
MSG1: DB "PUMP_IS_OFF",0

CMD2: DB 01H,80H,06H,0C0H,02H,0EH,0
MSG2: DB "PUMP_IS_ON",0

	 END
