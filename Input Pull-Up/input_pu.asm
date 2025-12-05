;
; input_pu.asm
;
; Created: 10/15/2025 2:10:47 PM
; Author : hazel
; Name   : Vanessa Gutierrez
; Desc   : intro to input with pull up
; ---------------------------------------------------------

.equ LED_DIR = DDRB
.equ LED_OUT = PORTB
.equ LED_PIN = PB2

.equ BTN_DIR = DDRD
.equ BTN_OUT = PORTD
.equ BTN_IN  = PIND
.equ BTN1_PIN = PD2
.equ BTN2_PIN = PD5


; sbi == Set bit in I/O == make the bit a 1       mnemonic = reg, bit
; cbi == Clear bit in I/O == make the bit a 0     mnemonic = reg, bit



main:

          ; GPIO setup

          sbi       LED_DIR, LED_PIN              ; Set LED pin in output mode
          cbi       LED_OUT, LED_PIN              ; Turn the LED off


          cbi       BTN_DIR, BTN1_PIN             ; Set button 1 in input mode
          cbi       BTN_OUT, BTN1_PIN             ; Set high impedance

          cbi       BTN_DIR, BTN2_PIN             ; Set button 2 in input mode
          sbi       BTN_OUT, BTN2_PIN             ; Set pull-up


main_loop:
    
          ; Check button 1
   
          sbic      BTN_IN, BTN1_PIN              ; If button 1 is pressed (button 1 == HIGH)
          rjmp      led_on                        ; Turn LED on
          rjmp      check_btn2                    ; Else, check button 2


check_btn2:

          ; Check button 2

          sbis      BTN_IN, BTN2_PIN              ; If button 2 is pressed (button 2 == LOW)      
          rjmp      led_off                       ; Turn LED off
          rjmp      main_loop                     ; Else, recheck buttons again        


led_on:
          sbi       LED_OUT, LED_PIN              ; Turn LED on
          call      delay                         ; Button debounce
          rjmp      main_loop                     ; Recheck buttons

led_off:
          cbi       LED_OUT, LED_PIN              ; Turn LED off
          call      delay                         ; Button debounce       

end_main:
          rjmp      main_loop                     ; Exit


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