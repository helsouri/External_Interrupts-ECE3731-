# External_Interrupts-ECE3731-
## Summary
I aim to have an ongoing event that happens (flashing green) and then interrupt that event through external inputs. <br>
That is to be achieved through the use of assembly language and an interrupt-driven approach. <br>
This project was divided into two parts a pre lab and a post lab<br> <br>
Files included: <br>
1) The pdf with details requirements <br>
2) The detailed pdf report inlcuding procedure and details <br>
3) The main.asm files for both parts (This is the assembly code) [This will not assebmle without proper configurtion {check #4}]<br> 
4) Both parts as a zip file containing all configurations of board for proper assembling [These also include the main] <br> <br>
**Note that the report contains both parts of the assembly code**<br>
**Also note that this is HCS12 assembly and needs the HCS12 board to be flashed on along with _CodeWarriors_ the assembler**
## INTRODUCTION
Often an external input may trigger a certain event. Your Dragon12 board supports
external interrupts on PTH (Port H), which conveniently has switches connected to it.
There are two types of switches connected to Port H (as you already know from the
previous lab).
DIP (dual-inline pin) switches – 8 switches that can set corresponding bits high (up) or
low (down).
Pushbutton switches – 4 switches on the 4 lower bit positions. These switches are termed
“active low”. (The DIP switches on the lower four-bit positions are set high (up) to avoid
interfering with the pushbutton switches.)
Pressing a pushbutton switch causes a high to low logic transition, which causes an
interrupt flag bit to be set since the switches are on Port H, which supports a type of
external interrupt called “key-wake-up”. A flag bit can cause an interrupt, if enabled to do
so.
## ASSIGNMENT
**PART A**: -interrupt driven interface
This program is to have a main program loop and one interrupt service routine. <br>
(i) Main Program Loop: <br>
The main program also has code or calls code to initialize an interrupt on PORT H.
The main Program constantly calls a Subroutine that flashes the GREEN LED 10 times
on the RGB display at a 2Hz rate as a type of “heartbeat” display.
(This means on for 250ms and off for 250 ms.)
(You do not need to use the timer subsystem to create the 250 ms delay.)
This is done in an endless loop.<br>
(ii) Interrupt Service Routine:<br>
The interrupt service routine responds to an external interrupt on PORT H (PTH).
Specifically, your program is written so that any one of the pushbutton switches PH0,
PH1 and PH2 can cause an interrupt. (There is one interrupt service routine for PTH
which handles all of these switches.)
The interrupt service routine determines which switch caused the interrupt, by testing IF
flag bits, not the switches and performs the corresponding action for the switch.
The Actions are as follows:<br> <br>
_PH0:_ <br>
- The value of all bits on Port H are read.<br>
- The four leftmost bits as set by the DIP switch bank, represent a 4-bit counter
value for this program.<br>
- PH0 causes the four leftmost bits on PTH to be written to the four rightmost bits
of PORTB (LED's). (PH7-4 are written to PORTB3-0 resp.) The upper 4-bits of
PORTB will always be cleared.<br>
- A message is displayed on LCD that SW0 is pressed.<br>

_PH1:_<br>
- The value of the 4-bit counter displayed on PORTB (LED's) is incremented by
one.<br>
- When a value of four ones is reached (1111), the counter rolls over to zero (0000).<br>
- A message is displayed on LCD that SW1 is pressed.<br>
- Blue LED flashes 2 times<br>

*PH2:*<br>
- The value of the 4-bit counter displayed on PORTB (LED's) is decremented by
one.<br>
- When a value of zero is reached and the counter is decremented, it becomes 1111.<br>
- A message is displayed on LCD that SW1 is pressed.<br>
- Red LED flashes 2 times<br><br>

**PARTB:** -flag polling interface –no interrupts
You have to implement the same functionality as in Part (a) but you are not allowed to
use interrupts, but instead polls the interrupt flag bits.
This program is a polling flag driven interface between the DIP switch bank and
pushbuttons on Port H and the 9S12 CPU. Port H bits 7-4 (upper 4-bits) represent the
data inputs. Port H bit 0 (PH0) going high to low sets an interrupt flag. This flag is what
is referred to as a Strobe signal indicating a command to input the 4-bit data value from
PTH 7-4 as currently set by the DIP switches.
