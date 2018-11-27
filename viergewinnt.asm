COLS EQU P0
ROWS EQU P1
KEYPAD EQU P2

AKTIVERSPIELER EQU 18h
; Eingabebereit wenn 20.0 = 1
EINGABEBEREIT EQU 00h

SPIELER1 EQU 038h
SPIELER2 EQU 040h
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
MOV COLS, 000h
MOV ROWS, 000h
mov IE, #10010010b
mov tmod, #00000010b
mov R7, #00h
mov tl0, #0c0h
mov th0, #0c0h
setb tr0
mov aktiverspieler, #spieler1
call display
setb EINGABEBEREIT
clr C

loop:
; Eingabe abfragen
call eingabe_abfragen
; Spielstand aktualisieren

; Spieler wechseln

JMP loop

; timer wird vom Timer-Interrupt gemerufen. Es inkrementiert den Counter in R7. Nach einer gewissen Zahl von Takten wird das Display angezeigt. Wird das Display angezeigt, wird in R6 inkrementiert, um bei jedem x-ten Aufruf Spieler 2 zu toggeln
timer:
INC R7
MOV A, R7
SUBB A, #01h ; Wenn bei der Subtraktion das Carry-Bit gesetzt wird, ist 1 größer als A
JNC timer_spieler2
timer_display:
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

eingabe_abfragen:
; Wenn wir nicht eingabebereit sind, dann gehen wir wieder zurück
jnb eingabebereit, eingabe_fertig
; Lesen, welcher Button auf dem Keypad gedrückt wurde
; R3 = Eingabe
mov a, p2
cpl a
mov r3, a
; TODO: Gegebenenfalls überprüfen, ob mehrere Buttons gedrückt wurden
; R2 = Schleifenzähler
mov r2, #07h

vergleich:

mov a, #SPIELER1
add a, r2
mov r0, a
mov a, @R0
anl a, r3
mov r1, a

mov a, #SPIELER2
add a, r2
mov r0, a
mov a, @R0
anl a, r3

orl a, r1
; Wir können einfügen
jz einfuegen
; Schleifenabbruch
mov a, r2
jz eingabe_fertig

dec r2
jmp vergleich

einfuegen:
mov a, AKTIVERSPIELER
add a, r2
mov r0, a
mov a, @r0
orl a, r3
mov @r0, a

eingabe_fertig:
ret

end