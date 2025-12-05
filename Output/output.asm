;
; output.asm
;
; Created: 10/15/2025 2:10:47 PM
; Author : hazel
; Name   : Vanessa Gutierrez
; Desc   : example of an output circuit with an LED
; ---------------------------------------------------------

.equ LED_DIR = DDRB
.equ LED_OUT = PORTB
.equ LED_IN  = PINB
.equ LED_PIN = PB2


; sbi == Set bit in I/O == make the bit a 1       mnemonic = reg, bit
; cbi == Clear bit in I/O == make the bit a 0     mnemonic = reg, bit


main:
          ; GPIO setup
          sbi       LED_DIR, LED_PIN              ; Set LED pin in output mode 
          cbi       LED_OUT, LED_PIN              ; Turn the LED off

          ldi       r20, (1 << LED_PIN)           ; LED mask


main_loop:
          call      delay                         ; Keep the LED on/off for 1 second

          in        r0, LED_OUT                   ; Read LED status
          eor       r0, r20                       ; Toggle LED
          out       LED_OUT, r0                   


end_main:
          rjmp      main_loop



delay:
; wait for 1 sec at 16MHZ
; 5 cycles * 250 * 200 * 64 = 16,000,000 cycles
; ---------------------------------------------------------
          ldi       r18, 64                       ; r18 == 64

wait_1s_1:                                        ; do
          ldi       r17, 200                      ; r17 == 200

wait_1s_2:                                        ; do
          ldi       r16, 250                      ; r16 == 250

wait_1s_3:                                        ; do
          nop                                     ; Waste a clock cycle
          nop                                     ; Waste a clock cycle
          dec       r16                           ; r16--   (1 clock cycle)
          brne      wait_1s_3                     ; while (r16 > 0), go to wait_1s_3 (2 clock cycles) // 1250

          dec       r17                           ; r17--   (1 clock cycle)
          brne      wait_1s_2                     ; while (r17 > 0), go to wait_1s_2 (2 clock cycles) // 2500

          dec       r18                           ; r18--   (1 clock cycle)
          brne      wait_1s_1                     ; while (r18 > 0), go to wait_1s_2 (2 clock cycles) // 16000000

          ret                                     ; loop back as long as conditions are true