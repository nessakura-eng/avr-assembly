;
; delay_counter.asm
;
; Created: 11/5/2025 1:55:03 PM
; Author : hazel
; Name   : Vanessa Gutierrez
; Desc   : Control a delay using a counter with timer
; ---------------------------------------------------------


; Declare constants and global variables
; ---------------------------------------------------------
                ;   us  * (XTAL / scaler) - 1
.equ DELAY_MS   = 100000 * (16 / 256.0) - 1

.equ LED_PIN    = PB2
.equ INC_BTN    = PD5
.equ DEC_BTN    = PD2

.equ MIN_COUNT  = 5
.equ MAX_COUNT  = 60

.def decFlag    = r21
.def incFlag    = r22
.def tmFlag     = r23

.equ ledCounter = 0x0100

; Vector Table
; ---------------------------------------------------------
.org 0x0000                                                 ; Reset
          jmp       main

.org INT0addr                                               ; External Interrupt Request 0 (Port-D Pin-2)
          jmp       btn_dec_isr

.org INT1addr                                               ; External Interrupt Request 1 (Port-D Pin-3)
          jmp       btn_inc_isr

.org OC1Aaddr                                               ; Timer/Counter 1 Compare Match A
          jmp       timer_isr

.org INT_VECTORS_SIZE                                       ; End vector table

; One-time configuration
; ---------------------------------------------------------
main:
          ; Initialize GPIO
          sbi       DDRB, LED_PIN                           ; LED output mode

          ; Set up decrement button
          cbi       DDRD, DEC_BTN                           ; Input mode
          cbi       PORTD, DEC_BTN                          ; Hi-Impedance mode

          sbi       EIMSK, INT0                             ; External Interrupt 0 on pin D2
          ldi       r16, (0b0011 << ISC00)
          sts       EICRA, r16                              ; Rising edge trigger

          ; Set up increment button
          cbi       DDRD, INC_BTN                           ; Input mode
          sbi       PORTD, INC_BTN                          ; Pull-up

          sbi       EIMSK, INT1                             ; External Interrupt 1 on pin D3
          ldi       r16, (0b0010 << ISC10)
          lds       r4, EICRA                               ; Read prior state
          or        r16, r4                                 ; Update with prior
          sts       EICRA, r16                              ; Falling edge trigger


          ; Initialize LED counter
          ldi       r16, MIN_COUNT                          ; Start counter
          sts       ledCounter, r16               

          sei                                               ; Turn global interrupts on

; Application main loop
; ---------------------------------------------------------
main_loop:

check_inc:

          tst       incFlag                                 ; if (incFlag)
          breq      check_dec                               ;         else check dec
                                                            ; {
          ; Increment counter
          lds       r0, ledCounter
          inc       r0
          call      check_range                             ; Check in range
          sts       ledCounter, r0
          clr       incFlag                                 ; incFlag = false

          rjmp      do_blink
                                                            ; }
check_dec:
          
          tst       PIND, DEC_BTN                           ; else if (decFlag)
          breq      end_blink                               ;         else don't blink
                                                            ; {
          ; Decrement counter
          lds       r0, ledCounter
          dec       r0
          call      check_range                             ; Check in range
          sts       ledCounter, r0
          clr       decFlag                                 ; decFlag = false
                                                            
do_blink:
          call      blink_led

end_blink:                                                  ; }

end_main:
          rjmp      main_loop

check_range:
; Check LED counter in min<-->max range
; @param r0 - current counter
; @return r0 - adjusted counter
; ---------------------------------------------------------
          ; Save used registers
          push      r16                                     ; min    
          push      r17                                     ; max

          ldi       r16, MIN_COUNT
          ldi       r17, MAX_COUNT

          cp        r0, r16                                 ; if (r0 < MIN_COUNT)
          brsh      check_max
          
          mov       r0, r16                                 ; r0 = MIN_COUNT

          rjmp      end_range

check_max:
          cp        r0, r17                                 ; else if (r0 > MIN_COUNT)
          brlo      end_range
          breq      end_range
          
          mov       r0, r17                                 ; r0 = MAX_COUNT

end_range:
          ; Restore saved registers
          pop       r17
          pop       r16

          ret                                               ; check_range

; Show LED for n milliseconds
; ---------------------------------------------------------
blink_led:
          sbi       PORTB, LED_PIN                          ; Turn LED on

          lds       r16, ledCounter                         ; r16 = ledCounter

delay_loop:                                                 ; do {

          call      delay

          dec       r16                                     ;    --r16
          brne      delay_loop                              ; } while (r16 > 0);
          
          cbi       PORTB, LED_PIN                          ; Turn LED off

          ret                                               ; blink_led 

; ---------------------------------------------------------
delay:

          ; 1. Load TCNT1H:TCNT1L with initial count
          clr       r20
          sts       TCNT1H, r20
          sts       TCNT1L, r20
                 
          ; 2. Load OCR1AH:OCR1AL with stop count
          ldi       r20, high(DELAY_MS)
          sts       OCR1AH, r20
          ldi       r20, low(DELAY_MS)
          sts       OCR1AL, r20

          ; 3. Load TCCR1A & TCCR1B
          clr       r20
          sts       TCCR1A, r20                             ; 1. CTC mode
          ldi       r20, (1 << WGM12) | (1 << CS12)
          sts       TCCR1B, r20                             ; 2. Clock Prescaler clk/256  – setting the clock starts the timer


          ldi       r20, (1 << OCIE1A)                      ; Interrupt mask
          sts       TIMSK1, r20

/*
          ; 4. Monitor OCF1A flag in TIFR1
monitor_OCF1A:
          sbis      TIFR1, OCF1A
          rjmp      monitor_OCF1A

          ; 5. Stop timer by clearing clock (clear TCCR1B)
          clr       r20
          sts       TCCR1B, r20

          ; 6. Clear OCF1A flag – write a 1 to OCF1A bit in TIFR1
          ldi       r20, (1 << OCF1A)
          out       TIFR1, r20

          ; 7. Repeat steps again for multiple timers
*/

          ret                                               ; Delay



; Handle decrement button press
; ---------------------------------------------------------
btn_dec_isr:
          
          ldi       decFlag, 1                              ; decFlag = true

          reti                                              ; btn_dec_isr (returning from an interrupt with this instruction)

; Handle increment button press
; ---------------------------------------------------------
btn_inc_isr:
          ldi       incFlag, 1                              ; incFlag = true

          reti                                              ; btn_inc_isr (returning from an interrupt with this instruction)


timer_isr:
          ldi       tmFlag, 1                               ; tmFlag = true

          ; 1. Load TCNT1H:TCNT1L with initial count
          clr       r20
          sts       TCNT1H, r20
          sts       TCNT1L, r20

          reti