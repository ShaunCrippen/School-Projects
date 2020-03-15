@ I2C Driver
@ 
@ The following program interfaces a ST7036 New Haven LCD board with a BeagleBone Black 
@ microcontroller using I2C communication to display the message "Shaun Crippen".
@ 
@ On each button press of the BeagleBone Black, each consecutive character of the 
@ message will be displayed.
@ 
@ Shaun E Crippen, August 2019

.text
.global _start
_start:

	@ GPIO1 register addresses
	.equ	CM_PER_GPIO1_CLKCTRL, 0x44E000AC
	.equ	GPIO1_FALLINGDETECT, 0x4804C14C
	.equ	GPIO1_DATAIN, 0x4804C138

	@ I2C1 register addresses
	.equ	CM_PER_I2C1_CLKCTRL, 0x44E00048
	.equ	I2C1_SDA, 0x44E10958
	.equ	I2C1_SCL, 0x44E1095C
	.equ	I2C1_PSC, 0x4802A0B0
	.equ	I2C1_SCLL, 0x4802A0B4
	.equ	I2C1_SCLH, 0x4802A0B8
	.equ	I2C1_SA, 0x4802A0AC
	.equ	I2C1_CNT, 0x4802A098
	.equ	I2C1_CON, 0x4802A0A4
	.equ	I2C1_DATA, 0x4802A09C
	.equ	I2C1_IRQSTATUS_RAW, 0x4802A024

@*********************************************INITIALIZATIONS*****************************************

	@ Enable module clocks
	LDR R0, =CM_PER_GPIO1_CLKCTRL	    @ Load GPIO1 module clock enable register
	MOV R1, #0x02			    @ Value to enable GPIO1 module clock
	STR R1, [R0]			    @ Write #2 to enable GPIO1 module clock

	LDR R0, =CM_PER_I2C1_CLKCTRL
	MOV R1, #0x02			    @ Value to enable I2C1 module clock
	STR R1, [R0]			    @ Write #2 to enable I2C1 module clock

	@ Enable FALLINGDETECT for button
	LDR R0, =GPIO1_FALLINGDETECT	    @ Address of GPIO1_FALLINGDETECT register
	LDR R1, [R0]			    @ Read word from register to enable falling edge of button
	MOV R2, #0x40000000		    @ (modify) word to enable FALLINGDETECT on bit 30
	ORR R1, R2, R1			    @ Write t0 set bit 30 to enable FALLINGDETECT
	STR R1, [R0]			    @ Store to enable FALLINGDETECT

	@ Change pin mapping on BBB P9 connectors to SCL and SDA lines
	LDR R0, =I2C1_SDA
	LDR R1, [R0]			    @ Read word from conf_spi0_d1 register to map SDA signal
	MOV R2, #0x32			    @ Word to enable SDA
	ORR R1, R2, R1			    @ (Modify) Enable SDA without affecting other bits
	STR R1, [R0]			    @ Write to map SDA signal

	LDR R0, =I2C1_SCL
	LDR R1, [R0]			    @ Read word from conf_spi0_cs0 register to map SCL signal
	MOV R2, #0x32			    @ Word to enable SCL
	ORR R1, R2, R1			    @ (Modify) Enable SCL without affecting other bits
	STR R1, [R0]			    @ Write to map SCL signal

	@ Scale I2C1 clock down to 12MHz
	LDR R0, =I2C1_PSC		    @ Load prescaler register
	MOV R1, #0x3			    @ Value + 1 is divisor to scale system clock
	STR R1, [R0]			    @ Write to revise 48 MHz system clock to 12 MHz for LCD

	@ Set I2C1 data rate to 100Kbps at 50% duty cycle
	LDR R0, =I2C1_SCLL		    @ 
	MOV R1, #0x35			    @ Value to set data rate
	STR R1, [R0]			    @ 

	LDR R0, =I2C1_SCLH		    @ 
	MOV R1, #0x37			    @ Second value to set data rate
	STR R1, [R0]			    @ 

	@ Configure I2C1 for master mode, transmission mode, 7-bit addressing, and take out of reset
	LDR R0, =I2C1_CON		    @ Load I2C1 configure register
	MOV R1, #0x8600			    @ 
	STR R1, [R0]			    @ Write word to configure I2C1 to be master transmitter

	@ Configure LCD slave address in BeagleBone Black
	LDR R0, =I2C1_SA		    @ Load slave address register
	MOV R1, #0x3C			    @ Slave address of LCD
	STR R1, [R0]			    @ Write value to configure slave address in processor

	@ Initialize LCD
	@ Set number of control bytes to be sent
	LDR R0, =I2C1_CNT		    @ Load I2C1 count register
	MOV R1, #0xA			    @ 
	STR R1, [R0]			    @ Configure count register for 10 control bytes

	BL BB_POLL			    @ Check if I2C1 bus is free
	BL START			    @ IF YES, assert START condition
	BL XRDY_POLL			    @ Check if transmit buffer is empty.  IF YES, send data
	
	LDR R0, =COMMAND_BYTES		    @ Get LCD initalization command bytes
	MOV R3, #0xA			    @ Load send loop counter value
	SEND_COMMANDS:
		BL SEND			    @ Send command byte
		SUBS R3, R3, #1		    @ Decrement loop counter
		BNE SEND_COMMANDS	    @ IF counter > 0, send another byte

	BL DELAY			    @ Delay to allow LCD to process commands

@*******************************************MESSAGE TRANSMISSION**************************************

	@ Display characters on LCD
	LDR R0, =I2C1_CNT		    @ Load I2C1 count register
	MOV R1, #0x10			    @ Value for 14 bytes to be sent
	STR R1, [R0]			    @ Configure count register for 14 command/character bytes 

	BL BB_POLL			    @ Check if I2C1 bus is free
	BL START			    @ IF YES, assert START condition
	BL XRDY_POLL		    	    @ Check if transmit buffer is empty.  IF YES, send data

	@ Send command byte to indicate character data byte transmission
	LDR R0, =DATA_BYTES	    	    @ Get character command/data bytes
	MOV R3, #0x10		    	    @ Load send loop counter value

	@ Send a character of message with each button press
	SEND_DATA:
		BL BUTTON_POLL		    @ Wait for button press
		BL SEND			    @ Send character data bytes
		BL SHORT_DELAY		    @ Delay to allow LCD to process character
		SUBS R3, R3, #1	   	    @ Decrement loop counter
		BNE SEND_DATA		    @ IF counter > 0, send another byte

	WAIT:
		B WAIT			    @ Dead loop at end of code

@************************************************PROCEDURES*******************************************

	@ Button poll
	BUTTON_POLL:

		LDR R11, =GPIO1_DATAIN	    @ Load GPIO1 read data register
		LDR R12, [R11]		    @ 
		TST R12, #0x40000000	    @ Check bit 30 for button press
		BNE BUTTON_POLL		    @ IF GPIO1_30 = 1 (button not pressed), check again
		
		MOV PC, LR		    @ ELSE, button pressed. Go back to mainline

	@ Bus Busy bit (BB) poll
	BB_POLL:

		LDR R0, =I2C1_IRQSTATUS_RAW @ Load I2C1 IRQ status register
		LDR R1, [R0]		    @ 
		TST R1, #0x1000		    @ Check bit 12 for bus busy
		BNE BB_POLL		    @ IF bit 12 = 1 (bus is busy), check BB bit again

		MOV PC, LR		    @ ELSE bus clear, go back to mainline

	@ Transmit Ready bit (XRDY) poll
	XRDY_POLL:

		LDR R0, =I2C1_IRQSTATUS_RAW @ Load I2C1 IRQ status register
		LDR R1, [R0]		    @ 
		TST R1, #0x10		    @ Check if bit 4 for transmit data ready
		BEQ XRDY_POLL		    @ IF bit 4 = 0 (transmission in progress), check again

		MOV PC, LR		    @ ELSE, transmit data ready.  Go back to mainline

	@ Send procedure
	SEND:

		LDRB R1, [R0], #1	    @ Load next byte to send, post increment pointer
		LDR R2, =I2C1_DATA	    @ Load I2C1 transmit buffer register
		STRB R1, [R2]		    @ Load next byte to send to LCD

		MOV PC, LR		    @ Go back to mainline

	START:

		LDR R0, =I2C1_CON	    @ Load I2C1 Configuration register
		LDR R1, =0x8603		    @ Value for START condition
		STR R1, [R0]		    @ Assert I2C START condition

		MOV PC, LR		    @ Go back to mainline

	DELAY:				    @ LCD initialization delay

		LDR R0, =0x1000000	    @ Delay loop counter value

		DELAY_LOOP:
			SUBS R0, R0, #1	    @ Count down by 1
			BNE DELAY_LOOP	    @ Count down to 0

		MOV PC, LR		    @ Go back to mainline
	
	SHORT_DELAY:			    @ LCD data delay
	
		LDR R10, =0x10000	    @ Delay counter value
		
		SHT_DELAY_LOOP:
			SUBS R10, R10, #1   @ Count down by 1
			BNE SHT_DELAY_LOOP  @ Count down to 0
			
		MOV PC, LR		    @ Go back to mainline

@***************************************************DATA**********************************************

.data
.align 4
COMMAND_BYTES:				    @ Command byte instructions to initialize LCD

	.byte 0x00			    
	.byte 0x38			    
	.byte 0x39
	.byte 0x14
	.byte 0x78
	.byte 0x5E
	.byte 0x6D
	.byte 0x0C
	.byte 0x01
	.byte 0x06


.align 4
DATA_BYTES:				    @ Character data byte instructions to spell name on LCD

	.byte 0x80			    @ Set Co bit
	.byte 0x06			    @ Set characters to display left to right
	.byte 0x40			    @ Byte to indicate character data (set RS bit, bit 6)

	.byte 0x53			    @ S
	.byte 0x68			    @ h
	.byte 0x61			    @ a
	.byte 0x75			    @ u
	.byte 0x6E			    @ n	    

	.byte 0x20			    @ (space)

	.byte 0x43			    @ C
	.byte 0x72			    @ r
	.byte 0x69			    @ i
	.byte 0x70			    @ p
	.byte 0x70			    @ p
	.byte 0x65			    @ e
	.byte 0x6E			    @ n

.end