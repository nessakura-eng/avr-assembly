;
; HelloAsm.asm
;
; Created: 9/24/2025 1:40:13 PM
; Author : hazel
; Desc   : Program that writes "Hi ASM!"
-----------------------------------------------------------

.equ SPACE = 0x20                       ; Space character
.equ EXCLM = SPACE + 1                  ; Exclamation point

main: 
          ldi       r16, 'H'            ; Load 'H' as the first character
          sts       0x0100, r16         ; Store to the 1st address in ISRAM

          inc       r16                 ; Increments the ASCII code of 'H' to 'I'
          ori       r16, 32             ; Make the 'I' a lowercase 'i'
          sts       0x0101, r16         ; Store next to 'H' in ISRAM memory

          ldi       r16, SPACE          ; Load a space to differention the word 'Hi' from the next word
          sts       0x0102, r16         ; Store next to 'i' in ISRAM memory

          ldi       r16, 'A'            ; Load 'A'
          sts       0x0103, r16         ; Store next to the space character in ISRAM memory

          ldi       r16, 'S'            ; Load 'S'
          sts       0x0104, r16         ; Store next to 'A' in ISRAM memory

          subi      r16, 6              ; Decrements the ASCII code of 'S' by 6 to get 'M'
          sts       0x0105, r16         ; Store next to 'S' in ISRAM memory

          ldi       r16, EXCLM          ; Load '!'
          sts       0x0106, r16         ; Store next to 'M' in ISRAM memory


end_main:
          rjmp      end_main