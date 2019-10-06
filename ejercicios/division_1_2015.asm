.include "m328def.inc"

.DSEG
	NUMEROS: .BYTE 2 ;poisiciones en RAM para ingresar numeros(prueba)

.CSEG
	RJMP MAIN

.ORG INT_VECTORS_SIZE
MAIN:
	LDI XL, LOW(NUMEROS) ;cargo punteros a ram
	LDI XH, HIGH(NUMEROS)
	LD R16, X+ ;leo el dividendo
	LD R17, X ;leo el divisor
	CALL DIVISION ;llamo a la rutina division
HERE:
	RJMP HERE ;ciclo infinito

DIVISION:
	CPI R17, 0 ;veo si el divisor es cero
	BRNE SEGUIR_NO_CERO ;si no es cero sigo con la rutina
	SET ;si es cero seteo el flag T
	RET ;salgo de la rutina
SEGUIR_NO_CERO:
	MOV R19, R16 ;copio R16 a R19 para no modificar (dividendo)
	MOV R20, R17 ;idem divisor
	SBRC R19, 7; veo si el dividendo es negativo
	NEG R19 ;si es negativo lo paso a positivo
	SBRC R20, 7 ; veo si el divisor es negativo
	NEG R20 ;si es negativo lo paso a positivo
	LDI R18, 0; cargo 0 en R18 (resultado de la division)
FOR:
	CP R19, R20 
	BRGE SEGUIR; veo si lo que queda en R19 es todavia mas grande que el divisor, si es asi sigo restando
	MOV R20, R17 ; muevo el divisor a R20
	EOR R20, R16 ;si divisor y dividendo eran negativos, el resultado es positivo
	SBRC R20, 7 ;si no lo eran ambos, la XOR quedó con bit 7 = 1 y el resultado y resto deben ser negativos
	NEG R18 ;paso a negativo el resultado
	SBRC R20, 7
	NEG R19 ;paso el resto a negativo
	RET ;vuelvo de la funcion

SEGUIR:
	SUB R19, R20 ;resto
	INC R18 ;incremento el resultado
	RJMP FOR ;vuelvo al ciclo
