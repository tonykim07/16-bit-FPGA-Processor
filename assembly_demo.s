
// Available Registers: r0 - r4 (r7 -> PC, r5 -> sp, r6 -> lr)
// 16-bit Processor
// memory: 0x0000 -> 0x00FF
// LED: 0x1000 
// HEX: 0x2000 (add #1 to access each HEX starting at 0)
// SW: 0x3000
// KEY: 
// Instructions available: mv, mvt, add, sub, and, ld, str, (and branch instructions), cmp, shift/rotate instructions, push, pop

// HEX Display counter 
// Main Loop with a countdown timer
// subroutines that call every <blank> counts of the HEX
// The HEX display will remember where it left off when it leaves and returns (push and pop)
// Subroutine timers will be implemented with the LEDs 
// Subroutine timers can increase or decrease in speed (use KEYs -> that it available) (speed change by shift Instructions)
// The HEX will display a message every time a subroutine is called
// 
DEPTH 4096

.define LED_ADDRESS 0x10
.define HEX_ADDRESS 0x20
.define SW_ADDRESS 0x30

START:		mv	    sp, =0x1000	//initialize sp

RESET:		mv      r0, #0
MAIN:       bl      REG // Displays r0 on Hex3-0
DO_DELAY:   mv      r4, =0xFFFF

SUB_LOOP0:   sub     r4, #1
            cmp     r4, #0
            bne     SUB_LOOP0
            mv      r4, =0xFFFF
SUB_LOOP1:   sub     r4, #1
            cmp     r4, #0
            bne     SUB_LOOP1
            mv      r4, =0xFFFF
SUB_LOOP2:   sub     r4, #1
            cmp     r4, #0
            bne     SUB_LOOP2
            mv      r4, =0xFFFF
SUB_LOOP3:   sub     r4, #1
            cmp     r4, #0
            bne     SUB_LOOP3
            mv      r4, =0xFFFF

SUB_LOOP:   sub     r4, #1
            cmp     r4, #0
            bne     SUB_LOOP

            cmp     r0, #33
            beq     DISPLAY_DELAY

            cmp     r0, #66
            beq     DISPLAY_DELAY

            cmp     r0, #99
            beq     DISPLAY_DELAY
            b       CHECK_RESET

DISPLAY_DELAY:
            bl      FLASH_DELAY

CHECK_RESET:
            cmp     r0, #99
            beq     RESET

MAIN_LOOP:  add     r0, #1
            b       MAIN

FLASH_DELAY:
            push    r0
            push    r1
            push    r2
            push    r3
            push    r4
            push    r6

            mv     r2, #_DELAY
            mvt    r4, #HEX_ADDRESS
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display

            mv     r0, #0 // delay counter

LEDR:       add    r0, #1
            mvt    r1, #LED_ADDRESS
            st     r0, [r1]
            mv     r4, =0x1FF
            cmp    r0, r4
            beq    END_SUB

DELAY:      
            mvt    r4, #SW_ADDRESS
            ld     r2, [r4]
            mvt    r4, #0x01
            add    r4, #0xFF
            and    r2, r4

OUTER:      mv     r1, =0xFFFF
            
INNER:      sub     r1, #1
            cmp     r1, #0
            bne     INNER

            cmp     r2, #0
            sub     r2, #1
            bne     OUTER
            b       LEDR
            
END_SUB:    
            mv     r2, #_EMPTY
            mvt    r4, #HEX_ADDRESS
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display
            add    r2, #1                // ++increment character pointer 
            add    r4, #1                // point to next HEX display
            ld     r3, [r2]              // get letter 
            st     r3, [r4]              // send to HEX display

            pop     r6
            pop     r4 
            pop     r3 
            pop     r2 
            pop     r1 
            pop     r0 
            mv      pc, lr

_DELAY:     .word  0b0000000001101110   // 'Y'
		    .word  0b0000000001110111   // 'A'
			.word  0b0000000000111000   // 'L'
			.word  0b0000000001111001   // 'E'
			.word  0b0000000001011110   // 'D'

_EMPTY:     .word  0b0   
		    .word  0b0   
			.word  0b0   
			.word  0b0   
			.word  0b0   

// subroutine that displays register r0 (in hex) on HEX3-0
REG:		push    r1
            push    r2
            push    r3
            mvt     r2, #HEX_ADDRESS // point to HEX0
            mv      r3, #0 // used to shift digits
DIGIT:      mv      r1, r0 // the register to be displayed
            lsr     r1, r3 // isolate digit
            and     r1, #0xF // " " " "
            add     r1, #SEG7 // point to the codes
            ld      r1, [r1] // get the digit code
            st      r1, [r2]
            add     r2, #1 // point to next HEX display
            add     r3, #4 // for shifting to the next digit
            cmp     r3, #16 // done all digits?
            bne     DIGIT
            pop     r3
            pop     r2
            pop     r1
            mv      pc, lr


SEG7:       .word 0b00111111 // ’0’
            .word 0b00000110 // ’1’
            .word 0b01011011 // ’2’
            .word 0b01001111 // ’3’
            .word 0b01100110 // ’4’
            .word 0b01101101 // ’5’
            .word 0b01111101 // ’6’
            .word 0b00000111 // ’7’
            .word 0b01111111 // ’8’
            .word 0b01100111 // ’9’
            .word 0b01110111 // ’A’ 1110111
            .word 0b01111100 // ’b’ 1111100
            .word 0b00111001 // ’C’ 0111001
            .word 0b01011110 // ’d’ 1011110
            .word 0b01111001 // ’E’ 1111001
            .word 0b01110001 // ’F’ 1110001