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

	@ Load GPIOA base address for button reading
	LDR R0, GPIOA_BASE
	@ R3 will be used to store button states
	MOVS R3, #0

main_loop:
	@ Read button states from GPIOA input data register
	LDR R4, [R0, #0x10]	@ Load GPIOA input data (IDR register)
	
	@ Check if SW2 (bit 2) is pressed for pattern control
	TST R4, #0x04			@ Test bit 2 (SW2)
	BNE sw2_not_pressed		@ If bit is 1 (not pressed), check other buttons
	
	@ SW2 is pressed - set pattern to 0xAA and skip increment
	MOVS R2, #0xAA			@ Set LED pattern to 0xAA
	B update_leds
	
sw2_not_pressed:
	@ SW2 not pressed - check SW0 for increment value
	TST R4, #0x01			@ Test bit 0 (SW0)
	BNE sw0_not_pressed		@ If bit is 1 (not pressed), skip
	
	@ SW0 is pressed - increment by 2
	ADDS R2, R2, #2
	B check_overflow
	
sw0_not_pressed:
	@ SW0 not pressed - increment by 1 (default behavior)
	ADDS R2, R2, #1
	
check_overflow:
	@ Check if counter overflowed (went past 0xFF)
	CMP R2, #0x100
	BLO no_overflow
	MOVS R2, #0         	@ Reset to 0 if overflow
	
no_overflow:
update_leds:
	@ Write current LED value to GPIOB
	STR R2, [R1, #0x14]
	
	@ Check if SW1 (bit 1) is pressed for timing control
	TST R4, #0x02			@ Test bit 1 (SW1)
	BNE sw1_not_pressed		@ If bit is 1 (not pressed), use long delay
	
	@ SW1 is pressed - use short delay (0.3 seconds)
	BL delay_300ms
	B continue_loop
	
sw1_not_pressed:
	@ SW1 not pressed - use long delay (0.7 seconds)
	BL delay_700ms
	
continue_loop:
	@ Branch back to main loop
	B main_loop


@ Delay function for 0.7 seconds
delay_700ms:
	PUSH {R3, R4, R5}   	@ Save registers
	LDR R3, LONG_DELAY_CNT	@ Load delay counter value
	MOVS R4, #0         	@ Initialize outer loop counter
	
@ Delay function for 0.3 seconds
delay_300ms:
	PUSH {R3, R4, R5}   	@ Save registers
	LDR R3, SHORT_DELAY_CNT	@ Load short delay counter value
	MOVS R4, #0         	@ Initialize outer loop counter
	
delay_short_outer:
	CMP R4, R3
	BHS delay_short_done
	MOVS R5, #0         	@ Initialize inner loop counter
	
delay_short_inner:
	CMP R5, R3
	BHS delay_short_inner_done
	ADDS R5, R5, #1
	B delay_short_inner
	
delay_short_inner_done:
	ADDS R4, R4, #1
	B delay_short_outer
	
delay_short_done:
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
LONG_DELAY_CNT: 	.word 0xFFFF		@ For 0.7 seconds
SHORT_DELAY_CNT: 	.word 0x6AAA		@ For 0.3 seconds (approximately 0.43 of long delay)
