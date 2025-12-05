;
; blink.asm
;
; Created: 10/15/2025 2:10:47 PM
; Author : hazel
; Desc   : blink an LED on pin 13
; ---------------------------------------------------------

main:

          ; GPIO setup
          sbi       DDRB, DDB5
          cbi       PORTB, PB5




main_loop:

          call      delay

          sbi       PORTB, PB5

          call      delay

          cbi       PORTB, PB5


end_main:
          rjmp      main_loop



delay:

; ---------------------------------------------------------

          ; Load TCNT0 with initial count
          ldi       r20, 256 - (4000 * (16 / 256.0))        ; max - (delay * (clock cycle / prescaler))
          out       TCNT0, r20


          ; Load TCCR0A & TCCR0B
          clr       r20                                     ; Normal mode
          out       TCCR0A, r20

          ldi       r20, (1 << CS02)                        ; Clock prescaler set to 256 -> clk / 256
          out       TCCR0B, r20


          ; Monitor TOV0 flag in TIFR0
delay_tov0:
          sbis      TIFR0, TOV0
          rjmp      delay_tov0


          ; Stop timer by clearing clock (clear TCCR0B)
          clr       r20
          out       TCCR0B, r20


          ; Clear TOV0 flag – write a 1 to TOV0 bit in TIFR0
          sbi       TIFR0, TOV0


          ; Repeat steps again for multiple timers

          ret