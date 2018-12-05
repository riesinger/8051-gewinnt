# Vier Gewinnt

## Ports

P0 -> LED Matrix Spalten
P1 -> LED Matrix Zeilen
P2 -> Keypad

## Register

R7 + R6 -> Timer für das Display, **nicht** verwenden!
R5 - R0 -> Frei verwendbar, aber in Interrupts sichern!


## Dokumentation

LaTeX Dateien liegen im Ordner `/docs`. **Wichtig:** Kann nur aus dem `docs` Ordner gebaut werden, weil relative Importe benutzt werden.
