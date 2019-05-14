MOV P1,#00000000B      // sets P1 as output port
MOV P2,#00000000B      // sets P0 as output port
CLR P3.0               // sets P3.0 as output for sending trigger
SETB P3.1              // sets P3.1 as input for receiving echo
MOV TMOD,#00100000B    // sets timer1 as mode 2 auto reload timer
MAIN: MOV TL1,#207D    // loads the initial value to start counting from
      MOV TH1,#207D    // loads the reload value
      MOV A,#00000000B // clears accumulator
      SETB P3.0        // starts the trigger pulse
      ACALL DELAY1     // gives 10uS width for the trigger pulse
      CLR P3.0         // ends the trigger pulse
HERE: JNB P3.1,HERE    // loops here until echo is received
BACK: SETB TR1         // starts the timer1
HERE1: JNB TF1,HERE1   // loops here until timer overflows (ie;48 count)
      CLR TR1          // stops the timer
      CLR TF1          // clears timer flag 1
      INC A 	       // increments A for every timer1 overflow
      JB P3.1,BACK     // jumps to BACK if echo is still available
      MOV R4,A         // saves the value of A to R4
      ACALL DISPLAY    // calls the display loop
      SJMP MAIN        // jumps to MAIN loop

DELAY1: MOV R6,#2D     // 10uS delay
LABEL1: DJNZ R6,LABEL1
        RET  

DISPLAY: MOV DPTR,#CMD //LOADING COMMAND WORDS
		 ACALL L1 
		 MOV DPTR,#MSG1 //DISPLAYING "DISTANCE" 
		 ACALL L2
         CLR A		 
		 MOV A,R4   //CONVERSION FROM HEX TO DECIMAL
		 MOV B,#64H
		 DIV AB
		 MOV R5,A  //GETTING MSB
		 ACALL L3
		 MOV A,B
		 MOV B,#0AH  
		 DIV AB
		 MOV R5,A
		 LCALL L3
		 MOV R5,B   //GETTING LSB
		 LCALL L3
		 MOV DPTR,#MSG2  //DISPLAYING "CM"
		 LCALL L4
		 RET
		 
L1: CLR A 
	MOVC A,@A+DPTR 
	JZ EXIT
	INC DPTR 
	MOV P1,#00H
	MOV P2,A
	MOV P1,#01H
	ACALL DELAY 
	MOV P1,#00H 
	SJMP L1
EXIT: RET

L2: CLR A
	MOVC A,@A+DPTR
	JZ EXIT1 
	INC DPTR
	MOV P1,#04H 
	MOV P2,A
	MOV P1,#05H
	ACALL DELAY
	MOV P1,#04H
	SJMP L2 
EXIT1: RET 

L3: MOV DPTR,#NUMBERS
    CLR A
    MOV A,R5 
	MOVC A,@A+DPTR
	MOV P1,#04H 
	MOV P2,A
	MOV P1,#05H
	ACALL DELAY
	MOV P1,#04H
    RET 
	
L4: CLR A
	MOVC A,@A+DPTR
	JZ EXIT2 
	INC DPTR
	MOV P1,#04H 
	MOV P2,A
	MOV P1,#05H
	ACALL DELAY
	MOV P1,#04H
	SJMP L2 
EXIT2: RET 

DELAY: 	MOV R0, #0FFH ; Delay function 
GO: 	MOV R1, #0FFH 
HERE2: 	DJNZ R1, HERE2
		DJNZ R0, GO
		RET 

 
CMD: DB 01H,80H,06H,0C0H,02H,0EH,0 
MSG1: DB " DISTANCE=",0
NUMBERS: DB "0123456789"
MSG2: DB " CM",0	
END
