;
; CountingLoop1.asm
;
; Created        : 9/24/2025 1:40:13 PM
; Name           : Vanessa Gutierrez
; Course         : Computer Organization & Assembly Language - CDA 3104
; Assignment Name: Counting Loop with a for Structure
; Desc           : Program that loops to add 2 for n times with a for loop
;-----------------------------------------------------------

main: 
          CLR       R16                 ; i = 0

FOR_ADD2:
          CPI       R16, 5              ; does i == n? (in this case n = 5)
          BREQ      end_main            ; if true, break out of the for loop
          INC       R0                  ; x += 1
          INC       R0                  ; x += 1
          INC       R16                 ; i++
          RJMP      FOR_ADD2            ; re-enter the for loop (i is still less than n, condition i < n is still satisfied)

end_main:
          RJMP      end_main            ; end of program