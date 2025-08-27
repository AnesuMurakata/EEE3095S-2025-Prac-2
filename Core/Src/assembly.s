/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
	@ Write current LED value to GPIOB
	STR R2, [R1, #0x14]

	@ Call delay function for 0.7 seconds
	BL delay_700ms

	@ Increment LED counter by 1
	ADDS R2, R2, #1

	@ Check if counter overflowed (went past 0xFF)
	CMP R2, #0x100
	BLO no_overflow
	MOVS R2, #0         	@ Reset to 0 if overflow

no_overflow:
	@ Branch back to main loop
	B main_loop


@ Delay function for 0.7 seconds
delay_700ms:
	PUSH {R3, R4, R5}   	@ Save registers
	LDR R3, LONG_DELAY_CNT	@ Load delay counter value
	MOVS R4, #0         	@ Initialize outer loop counter
	
delay_outer:
	CMP R4, R3
	BHS delay_done
	MOVS R5, #0         	@ Initialize inner loop counter
	
delay_inner:
	CMP R5, R3
	BHS delay_inner_done
	ADDS R5, R5, #1
	B delay_inner
	
delay_inner_done:
	ADDS R4, R4, #1
	B delay_outer
	
delay_done:
	POP {R3, R4, R5}    	@ Restore registers
	BX LR                	@ Return from function

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 0xFFFF
SHORT_DELAY_CNT: 	.word 0xFFFF
