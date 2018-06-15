;*****************************************************************
;* KeyWakeup.ASM
;* 
;*****************************************************************
; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 
		
;-------------------------------------------------- 
; Equates Section  
;----------------------------------------------------  
ROMStart    EQU  $2000  ; absolute address to place my code
RED:        EQU     $10    ; PP4
BLUE:       EQU     $20    ; PP5
GREEN:      EQU     $40    ; PP6

;---------------------------------------------------- 
; Variable/Data Section
;----------------------------------------------------  
            ORG RAMStart   ; loc $1000  (RAMEnd = $3FFF)
; Insert here your data definitions here

COUNT1 dc.b 0
COUNT2 dc.b 0
COUNT3 dc.b 0
COUNT4 dc.b 0
COUNT5 DC.B 0

COUNTB dc.b 0

MSG1       FCC  "SW0 is pressed"
            dc.b  0
MSG2       FCC  "SW1 is pressed"
            dc.b 0
MSG3       FCC  "SW2 is pressed"
            dc.b  0
            

       INCLUDE 'utilities.inc'
       INCLUDE 'LCD.inc'

;---------------------------------------------------- 
; Code Section
;---------------------------------------------------- 
            ORG   ROMStart  ; loc $2000
Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9
            JSR   PLL_init      ; initialize PLL  
  endif

;---------------------------------------------------- 
; Insert your code here
;---------------------------------------------------- 
         LDS   #ROMStart ; load stack pointer
* Port H interrupt program for Dragon12
* Lights LED 0 (and clears LED1) when sw5 is pressed (PH0)
* Lights LED 1 (and clears LED0) when sw4 is pressed (PH1)
          jsr led_enable
; note Port H is all inputs after reset
          jsr   lcd_init    ; initialize LCD (must be done first)
          BCLR    PPSH, #$07  ; set Port H pins 0-1-2 for falling edge
Flash_Green_Led          
          JSR FLASH_GREEN
          BRA Flash_Green_Led

; Note: main program is an endless loop and subroutines follow
; (Must press reset to quit.)

;===================================================================

;************FUNCTIONS

FLASH_GREEN
 JSR   clear_lcd     ;Clear the LCD
 CLR COUNT1     ;clear count 1
 CLR COUNT5
 bclr PTP, RED+GREEN+BLUE ; clear all
LOOP1
 bset PTP, GREEN ; turn on GREEN
 ldd #250 ; 250ms delay
 jsr ms_delay ; delay for 0.25 second
 bclr PTP, RED+GREEN+BLUE ; clear all
 ldd #250 ; 250ms delay
 jsr ms_delay ; delay for 0.25 second
 ldaa COUNT1  ; load value of count1 into REG A
 inca         ;increment A
 STAA COUNT1  ;store result in count
 cmpa #10     ;compare to 10
 bne LOOP1    ; loop back if not equal
LOOP_HERE
 LDAA COUNT5 
 jsr    PTHISR
 CMPA #3
 bne LOOP_HERE
 INCA
 STAA COUNT5
 RTS 
FLASH_BLUE
              CLR COUNT3    ;clear count3 
              bclr PTP, RED+GREEN+BLUE ; clear all
LOOP2
              bset PTP, BLUE ; turn on blue
              ldd #500 ; 500ms delay
              jsr ms_delay ; delay for 0.25 second
              bclr PTP, RED+GREEN+BLUE ; clear all
              ldd #200 ; 200ms delay
              jsr ms_delay 
              ldaa COUNT3 ;load value of count3 into reg A
              inca            ;inc value reg A
              STAA COUNT3   ;store baxk in count3
              cmpa #2
              BNE LOOP2
              rts          
FLASH_RED
              CLR COUNT4
              bclr PTP, RED+GREEN+BLUE ; clear all
LOOP3
              bset PTP, RED ; turn on RED
              ldd #500 ; 500ms delay
              jsr ms_delay ; delay for 0.25 second
              bclr PTP, RED+GREEN+BLUE ; clear all
              ldd #200 ; 200ms delay
              jsr ms_delay 
              ldaa COUNT4
              inca
              STAA COUNT4
              cmpa #2
              BNE LOOP3
              rts
; ISR must test to see which button was pressed, because there ;is only one ISR for the two enabled buttons

PTHISR:  ; the interrupt service routine
         BRSET  PIFH, %00000001,PUSHBTN0  ; test btn0 IF flag
         BRSET  PIFH, %00000010,PUSHBTN1  ; test btn1 IF flag
         BRSET  PIFH, %00000100,PUSHBTN2  ; test btn2 IF flag 
; NOTE:  Flags are tested –not the switches
         LBRA Flash_Green_Led  
PUSHBTN0:
          bclr PTP, RED+GREEN+BLUE ; clear all
          JSR   clear_lcd     ;Clear the LCD
          CLR COUNT2          ;clear count 2
          ldab PTH
GET_BITS
          ldaa COUNT2         ;loads value of count2
          LSRB                ;shifts content of B to the right
          inca
          staa COUNT2
          cmpa #4             ; shifts 4 times tpo get 4 MSB
          BNE GET_BITS
          STAB PORTB          ; stores value of B on PORTB
          STAB COUNTB         ; stores Value of reg B into a count specific for portB
          ldab  #$0           ; set print position to top line
          jsr   set_lcd_addr  ;      "
          ldd   #MSG1       ; D is pointer to string
          jsr lcd_prtstrg;   ; print first string
          MOVB  #$01, PIFH    ; CLEAR FLAG FOR BIT 1
          rts
PUSHBTN1:
        bclr PTP, RED+GREEN+BLUE ; clear all
        JSR   clear_lcd     ;Clear the LCD
        ldab COUNTB
        cmpb #$F
        BEQ RESET_COUNT
        BMI INC_COUNT
INC_COUNT        
        incb
        STAB COUNTB
        stab PORTB
        ldab  #$0           ; set print position to top line
        jsr   set_lcd_addr  
        ldd   #MSG2       ; D is pointer to string
        jsr lcd_prtstrg   ; print first string
        MOVB  #$02, PIFH    ; CLEAR FLAG FOR BIT 2 
        LBRA FLASH_BLUE
RESET_COUNT
        CLR COUNTB
        ldab COUNTB
        STAB PORTB
        ldab  #$0           ; set print position to top line
        jsr   set_lcd_addr  ;      "
        ldd   #MSG2       ; D is pointer to string
        jsr lcd_prtstrg;   ; print first string 
        MOVB  #$02, PIFH    ; CLEAR FLAG FOR BIT 2                
        LBRA FLASH_BLUE
PUSHBTN2
        bclr PTP, RED+GREEN+BLUE ; clear all
        JSR   clear_lcd     ;Clear the LCD
        ldab COUNTB
        cmpb #$0
        BEQ RESET_COUNT1
        BNE DEC_COUNT
DEC_COUNT        
        DECB
        STAB COUNTB
        stab PORTB
        ldab  #$0           ; set print position to top line
        jsr   set_lcd_addr  
        ldd   #MSG3       ; D is pointer to string
        jsr lcd_prtstrg   ; print first string
        MOVB  #$04, PIFH    ; CLEAR FLAG FOR BIT 3
        LBRA FLASH_RED
RESET_COUNT1
        LDAB #$F
        STAB COUNTB
        STAB PORTB
        ldab  #$0           ; set print position to top line
        jsr   set_lcd_addr  ;      "
        ldd   #MSG3       ; D is pointer to string
        jsr lcd_prtstrg;   ; print first string
        MOVB  #$04, PIFH    ; CLEAR FLAG FOR BIT 3                
        LBRA FLASH_RED      
                           
;******************** useful code***********
    ;ldab  #$44         ; set print position in bottom line
          ;jsr   set_lcd_addr  ;   "
          ;ldd   #MSG1B      ; D is pointer to string
          ;jsr   lcd_prtstrg  ; print second string
          ;BSET  PORTB, $01    ; light LED0 if button 0 pressed
          ;BCLR  PORTB, $02    ; and clear LED1
                      
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   Vreset
            DC.W  Entry         ; Reset Vector
            
;***********************************************************
            ORG     Vporth     ; setup  Port H interrupt Vector
            DC.W    PTHISR
                            
 