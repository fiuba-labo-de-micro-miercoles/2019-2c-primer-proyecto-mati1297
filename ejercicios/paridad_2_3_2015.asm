.include "m328pdef.inc"

.MACRO PARIDAD ;macro para obtener paridad de unos
	LDI @1, 0 ;cargo en el bit de paridad pasado -> 0
	CLR R0 ; limpio R0
	MOV R16, @0, muevo el byte pasado a r16 para no modificarlo
FOR_MACRO_PARIDAD:
	LSL R16 ;shifteo con un logical shift (se llena con ceros)
	ADC @1, R0 ; sumo el carry al registro
	CPI R16, 0 ; si el R16 ya es 0, no quedan mas unos por contar
	BRNE FOR_MACRO_PARIDAD ; si no es igual vuelvo a hacer el proceso
	ANDI @1, MASCARA_PARIDAD ;dejo solo el primer bit, si es 1 la cantidad de unos era impar
.ENDM

;Definiciones
.EQU TAMANO_TABLA = 7
.EQU MASCARA_PARIDAD = 0x01
.EQU CLK = 2
.EQU TRANSMISION = 1

.DSEG
TABLA_RAM: .BYTE TAMANO_TABLA ;cargo la tabla en RAM

.CSEG
	;inicializo el stack
	LDI R16, LOW(RAMEND)
	STS SPL, R16
	LDI R16, HIGH(RAMEND)
	STS SPH, R16
	CALL LEER_TABLA ; llamo a leer la tabla
HERE:
	RJMP HERE

LEER_TABLA:
	LDI XL, LOW(TABLA_RAM) ;guardo punteros
	LDI XH, HIGH(TABLA_RAM)
	LD R20, X+ ;cargo el primer valor de la tabla
	CPI R20, 0xFF ;veo si es 0xFF
	BREQ TERMINAR ;si es asi, la tabla esta vacia y termino
FOR:
	CALL CALCULAR_PARIDAD ;si no era asi, llamo a calcular paridad
	LD R20, X+ ;cargo el siguiente valor
	CPI R20, 0xFF ;veo si es 0xFF
	BRNE FOR ;si no es, sigo con el ciclo
TERMINAR:
	RET ;si es 0xFF termino la rutina

CALCULAR_PARIDAD:
	PARIDAD R20, R21; en R21 obtengo el bit de paridad
	IN R16, DDRB ;cargo DDRB
	ORI R16, ((1 << TRANSMISION)|(1<<CLK)) ;seteo en  1 (salida) los bitts CLK y TRANSMISION
 	OUT DDRB, R16 ;saco R16 a DDRB
 	LDI R23, 7 ;inicializo el contador
FOR_2:
	IN R17, PORTB ;me guardo PORTB para modificarlo
	ANDI R17, ~(1<<CLK); limpio en PORTB el bit CLK para setearlo como bajo
	OUT PORTB, R17 ;lo saco a PORTB
	IN R17, PORTB ;vuelvo a leer PORTB
	LSL R20 ;shifteo el bit que recibo 
	CLR R0 ;limpio el bit R0 
	ADC R18, R0 ; sumo al carry a R18 
	ANDI R17, ~(1<<TRANSMISION) ;limpio el bit de TRANSMISION
	SBRC R18, 0 ;si el bit 0 de R18 esta limpio (el bit correspondiente de R20 era 0) no hago nada
	ORI R17, (1<<TRANSMISION) ; caso contrario transmito el 1
	CLR R18 ;limpio r18
	ORI R17, (1<<CLK) ;subo el clock
	OUT PORTB, R17; saco PORTB con la transmision y el clock
	DEC R23 ; si el contador llego a 0 termino el ciclo
	BRNE FOR_2
	
	IN R17, PORTB ;vuelvo a cargar el PORTB
	ANDI R17, (1<<CLK); bajo el clock
	OUT PORTB, R17 ;saco el clock bajo por PORTB
	IN R17, PORTB ;vuelvo a leer PORTB
	ANDI R17, ~(1<<TRANSMISION); limpio el bit de transmision
	SBRC R21, 0 ;si el bit 0 de R21 (paridad es 0) no hago nada
	ORI R17, (1<<TRANSMISION); si era 1 lo saco por transmision 
	ORI R17, (1<<CLK); subo el clock
	OUT PORTB, R17 ; saco el clock y la transmision
	RET ; vuelvo de la rutina

	

	




