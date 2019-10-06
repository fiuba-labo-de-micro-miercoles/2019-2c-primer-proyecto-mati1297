.include "m328def.inc"

.DSEG
	V: .BYTE 1 ;espacio para pasar el valor en Celsius

.CSEG
	RJMP MAIN

.ORG INT_VECTORS_SIZE
MAIN:
	LDI R16, LOW(RAMEND) ;inicializo el stack
	STS SPL, R16
	LDI R16, HIGH(RAMEND)
	STS SPH, R16
	LDI XL, LOW(V) ;cargo la variable V en puntero
	LDI XH, HIGH(V)
	LD R0, X ;cargo V a R0
	CALL C_TO_F ;llamo a la rutina
HERE: 
	RJMP HERE; ciclo infinito

C_TO_F: ;F = 9/5*C + 32
	;muevo R0 a otros registros para no pisarlo
	MOV R16, R0
	MOV R21, R0
	SBRC R21, 7; si el valor en celsius es negativo lo vuelvo positivo
	NEG R21
	;cargo la parte decimal de 9/5 EN R18
	LDI R18, 0xCD ;parte decimal 
	LDI R20, 32 ;cargooe el 32 en un registro
	MUL R21, R18 ;multiplico el valor en C por la parte decimal 9/5
	MOV R19, R1; paso R1 a R19
	SBRC R16, 7 ;si el valor original es negativo vuelvo negativo R19
	NEG R19
	ADD R19, R16 ; sumo C + C * 0,8 = C * 1,8
	ADD R19, R20; le sumo 32
	MOV R0, R16 ; muevo  el valor original a R0 nuevamente
	MOV R1, R19 ; muevo el valor resultado a R1
	RET ;vuelvo de la funcion
	

