.include "m328def.inc"



.CSEG
	RJMP MAIN

.ORG INT_VECTORS_SIZE
MAIN:
	LDI ZH, HIGH(DATA<<1) //cargo la parte alta de la tabla
	LDI ZL, LOW(DATA<<1) //cargo la parte baja de la tabla
	CALL PROMEDIO //llamo la funcion promedio

HERE: RJMP HERE

PROMEDIO:
	LDI R16, 8 //cargo el contador en 8
	LDI R17, 0 //inicializo en 0 el registro de la suma
	LDI R18, 0 //inicializo en 0 el registro alto de la suma
FOR:
	LPM R19, Z+ //cargo de la memoria flash la primera direccion de la tabla
	CPI R19, 0 //comparo con 0 ya que LPM (o LD) no prende le flag N
	BRMI SNEG //si es negativo hago branch
	ADD R17, R19 //sumo el registro que entra a la suma
	CLR R0 //limpio R0
SEGUIR:
	ADC R18, R0 //sumo R0 a R18 (registro alto) con el carry (R0 = 0 o R0 = FF)
	DEC R16 //decremento R16
	BRNE FOR //si R16 != 0 sigue el ciclo
	
	LDI R16, 3 //cargo el contador en 3 para la division
DIVISION:
	ASR R18 //hago un shift aritmetico en el byte alto
	ROR R17 //roto a la derecha con el carry 
	DEC R16 //decremento el contador
	BRNE DIVISION //si R16 != 0 sigue el ciclo
	RET //salgo de la funcion

SNEG:	
	CLR R0 //limpio R0
	COM R0 //lo complemento para R0 = FF ya que es negativo el numero
	ADD R17, R19 //sumo el numero que ingresa
	RJMP SEGUIR //vuelvo a la branch principal


.ORG 0x760
	DATA: .DB "Hola mundo", '\0'
