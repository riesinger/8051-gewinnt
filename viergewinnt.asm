COLS EQU P0
ROWS EQU P1
KEYPAD EQU P2

SPIELER1 EQU 020h
SPIELER2 EQU 028h
SPIELER2AKTIV EQU 030h

cseg at 0h
ajmp init
cseg at 100h

org 0bh
call timer
reti

org 20h
; Init setzt Ausgänge und Speicherbereiche auf Initialwerte, aktiviert timer
init:
MOV P0, 000h
MOV P1, 000h
mov IE, #10010010b
mov tmod, #00000010b
mov R6, #00h
mov R7, #00h
mov tl0, #0c0h
mov th0, #0c0h
setb tr0
call display
clr C

loop:

JMP loop

; timer wird vom Timer-Interrupt gemerufen. Es inkrementiert den Counter in R7. Nach einer gewissen Zahl von Takten wird das Display angezeigt. Wird das Display angezeigt, wird in R6 inkrementiert, um bei jedem x-ten Aufruf Spieler 2 zu toggeln
timer:
INC R6
MOV A, R6
SUBB A, #04h ; Wenn bei der Subtraktion das Carry-Bit gesetzt wird, ist 4 größer als A
JNC timer_show
RET
timer_show:
INC R7
MOV A, R7
SUBB A, #02h ; Wenn bei der Subtraktion das Carry-Bit gesetzt wird, ist 2 größer als A
JNC timer_spieler2
timer_display:
MOV R6, #00h
CALL display
RET
timer_spieler2:
MOV R7, #00h
MOV A, SPIELER2AKTIV
JZ timer_spieler2_an ; Wenn akku Inhalt = SPIELER2AKTIV gleich 0
MOV SPIELER2AKTIV, #00h
JMP timer_display
timer_spieler2_an:
MOV SPIELER2AKTIV, #0FFh
JMP timer_display


; Display gibt das Spielbrett aus. Falls in SPIELER2AKTIV FFh steht, werden beide Zustände ausgegeben
display:
MOV A, SPIELER2AKTIV
ANL A, SPIELER2
ORL A, SPIELER1
MOV COLS, A
SETB ROWS.0
CLR ROWS.0
MOV A, SPIELER2AKTIV
ANL A, SPIELER2 + 1
ORL A, SPIELER1 + 1
MOV COLS, A
SETB ROWS.1
CLR ROWS.1
MOV A, SPIELER2AKTIV
ANL A, SPIELER2 + 2
ORL A, SPIELER1 + 2
MOV COLS, A
SETB ROWS.2
CLR ROWS.2
MOV A, SPIELER2AKTIV
ANL A, SPIELER2 + 3
ORL A, SPIELER1 + 3
MOV COLS, A
SETB ROWS.3
CLR ROWS.3
MOV A, SPIELER2AKTIV
ANL A, SPIELER2 + 4
ORL A, SPIELER1 + 4
MOV COLS, A
SETB ROWS.4
CLR ROWS.4
MOV A, SPIELER2AKTIV
ANL A, SPIELER2 + 5
ORL A, SPIELER1 + 5
MOV COLS, A
SETB ROWS.5
CLR ROWS.5
MOV A, SPIELER2AKTIV
ANL A, SPIELER2 + 6
ORL A, SPIELER1 + 6
MOV COLS, A
SETB ROWS.6
CLR ROWS.6
MOV A, SPIELER2AKTIV
ANL A, SPIELER2 + 7
ORL A, SPIELER1 + 7
MOV COLS, A
SETB ROWS.7
CLR ROWS.7
RET