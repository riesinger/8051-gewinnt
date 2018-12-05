COLS EQU P0
ROWS EQU P1
KEYPAD EQU P2

AKTIVERSPIELER EQU 18h
; Eingabebereit wenn 20.0 = 1
EINGABEBEREIT EQU 00h

SPIELER1 EQU 038h
SPIELER2 EQU 040h
SPIELER2AKTIV EQU 030h

; SHOW_ROW legt den aktuellen Spielstand der übergebenen Zeile auf P0 an.
; Dabei wird der Spielstand von Spieler 2 durch blinken dargestellt (SPIELER2AKTIV = #0ffb)
SHOW_ROW  MACRO row
	MOV A, SPIELER2AKTIV
	ANL A, SPIELER2 + row
	ORL A, SPIELER1 + row
	MOV COLS, A
ENDM

CMP_HORIZ MACRO num
	mov a, R1
	clr c
	subb a, num
	jc spielstand_horiz_exit
	jz win
ENDM

cseg at 0h
ajmp init
cseg at 100h

org 0bh
mov 19h, a
call timer
mov a, 19h
reti

org 20h
; Init setzt Ausgänge und Speicherbereiche auf Initialwerte, aktiviert timer
init:
MOV COLS, 000h
MOV ROWS, 000h
mov IE, #10010010b
mov tmod, #00000010b
mov r6, #00h
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

JMP loop

; timer wird vom Timer-Interrupt gemerufen. Es inkrementiert den Counter in R7. Nach einer gewissen Zahl von Takten wird das Display angezeigt. Wird das Display angezeigt, wird in R6 inkrementiert, um bei jedem x-ten Aufruf Spieler 2 zu toggeln
timer:
INC R6
MOV a, R6
clr c
subb a, #02h
jnc timer_show
ret
timer_show:
INC R7
MOV A, R7
SUBB A, #01h ; Wenn bei der Subtraktion das Carry-Bit gesetzt wird, ist 1 größer als A
JNC timer_spieler2
timer_display:
mov r6, #00h
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
SHOW_ROW 0
SETB ROWS.0
CLR ROWS.0
SHOW_ROW 1
SETB ROWS.1
CLR ROWS.1
SHOW_ROW 2
SETB ROWS.2
CLR ROWS.2
SHOW_ROW 3
SETB ROWS.3
CLR ROWS.3
SHOW_ROW 4
SETB ROWS.4
CLR ROWS.4
SHOW_ROW 5
SETB ROWS.5
CLR ROWS.5
SHOW_ROW 6
SETB ROWS.6
CLR ROWS.6
SHOW_ROW 7
SETB ROWS.7
CLR ROWS.7
RET

eingabe_abfragen:
; Lesen, welcher Button auf dem Keypad gedrückt wurde
; R3 = Eingabe
mov a, p2
cpl a
mov r3, a
jz eingabe_null
; TODO: Gegebenenfalls überprüfen, ob mehrere Buttons gedrückt wurden

; Wenn wir nicht eingabebereit sind, dann gehen wir wieder zurück
jnb eingabebereit, eingabe_fertig

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

; R2 => eingefügte Reihe
call spielstand

clr EINGABEBEREIT
call spieler_wechseln
ret

eingabe_null:
setb EINGABEBEREIT
eingabe_fertig:
ret

spieler_wechseln:
mov a, #SPIELER1
cjne a, AKTIVERSPIELER, spieler_zwei
mov AKTIVERSPIELER, #SPIELER2
ret
spieler_zwei:
mov AKTIVERSPIELER, #SPIELER1
ret

; R2 => eingefügte Reihe
spielstand:
call spielstand_horiz
call spielstand_vert
ret

; R2 => eingefügte Reihe
spielstand_horiz:
; Wenn aktueller Spieler 4 horizontal nebeneinander hat
; Für jede Zeile >= 127 auf = 127 testen und dann bis 4 mal nach rechts shiften
; Ist die Zeile 127, dann sind 4 Steine nebeneinander => Win

mov a, aktiverspieler
add a, R2
mov R0, a
mov a, @R0
mov R1, a

CMP_HORIZ #15d
CMP_HORIZ #30d
CMP_HORIZ #60d
CMP_HORIZ #120d
CMP_HORIZ #240d

spielstand_horiz_exit:
ret

; R2 => eingefügte Reihe
spielstand_vert:
; Wenn aktueller Spieler 4 vertikal übereinander hat
; Wenn eingefügte Reihe < 4 dann eingefügte Reihe bis +3 verunden
; Ergebnis > 0 => 4 Steine übereinander

mov a, R2
clr c
subb a, #5d
jnc spielstand_vert_exit

mov a, aktiverspieler
add a, R2
mov R0, a
mov a, @R0

inc R0
anl a, @R0

inc R0
anl a, @R0

inc R0
anl a, @R0

jz spielstand_vert_exit

jmp win

spielstand_vert_exit:
ret

win:
; Spieler1 = Leer
; Spieler2 = Darstellen einer '1' oder '2'
jmp leerlauf

leerlauf:
jmp leerlauf

end