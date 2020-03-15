@ Blood Pressure Talking Program
@
@ Program interfaces RC 8660 Speech Synthesis board with BeagleBone Black
@ using RS-232C com 2 port on an interrupt basis.  The Clear To Send (CTS#),
@ Request To Send (RTS#), Transmit Data (TXD), and Receive Data (RXD) signals
@ were used in the RS-232C "handshaking".
@
@ When the button on the BeagleBone Black is pressed, it will send the message
@ "Ihr Blutdruck ist 120 uber 70. Ihr Puls ist 54.", which is German for
@ "Your blood pressure is 120 over 70.  You pulse is 54.".  The RC8660 will
@ then speak the message in a Darth Vader voice.
@
@ TIMER2 was implemented on the BeagleBone to repeat the message send to the RC 8660
@ every 10 seconds.
@
@ NOTE: Program uses modified Startup_ARMCA8 file to access IRQ interrupt
@ service procedure INT_DIRECTOR.
@
@ Shaun E Crippen, August 7 2019

.text
.global _start
.global INT_DIRECTOR
_start:

	.equ    MESSAGE_LENGTH, 130         @ Value to reload CHAR_COUNT

	@ INTC register addresses
	.equ	INTC_CONTROL, 0x48200048
	.equ	INTC_SYSCONFIG, 0x48200010
	.equ	INTC_MIR_CLEAR2, 0x482000C8
	.equ	INTC_MIR_CLEAR3, 0x482000E8
	.equ	INTC_PENDING_IRQ2, 0x482000D8
	.equ	INTC_PENDING_IRQ3, 0x482000F8
	.equ	INTC_MIR_SET2, 0x482000CC

	@ GPIO1 register addresses
	.equ	CM_PER_GPIO1_CLKCTRL, 0x44E000AC
	.equ	GPIO1_FALLINGDETECT, 0x4804C14C
	.equ	GPIO1_IRQSTATUS_SET_0, 0x4804C034
	.equ	GPIO1_IRQSTATUS_0, 0x4804C02C

	@ UART2 register addresses
	.equ	CM_PER_UART2_CLKCTRL, 0x44E00070
	.equ	UART2_LCR, 0x4802400C
	.equ	UART2_DLL, 0x48024000
	.equ	UART2_DLH, 0x48024004
	.equ	UART2_MDR1, 0x48024020
	.equ	UART2_CTSN, 0x44E108C0
	.equ	UART2_RTSN, 0x44E108C4
	.equ	UART2_RXD, 0x44E10950
	.equ	UART2_TXD, 0x44E10954
	.equ	UART2_IER, 0x48024004
	.equ	UART2_MSR, 0x48024018
	.equ	UART2_LSR, 0x48024014
	.equ	UART2_THR, 0x48024000
	.equ	UART2_IIR, 0x48024008
	.equ	UART2_FCR, 0x48024008

	@ TIMER2 register addresses
	.equ	CM_PER_TIMER2_CLKCTRL, 0x44E00080
	.equ	CLKSEL_TIMER2_CLK, 0x44E00508
	.equ	TIMER2_CFG, 0x48040010
	.equ	TIMER2_IRQENABLE_SET, 0x4804002C
	.equ	TIMER2_TLDR, 0x48040040
	.equ	TIMER2_TCRR, 0x4804003C
	.equ	TIMER2_TCLR, 0x48040038
	.equ	TIMER2_IRQSTATUS, 0x48040028
	.equ	TIMER2_TTGR, 0x48040044
	.equ	TIMER2_COUNT, 0xFFFB0000

	@ Load STACK pointers
    LDR R13, =SVC_STACK				    @ Load SVC mode stack pointer
	ADD R13, R13, #0x1000			    @ Point SVC stack pointer to top of stack (FD)
	CPS #0x12						    @ Switch to IRQ mode
	LDR R13, =IRQ_STACK				    @ Load IRQ mode stack pointer
	ADD R13, R13, #0x1000			    @ Point IRQ stack pointer to top of stack (FD)
	CPS #0x13						    @ Switch back to SVC mode

	@ Enable module clocks
	LDR R0, =CM_PER_GPIO1_CLKCTRL	    @ Load GPIO1 module clock enable register
	MOV R1, #0x02					    @ Value to enable GPIO1 module clock
	STR R1, [R0]					    @ Write #2 to enable GPIO1 module clock

	LDR R0, =CM_PER_UART2_CLKCTRL	    @ Load UART2 module clock enable register
	MOV R1, #0x02					    @ Value to enable UART2 module clock
	STR R1, [R0]					    @ Write #2 to enable UART2 module clock

	@ Enable FALLINGDETECT for button
	LDR R0, =GPIO1_FALLINGDETECT	    @ Address of GPIO1_FALLINGDETECT register
	LDR R1, [R0]					    @ Read word from FALLINGDETECT register to enable IRQ on falling edge of button
	MOV R2, #0x40000000				    @ word to enable FALLINGDETECT on bit 30 and to enable bit 22 as INT source.
	ORR R1, R2, R1					    @ Set bit 30 to 1 to enable FALLINGDETECT without affecting other bits
	STR R1, [R0]					    @ Store to enable FALLINGDETECT

	@ Enable button as interrupt
	LDR R0, =GPIO1_IRQSTATUS_SET_0	    @ Load word from IRQ status register
	STR R2, [R0]					    @ enable button as interrupt source

	@ INTC initialization and enable button interrupt (INTC #98), UART2 interrupt (INTC #74)
	LDR R0, =INTC_SYSCONFIG
	MOV R1, #0x2					    @ Value to reset INTC
	STR R1, [R0]					    @ Reset INTC

	LDR R0, =INTC_MIR_CLEAR3		    @ Address of INTC_MIR_CLEAR3 register
	MOV R1, #0x4					    @ Value to unmask INTC INT 98
	STR R1, [R0]					    @ Unmask INT #98 to allow INTC to generate IRQ from button

	LDR R0, =INTC_MIR_CLEAR2		    @ Address of INTC_MIR_CLEAR2 register
	MOV R1, #0x400					    @ Value to unmask INT #74 (bit 10)
	STR R1, [R0]					    @ Write mask to allow INTC to generate IRQ for UART2

	@ Select UART2 Mode A
	LDR R0, =UART2_LCR				    @ Address of UART2 Line Control register
	MOV R1, #0x83					    @ Value to change UART2 mode to Mode A
	STR R1, [R0]					    @ Change UART2 mode to Mode A

	@ Set UART2 baud rate
	LDR R0, =UART2_DLH				    @ Address of UART2 Divisor Latch High
	MOV R1, #0x00					    @ Value to modify base functional clock baud rate
	STR R1, [R0]					    @ Modify functional clock

	LDR R0, =UART2_DLL				    @ Address of UART2 Divisor Latch Low
	MOV R1, #0x4E					    @ Value to further modify base functional clock baud rate
	STR R1, [R0]					    @ Modify functional clock further

	@ Set UART2 16x divisor
	LDR R0, =UART2_MDR1				    @ Address of UART2 Mode Definition Register
	MOV R1, #0x00					    @ Value to set UART2 16x divisor
	STR R1, [R0]					    @ Set UART2 16x divisor

	@ Select UART2 Operational Mode
	LDR R0, =UART2_LCR				    @ Address of UART2 Line Control register
	MOV R1, #0x3					    @ Value to change UART2 mode to Operational Mode
	STR R1, [R0]					    @ Change UART2 mode to Operational Mode

	@ Clear and disable UART2 FIFO
	LDR R0, =UART2_FCR				    @ Address of UART2 FIFO Control register
	MOV R1, #0x6					    @ Value to clear TXD and RXD FIFO bits and disable FIFO
	STR R1, [R0]					    @ Clear and disable UART2 FIFO

	@ Change pin mappings on BeagleBone Black P8/P9 connectors for UART2 signals (RMW)
	LDR R0, =UART2_CTSN
	LDR R1, [R0]					    @ Read word from UART2_CTSN register to map CTS signal
	MOV R2, #0x26					    @ Word to enable CTS
	ORR R1, R2, R1					    @ (Modify) Enable CTS without affecting other bits
	STR R1, [R0]					    @ Write to map CTS signal

	LDR R0, =UART2_RTSN
	LDR R1, [R0]					    @ Read word from UART2_RTSN register to map RTS signal
	MOV R2, #0x6					    @ Word to enable RTS
	ORR R1, R2, R1					    @ (Modify) Enable RTS without affecting other bits
	STR R1, [R0]					    @ Write to map RTS signal

	LDR R0, =UART2_RXD
	LDR R1, [R0]					    @ Read word from UART2_RXD register to map RXD signal
	MOV R2, #0x21					    @ Word to enable RXD
	ORR R1, R2, R1					    @ (Modify) Enable RXD without affecting other bits
	STR R1, [R0]					    @ Write to map RXD signal

	LDR R0, =UART2_TXD
	LDR R1, [R0]					    @ Read word from UART2_TXD register to map CTS signal
	MOV R2, #0x1					    @ Word to enable TXD
	ORR R1, R2, R1					    @ (Modify) Enable TXD without affecting other bits
	STR R1, [R0]					    @ Write to map TXD signal

	@ TIMER2 Initialization (based on textbook example, Hall pg 241-247)
    LDR R0, =INTC_MIR_CLEAR2		    @ Address of INTC_MIR_CLEAR2 register
	MOV R1, #0x10					    @ Value to unmask INT #68 (bit 4)
	STR R1, [R0]					    @ Write mask to allow INTC to generate IRQ for TIMER2

    LDR R0, =CM_PER_TIMER2_CLKCTRL	    @ Load TIMER2 module clock enable register
    MOV R1, #0x2					    @ Value to enable TIMER2 module clock
	STR R1, [R0]					    @ Write #2 to enable TIMER2 module clock

	@ Set TIMER2 clock frequency multiplexer for 32.768 KHz
	LDR R0, =CLKSEL_TIMER2_CLK
	STR R1, [R0]                        @ Write 0x2 to select 32,768 KHz

	@ Initialize TIMER2 registers for 10 second count and overflow IRQ generation
    LDR R0, =TIMER2_CFG
    MOV R1, #0x1
	STR R1, [R0]					    @ Write 0x1 to reset TIMER2

	LDR R0, =TIMER2_IRQENABLE_SET       @ Load TIMER2 IRQENABLE_SET register
    MOV R1, #0x2					    @ Value to enable TIMER2 overflow interrupt
	STR R1, [R0]					    @ Write 0x2 to enable TIMER2 overflow

	LDR R0, =TIMER2_TCRR                @ Load TIMER2 Timer Counter Register (TCRR)
	LDR R1, =TIMER2_TLDR                @ Load TIMER2 Timer Load Register (TLDR)
	LDR R2, =TIMER2_COUNT               @ Value to get 10 second timer
	STR R2, [R0]                        @ Write to TCRR for initial TIMER2 starting point
	STR R2, [R1]                        @ Write to TLDR for 10 second TIMER2 reload

	@ Enable IRQ
	MRS R0, CPSR					    @ Copy CPSR to R3
	BIC R0, #0x80					    @ Enable IRQs by clearing bit 7
	MSR CPSR_c, R0					    @ Write back to CPSR to

	@ Wait loop
	IDLE:
    	NOP							    @ Wait for interrupt
		B IDLE

	INT_DIRECTOR:
    	STMFD SP!, {R0-R10, LR}         @ Push SVC registers to IRQ stack
    	LDR R0, =INTC_PENDING_IRQ2
    	LDR R1, [R0]                    @ Load word to see if IRQ from UART2
    	TST R1, #0x400                  @ Test bit 10

    	BEQ TIMER_CHECK	                @ IF NOT UART2, check if IRQ from TIMER2

    	LDR R0, =UART2_IIR			    @ IF YES UART2,
    	LDR R1, [R0]                    @ Load word to see if IRQ pending in UART2
    	TST R1, #0x1                    @ Test bit 0 (IT_PENDING bit)

    	BEQ TALKER_SVC                  @ IF IRQ pending (bit 0 = 0), go to talker service

    	B RETURN					    @ IF NO, return to wait loop

		TIMER_CHECK:

			LDR R0, =INTC_PENDING_IRQ2
			LDR R1, [R0]				@ Load word to see if IRQ pending for TIMER2
			TST R1, #0x10				@ Test bit 4

			BEQ BUTTON_CHECK			@ IF NO, check if IRQ from button

			LDR R0, =TIMER2_IRQSTATUS	@ IF YES, check if IRQ from TIMER2 overflow
			LDR R1, [R0]
			TST R1, #0x2				@ Test bit 1 for TIMER2 overflow

			BEQ RETURN					@ IF NOT overflow, return to wait loop

			MOV R1, #0x2				@ IF YES overflow,
			STR R1, [R0]				@ Turn off overflow IRQ
										@
			B BUTTON_SVC				@ Go to BUTTON_SVC to enable UART IRQs

        BUTTON_CHECK:

        	LDR R0, =INTC_PENDING_IRQ3
            LDR R1, [R0]                @ Load word to see if IRQ from button
            TST R1, #0x4                @ Test bit 2 (INT #98)

            BEQ RETURN					@ IF NO, return to wait loop

            LDR R0, =GPIO1_IRQSTATUS_0  @ IF YES, check if IRQ from GPIO1_30
            LDR R1, [R0]                @ Load word to see if GPIO pin
            TST R1, #0x40000000         @ Test bit 30

            BEQ RETURN                  @ IF NO, return to wait loop
                	                    @ IF YES, update button status and service button press

            @ Update button flag
            LDR R0, =BUTTON_FLAG        @ Get button flag from memory
            LDR R1, [R0]                @ Read button status (ON = 1, OFF = 0)
            TST R1, #0x1                @ Test if flag is set, then update based on result
            MOVEQ R2, #1                @ System in "OFF" state, turn system "ON"
            MOVNE R2, #0                @ System in "ON" state, turn system "OFF"
            STR R2, [R0]                @ Write button flag to memory

			BNE TURN_OFF				@ Branch to turn off UART ints if button updates to "OFF" state

	BUTTON_SVC:

		LDR R0, =GPIO1_IRQSTATUS_0
        MOV R1, #0x40000000             @ Value to turn off button interrupt
        STR R1, [R0]                    @ Turn off button interrupt

        LDR R0, =UART2_IER
        MOV R1, #0xA                    @ Value to enable UART2's THR and MSR interrupts (bits 1 and 3)
        STR R1, [R0]                    @ Enable UART2 interrupts

        B RETURN                        @ Enable new IRQ and return to wait loop

	TALKER_SVC:

        @ Check if CTS# was asserted
        LDR R0, =UART2_MSR
        LDR R1, [R0]
        TST R1, #0x10                   @ Test if CTS# is asserted (bit 4 = 1)

        BEQ NOCTS                       @ IF NOT asserted, check THR to avoid "spinning"

        @ Check if THR empty
        LDR R0, =UART2_LSR
        LDR R1, [R0]
        TST R1, #0x20                   @ Test if THR is empty (bit 5 = 1)

        BNE SEND                        @ IF empty, send character
        B RETURN                        @ ELSE enable new IRQ and return to wait loop

        NOCTS:
        	@ Check if THR empty
            LDR R0, =UART2_LSR
            LDR R1, [R0]
            TST R1, #0x20           	@ Test if THR is empty (bit 5 = 1)

            BEQ RETURN              	@ not "spinning", enable new IRQ and return to wait loop

            LDR R0, = UART2_IER			@ To avoid "spinning", set bit 3 to mask THR IRQ
            MOV R1, #0x8				@					and
            STR R1, [R0]            	@ enable new IRQ and return to wait loop

            B RETURN

		@SEND TAKEN FROM PROJECT HANDOUT
        SEND:

        	@ Setting up character pointer and count, increment pointer
            LDR R0, =CHAR_PTR			@ Send character, R0 = address of pointer store
            LDR R1, [R0]				@ R1 = Address of desired character in text string
            LDR R2, =CHAR_COUNT			@ R2 = Address of count store location
            LDR R3, [R2]				@ Get current character count value
            LDRB R4, [R1], #1			@ Read char to send from string, inc ptr to R1
            STR R1, [R0]				@ Put incremented address back in CHAR_PTR location

            @ Stage current character to send to talker
            LDR R5, =UART2_THR			@ Point at UART transmit buffer
            STRB R4, [R5]				@ Write character to transmit buffer

            @ Decrement counter
            SUBS R3, R3, #1				@ Decrement character counter by 1
            STR R3, [R2]				@ Store character value counter back to memory
            BPL RETURN					@ Counter >= zero, more characters

			@ If no more characters to send
			LDR R3, =MESSAGE		    @ Done, reload.  Get address of start of string
            STR R3, [R0]			    @ Write in char pointer store location in memory
            MOV R3, #MESSAGE_LENGTH	    @ Load original number of char in string again
            STR R3, [R2]			    @ Write back to memory for next message send
            LDR R0, =UART2_IER		    @ Load UART2 Interrupt Enable Register (IER)
            MOV R1, #0x0			    @ Word to disable UART2 interrupts
            STR R1, [R0]			    @ Disable UART2 THR and MSR interrupts

			@ Finished message, start TIMER2 and set for auto reload
			LDR R0, =TIMER2_TCLR	    @ Load TIMER2 TCLR
			MOV R1, #0x3			    @ Value to start TIMER2 with auto reload
			STR R1, [R0]			    @ Write 0x3 to start timer and auto reload

			B RETURN				    @ End of message, reset message pointer and counter

		TURN_OFF:

			LDR R0, =INTC_MIR_SET2      @
			MOV R1, #0x10               @ Mask INT #68 to disable TIMER2 interrupts
			STR R1, [R0]                @

			LDR R0, =CHAR_PTR
			LDR R2, =CHAR_COUNT
			LDR R3, =MESSAGE		    @ Done, reload.  Get address of start of string
            STR R3, [R0]			    @ Write in char pointer store location in memory
            MOV R3, #MESSAGE_LENGTH	    @ Load original number of char in string again
            STR R3, [R2]			    @ Write back to memory for next message send
            LDR R0, =UART2_IER		    @ Load UART2 Interrupt Enable Register (IER)
            MOV R1, #0x0			    @ Word to disable UART2 interrupts
            STR R1, [R0]			    @ Disable UART2 THR and MSR interrupts

			B RETURN

		RETURN:

            LDR R0, =INTC_CONTROL
            MOV R1, #1
            STR R1, [R0]                @ Turn off NEWIRQ bit
            LDMFD SP!, {R0-R10, LR}     @ Pop SVC registers
            SUBS PC, LR, #4             @ Return to wait loop


.align 4
SYS_IRQ: .word 0						@ Location to store system's IRQ address
.data
.align 4

BUTTON_FLAG: .word 0x0					@ Initialize button flag to "OFF"

SVC_STACK:	 .rept 1024
			 .word 0x0
			 .endr

IRQ_STACK:	 .rept 1024
			 .word 0x0
			 .endr
MESSAGE:                                @ "1O" changes RC8660 default voice to Darth Vader voice
			.byte 0x0D					@ Start byte
			.byte 0x1					@ Command character to change voice
			@ Phonetic spelling for German message
			.ascii "1O" "/Ee\'uh  Bl/oo\t'trrutsk  /i\zt  ain'hoon'derts'vahn'tsik  /oo\buh  z/ee\b'tsich.  /Ee\'uh  P/oo\lz  /i\zt  feer'oond'foonf'tsich."
			.byte 0x0D					@ End byte
.align 4

CHAR_PTR:	.word MESSAGE               @ Pointer to next character to send

CHAR_COUNT:	.word MESSAGE_LENGTH        @ Counter for number of characters to send
                                        @ (number of characters counts X-1 down to 0)

.end
