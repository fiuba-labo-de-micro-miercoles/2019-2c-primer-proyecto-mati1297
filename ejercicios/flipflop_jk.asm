.include "m328def.inc"

.MACRO SHIFTR //macro para hacer shift la cantidad de posiciones que se necesite
	LDI @2, @0 //cargo en el registro que se pasa el numero de iteraciones
	CPI @2, 0 //si es cero, directamente  sale y no hace ningun shift
	BREQ EXIT
FOR:
	LSR @1 //logical shift a la derecha en el registro que se pasa
	DEC @2 //decremento el contador
	BRNE FOR //si no es cero sigue el ciclo
EXIT:
.ENDM

.MACRO SHIFTL //lo mismo pero hacia la izquierda
	LDI @2, @0 //cargo en el registro que se pasa el numero de iteraciones
	CPI @2, 0 //si es cero, directamente  sale y no hace ningun shift
	BREQ EXIT
FOR:
	LSL @1 //logical shift a la derecha en el registro que se pasa
	DEC @2 //decremento el contador
	BRNE FOR //si no es cero sigue el ciclo
EXIT:
.ENDM


//definiciones (de los bits del puerto B) para los shifts
.EQU K = 3
.EQU J = 2
.EQU CLK = 1
.EQU Q = 0


.CSEG
	RJMP MAIN

.org	INT_VECTORS_SIZE	; Saltea los vectores de interrupción
MAIN:	
	IN R16, DDRB 	//traigo (leo) DDRB
	ORI R16, (1<<Q) //inicializo como out Q
	ANDI R16, ~((1<<K)|(1<<J)|(1<<CLK)) //inicializo como in K J y CLK
	OUT DDRB, R16 	//saco (escribo) DDRB

; La detección del flanco de subida se puede hacer con sólo 4 instrucciones:
EN_ALTO:
	sbic	PINB, CLK
	rjmp	EN_ALTO
	
DETECTAR_BAJO:
	SBIS PINB, CLK //si el bit CLK del pin B esta en 1 saltea a la siguiente
;//	RJMP DETECTAR_ALTO //si el bit esta bajo paso a detectar el alto
	RJMP DETECTAR_BAJO //si el bit esta alto todavia vuelvo a esperar el bajo
;DETECTAR_ALTO:
;	SBIC PINB, CLK //leo el bit CLK del PINB, salteo la siguiente si esta en 0
;	RJMP JK //si el bit CLK esta alto paso al algoritmo del JK
;	RJMP DETECTAR_ALTO //si todavia esta bajo vuelvo a esperar el alto

JK:	; si J=K=1 conmuta, si J=1 y K=0 setea, si J=0 y K=1 clear y si J=K=0 no hace nada
	IN R20, PORTB //cargo el PORTB (salida) en el R20 para usarlo despues
	IN R16, PINB //leo K
	SHIFTR K, R16, R21 //shiteo 3 veces K
	ANDI R16, 1 //limpio K
	IN R17, PINB //leo J
	SHIFTR J, R17, R21 //shifteo 2 veces J
	ANDI R17, 1 //limpio J
	IN R18, PORTB //leo Q
	SHIFTR Q, R18, R21 //shifteo 0 veces Q
	ANDI R18, 1 // limpio Q
	COM R16 //niego K
	AND R16, R18 //Q*~K
	COM R18 //~Q
	AND R17, R18 //~Q*J
	OR R16, R17 //~Q*J + Q*~K
	ANDI R20, ~(1<<Q) //limpio el bit Q de PORTB
	SHIFTL Q, R16, R21 //sifteo Q veces R16
	ANDI R16, (1<<Q) //limpio R16 despues del shifteo (no se si hace falta)
	OR R20, R16 //agrego el valor de R16 a R20
	OUT PORTB, R20 //saco R20 al PROTB
	
	; RJMP DETECTAR_BAJO //vuelvo a esperar el flanco bajo
	rjmp	EN_ALTO
	
	
	//branch if zero is cleared
	//branch if carry is set
	
	




