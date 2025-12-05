;
; input_hi.asm
;
; Created: 10/15/2025 2:10:47 PM
; Author : hazel
; Name   : Vanessa Gutierrez
; Desc   : intro to input with high impedence
; ---------------------------------------------------------

.equ LED_DIR = DDRB
.equ LED_OUT = PORTB
.equ LED_IN  = PINB
.equ LED_PIN = PB2


.equ BTN_DIR = DDRD
.equ BTN_OUT = PORTD
.equ BTN_IN  = PIND
.equ BTN_PIN = PD2


; sbi == Set bit in I/O == make the bit a 1       mnemonic = reg, bit
; cbi == Clear bit in I/O == make the bit a 0     mnemonic = reg, bit


main:
          ; GPIO setup
          sbi       LED_DIR, LED_PIN              ; Set LED pin in output mode 
          cbi       LED_OUT, LED_PIN              ; Turn the LED off

          cbi       BTN_DIR, BTN_PIN              ; Set button in input mode
          cbi       BTN_OUT, BTN_PIN              ; Set high impedence

          ldi       r21, (1 << BTN_PIN)           ; Button pin mask
          ldi       r22, (1 << LED_PIN)           ; LED pin mask

main_loop:

          ; wait for button input
          
wait_for_btn:
         
          sbis      BTN_IN, BTN_PIN
          rjmp      wait_for_btn

          ; Toggle LED
          in        r0, LED_IN                    ; Get current LED state
          eor       r0, r22                       ; Toggle LED pin
          out       LED_OUT, r0                   ; Update LED pin state
          
          call      delay                         ; Button debounce 

end_main:
          rjmp      main_loop


delay:
; 1/4 second delay
; ---------------------------------------------------------
          ldi       r18, 4

wait_1s_1:          
          ldi       r17, 200

wait_1s_2:
          ldi       r16, 250

wait_1s_3:
          nop
          nop
          dec       r16
          brne      wait_1s_3

          dec       r17
          brne      wait_1s_2

          dec       r18
          brne      wait_1s_1

          ret