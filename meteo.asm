.include "m8def.inc"
.include "LCD4_macro.inc"  
.include "my_macro.inc"

.DSEG

firb:	.byte		1
secb:	.byte		1
RH_RAM: .byte       1
P_RAM:  .byte       1

.def temp0      = R16
.def OSRG 		= R17
.def temp 		= R18
.def temp1 		= R19
.def temp2 		= R20
.def Flag 		= R21
.def con 		= R22
.def ADC_cycles = R23
.def w_per 		= R24
.def ZLmax 		= R25

.CSEG 

; Interrupts ==============================================
			.ORG 	0x0000
				 rjmp RESET

			.ORG	INT0addr		; External Interrupt Request 0
				rjmp INT0_OK
			.ORG	INT1addr		; External Interrupt Request 1
				rjmp INT1_OK
			.ORG	OC2addr			; Timer/Counter2 Compare Match
			RETI
			.ORG	OVF2addr		; Timer/Counter2 Overflow

			.ORG	ICP1addr		; Timer/Counter1 Capture Event
			RETI
			.ORG	OC1Aaddr		; Timer/Counter1 Compare Match A
			RETI
			.ORG	OC1Baddr		; Timer/Counter1 Compare Match B
			RETI
			.ORG	OVF1addr		; Timer/Counter1 Overflow
				rjmp TIM1_Overflow

			.ORG	OVF0addr		; Timer/Counter0 Overflow
			RETI
			.ORG	SPIaddr			; Serial Transfer Complete
			RETI

			.ORG	URXCaddr		; USART, Rx Complete
			RETI

			.ORG	UDREaddr		; USART Data Register Empty
			RETI
			.ORG	UTXCaddr		; USART, Tx Complete
			RETI
			.ORG	ADCCaddr		; ADC Conversion Complete
			RETI 
			
			.ORG	ERDYaddr		; EEPROM Ready
			RETI
			.ORG	ACIaddr			; Analog Comparator
			RETI
			.ORG	TWIaddr			; 2-wire Serial Interface
			RETI
			.ORG	SPMRaddr		; Store Program Memory Ready
			RETI
; End Interrupts ==========================================

.org INT_VECTORS_SIZE
;=============================================================================
INT0_OK:
push ZH
push ZL
push temp0
push temp
push temp1
push temp2
push ZLmax

sbrc Flag, 5
rjmp ex_int0

clr w_per

LCDCLR
		ldi temp, $41
		WR_DATA temp
		ldi temp, $BD
		WR_DATA temp
		ldi temp, $61
		WR_DATA temp
		ldi temp, $BB
		WR_DATA temp
		ldi temp, $B8
		WR_DATA temp
		ldi temp, $B7
		WR_DATA temp

		ldi temp, $20
		WR_DATA temp

		ldi temp, $E3
		WR_DATA temp
		ldi temp, $61
		WR_DATA temp
		ldi temp, $BD
		WR_DATA temp
		ldi temp, $BD
		WR_DATA temp
		ldi temp, $C3
		WR_DATA temp
		ldi temp, $78
		WR_DATA temp

		LCD_COORD 0,1

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		wdr

		clr ZH
		ldi ZL, 255
		ldi ZLmax, 255

		rcall ReadEEP
		cpi temp, $FF
		breq no_more_13
		rjmp more_13

no_more_13:

		clr ZH
		clr ZL

		rcall ReadEEP
		mov ZLmax, temp

		cpi temp, 13
		brlo less_13
		rjmp more_13

less_13:
		LCDCLR

		ldi temp, $48
		WR_DATA temp
		ldi temp, $65
		WR_DATA temp
		ldi temp, $E3
		WR_DATA temp
		ldi temp, $6F
		WR_DATA temp
		ldi temp, $63
		WR_DATA temp
		ldi temp, $BF
		WR_DATA temp
		ldi temp, $61
		WR_DATA temp
		ldi temp, $BF
		WR_DATA temp
		ldi temp, $6F
		WR_DATA temp
		ldi temp, $C0
		WR_DATA temp
		ldi temp, $BD
		WR_DATA temp
		ldi temp, $6F
		WR_DATA temp

		LCD_COORD 0,1

		ldi temp, $E3
		WR_DATA temp
		ldi temp, $61
		WR_DATA temp
		ldi temp, $BD
		WR_DATA temp
		ldi temp, $BD
		WR_DATA temp
		ldi temp, $C3
		WR_DATA temp
		ldi temp, $78
		WR_DATA temp

		rjmp ex_int0

more_13:

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		wdr

		clr temp1
		ldi temp2, 3
		clr ZH
		ldi ZL, 2

RH_more_65:
		rcall ReadEEP
		add ZL, temp2
		cp ZL, ZLmax
		brge RH_more_ex
		cpi temp, 146
		brlo RH_more_65
		inc temp1
		rjmp RH_more_65

RH_more_ex:
		cpi temp1, 3
		brlo RH_ex
		ldi temp1, 20
		add w_per, temp1

RH_ex:	

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		wdr

		cpi ZLmax, 255
		brlo diff_T_ex
		
		ldi temp2, 3

		ldi ZL, 1
		rcall ReadEEP
		mov temp0, temp
		mov temp1, temp

diff_maxmin_T:
		rcall ReadEEP
		add ZL, temp2
		cp ZL, ZLmax
		brge diff_maxmin_ex
		cp temp, temp0
		brlo diff_min_T
		cp temp, temp1
		brge diff_max_T
		
diff_min_T:
		mov temp0, temp
		rjmp diff_maxmin_T

diff_max_T:
		mov temp1, temp
		rjmp diff_maxmin_T
		
diff_maxmin_ex:
		sbc temp1, temp0
		cpi temp1, 10
		brge diff_T_ex
		cpi temp1, 4
		brlo diff_T_ex
		ldi temp1, 25
		add w_per, temp1
diff_T_ex:		

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		wdr

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		clr temp1
		ldi temp2, 3
		clr ZH
		ldi ZL, 3
		ldi temp0, 200
P_730:
		rcall ReadEEP
		add ZL, temp2
		cp ZL, ZLmax
		brge P_730_ex
		cp temp, temp0
		brge P_730
		inc temp1
		rjmp P_730
P_730_ex:
		cpi temp1, 6
		brlo P_730_ex_2
		ldi temp1, 15
		add w_per, temp1
P_730_ex_2:

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		wdr
		

		clr temp1
		ldi temp2, 3

		ldi ZL, 3
		rcall ReadEEP
		mov temp0, temp
P_down_4:
		rcall ReadEEP
		add ZL, temp2
		cp ZL, ZLmax
		brge P_down_4_ex
		cp temp, temp0
		brlo P_down_4_2
		rjmp P_down_4 
P_down_4_2:
		mov temp0, temp
		inc temp1
		rjmp P_down_4

P_down_4_ex:
		cpi temp1, 4
		brlo P_down_ex
		ldi temp1, 35
		add w_per, temp1

P_down_ex:

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		rcall delay_big
		ldi temp, $FF
		WR_DATA temp

		wdr

		
		LCDCLR

		ldi temp, $48
		WR_DATA temp
		ldi temp, $65
		WR_DATA temp
		ldi temp, $BD
		WR_DATA temp
		ldi temp, $61
		WR_DATA temp
		ldi temp, $63
		WR_DATA temp
		ldi temp, $BF
		WR_DATA temp
		ldi temp, $C4
		WR_DATA temp
		ldi temp, $65
		WR_DATA temp
		ldi temp, $3A
		WR_DATA temp
		ldi temp, $20
		WR_DATA temp

		mov temp, w_per
		rcall bin2ASCII

		ldi temp, $25
		WR_DATA temp

		rcall delay_big
		rcall delay_big
		rcall delay_big
		rcall delay_big
		rcall delay_big
		rcall delay_big
		rcall delay_big
		rcall delay_big

		wdr

ex_int0:
	ldi temp, high(125000)
	out TCNT1H,temp
	ldi temp, low(125000)
	out TCNT1L,temp

pop ZLmax
pop temp2
pop temp1
pop temp
pop temp0
pop ZL
pop ZH

reti

INT1_OK:
push temp

	sbrc Flag, 5
	rjmp flag5to0
	sbr Flag, (1<<5)
	ldi temp, (0<<INT0)|(1<<INT1)
	out GIMSK, temp
	sbi PORTD, 6
	rjmp ex_int1

flag5to0:
	cbr Flag, 32
	ldi temp, (1<<INT0)|(1<<INT1)
	out GIMSK, temp
	cbi PORTD, 6
	wdr
	INIT_LCD
	LCDCLR

ex_int1:
pop temp
reti


TIM1_Overflow:
	set

	inc con
	cpi con, 190
	brne int_ex
	sbr Flag, (1<<7)
	clr con
	 	 	
int_ex:
reti

;=============================================================================

RESET:
		LDI R16,Low(RAMEND)		; Инициализация стека
	  	OUT SPL,R16			; Обязательно!!!
 
	  	LDI R16,High(RAMEND)
	  	OUT SPH,R16
RAM_Flush:	
		LDI	ZL,Low(SRAM_START)	
		LDI	ZH,High(SRAM_START)
		CLR	R16			
Flush:		
		ST 	Z+,R16			
		CPI	ZH,High(RAMEND+1)	
		BRNE	Flush			
 
		CPI	ZL,Low(RAMEND+1)	
		BRNE	Flush
 
		CLR	ZL			
		CLR	ZH

		LDI	ZL, 30		
		CLR	ZH		
		DEC	ZL		
		ST	Z, ZH		
		BRNE	PC-2
;------------------------------------------------------
		OUTI	DDRB, 0b00000000
		OUTI	PORTB,0b00000000 

		OUTI	DDRC, 0b00000000
		OUTI	PORTC,0b00000000

		OUTI	DDRD, 0b01000000
		OUTI	PORTD,0b00000110

		RCALL IIC_INIT

		RCALL ADC_INIT

		INIT_LCD
		LCDCLR

		ldi temp, $43
		WR_DATA temp
		ldi temp, $BF
		WR_DATA temp
		ldi temp, $61
		WR_DATA temp
		ldi temp, $70
		WR_DATA temp
		ldi temp, $BF
		WR_DATA temp
		ldi temp, $2E
		WR_DATA temp
		WR_DATA temp
		WR_DATA temp

		rcall temp_ready_to_read

		ldi temp, high(125000)
		out TCNT1H,temp
		ldi temp, low(125000)
		out TCNT1L,temp
		ldi temp, 0b00000101
		out TCCR1B, temp
		ldi temp, (1<<TOIE1)
		out TIMSK, temp

		ldi temp, (1<<ISC01)|(1<<ISC11)
		out MCUCR, temp
		ldi temp, (1<<INT0)|(1<<INT1)
		out GIMSK, temp

		rcall IniWDT

		ldi con, 185

		rcall ReadEEP
		mov ZL, temp

		cpi ZL, $FF
		brne ZL_start
		clr ZL
		inc ZL

ZL_start:
				
		SEI;РАЗРЕШАЕМ ПРЕРЫВАНЯ!

Loop:
wdr
brtc loop
	;CLI
	clt

sbrc Flag, 5
rjmp no_display_1 

	LCDCLR

	LDI temp, $54
	WR_DATA temp
	LDI temp, $65
	WR_DATA temp
	LDI temp, $BC
	WR_DATA temp
	LDI temp, $BE
	WR_DATA temp
	LDI temp, $3A
	WR_DATA temp
	LDI temp, $20
	WR_DATA temp

no_display_1: 

	rcall read_temp

	wdr

	LDS		R16,firb
	MOV     temp, R16
;---------------------------------	
rcall to_EEPROM
;---------------------------------
sbrc Flag, 5
rjmp no_display_2
		
	RCALL	firb_to_ASCII			

	LDI temp, $2C
	WR_DATA temp

	LDS		R16,secb			
	RCALL	secb_to_ASCII				

	LDI temp, $27
	WR_DATA temp
	LDI temp, $43
	WR_DATA temp
	LCD_COORD 0,1
	LDI temp, $42
	WR_DATA temp
	LDI temp, $BB
	WR_DATA temp
	LDI temp, $3A
	WR_DATA temp

no_display_2:

	cbi ADMUX, MUX0
	sbi ADCSRA, ADSC

ADC0_COM:		
		IN	OSRG, ADCSRA
		ANDI	OSRG,1<<ADIF
		BREQ	ADC0_COM		; Ждем пока не будет готово преобразование
		
		IN	temp,ADCH
;---------------------------------	
rcall to_EEPROM
;---------------------------------
sbrc Flag, 5
rjmp no_display_4

	CPI temp, 45
	BRLO RH_0

	CPI temp, 203
	BRLO calc_RH
	ldi temp, 100
	rjmp view_RH


calc_RH:
		subi temp, 45
		clr temp1
		
		push ZH
		push ZL
		LDPA RH_table
		ADD ZL, temp
		ADC ZH, temp1
		LPM temp, Z
		pop ZL
		pop ZH
				
		rjmp view_RH 
RH_0:
		clr temp

view_RH:
	rcall bin2ASCII


	LDI temp, $25
	WR_DATA temp
	LDI temp, $20
	WR_DATA temp
	LDI temp, $20
	WR_DATA temp
	LDI temp, $E0
	WR_DATA temp
	LDI temp, $B3
	WR_DATA temp
	LDI temp, $3A
	WR_DATA temp

no_display_4:

	sbi ADMUX, MUX0
	sbi ADCSRA, ADSC


	ADC1_COM:		
		IN	OSRG, ADCSRA
		ANDI	OSRG,1<<ADIF
		BREQ	ADC1_COM		; Ждем пока не будет готово преобразование

		IN	temp,ADCH
;---------------------------------	
rcall to_EEPROM
;---------------------------------
sbrc Flag, 5
rjmp no_display_5

	subi temp, 170                                       
	cpi temp, 20
	brge sev_xx

	LDI temp2, $36
	WR_DATA temp2
	rjmp calc_P

sev_xx:

	LDI temp2, $37
	WR_DATA temp2

calc_P:
		ldi temp1, 0

		push ZH
		push ZL
		LDPA P_table
		ADD ZL, temp
		ADC ZH, temp1
		LPM temp, Z
		pop ZL
		pop ZH
		
P_view:
	rcall bin2ASCII

	LDI temp, $BC
	WR_DATA temp

	LDI temp, $BC
	WR_DATA temp

no_display_5:

	ldi temp, high(125000)
	out TCNT1H,temp
	ldi temp, low(125000)
	out TCNT1L,temp

	;SEI

	CBR Flag, 128

RJMP Loop
;=============================================================================

reg_conf:
	RCALL	IIC_START

	LDI	OSRG,0b10010000
	RCALL	IIC_BYTE

	LDI	OSRG, $AC
	RCALL	IIC_BYTE

	LDI	OSRG, $00
	RCALL	IIC_BYTE

	RCALL	IIC_STOP
ret

;=============================================================================

start_convert:
	RCALL	IIC_START

	LDI	OSRG, 0b10010000
	RCALL	IIC_BYTE

	LDI	OSRG, $EE
	RCALL	IIC_BYTE

	RCALL	IIC_STOP
ret

temp_ready_to_read:
 	rcall reg_conf
 	rcall delay_big
 	rcall start_convert
 	rcall delay_very_big
ret

;=============================================================================

read_temp:
	RCALL	IIC_START

	LDI	OSRG,0b10010000
	RCALL	IIC_BYTE

	LDI	OSRG,$AA
	RCALL	IIC_BYTE

	RCALL	IIC_START

	LDI	OSRG,0b10010001
	RCALL	IIC_BYTE
	
	RCALL	IIC_RCV
	IN	OSRG,TWDR
	STS	firb,OSRG

	RCALL	IIC_RCV2
	IN	OSRG,TWDR
	STS	secb,OSRG
	
	RCALL	IIC_STOP
ret

;=============================================================================

firb_to_ASCII:; Преобразование из BCD в симовол  ASCII		
			push temp
			push temp1
			clr temp
			clr temp1
			
			SBRS r16, 7
			rjmp l0
			COM r16
			push r16
				LDI temp, $2D
				WR_DATA temp
			pop r16

	l0:

			CPI R16, 100
			BRGE minus1
			rjmp l1
			minus1:
				SUBI R16,100
				inc temp1
				rjmp l0
	l1:

			cpi temp1,0
			breq l11
			push r16
				mov temp, temp1
				WR_DATA temp
			pop r16
			
	l11:								
			CPI R16, 10
			BRGE minus2
			rjmp l2
			minus2:
				SUBI R16,10
				inc temp
				rjmp l11
	l2:
				push r16
				SUBI temp, -48
				WR_DATA temp
				
				pop r16


				SUBI r16, -48
				mov temp, r16
				WR_DATA temp
				pop temp1
				pop temp	
			RET

;=============================================================================

secb_to_ASCII:; Преобразование из BCD в симовол  ASCII		
			push temp
			ldi temp, 0
			
			SBRC r16, 4
			SUBI temp, -6
			
			SBRC r16, 5
			SUBI temp, -13

			SBRC r16, 6
			SUBI temp, -25

			SBRC r16, 7
			SUBI temp, -50

			MOV r16, temp
			ldi temp, 0

	s_l1:
			CPI R16, 10
			BRGE s_minus
			rjmp s_l2
	s_minus:
				SUBI R16,10
				inc temp
				rjmp s_l1
	s_l2:
				push r16
				SUBI temp, -48

				WR_DATA temp
				
				pop r16
				SUBI r16, -48
				mov temp, r16
				WR_DATA temp

				pop temp	
			RET

;=============================================================================

bin2ASCII:

push temp
push temp1
push temp2
PUSHF

	clr temp1
	clr temp2

bBCD8_1: 
	subi temp, 100
	brcs bBCD8_2_1
	inc temp2
	rjmp bBCD8_1

bBCD8_2_1:
	subi temp, -100

	cpi temp2, 0
	BREQ bBCD8_2 
	SUBI temp2, -48
	WR_DATA temp2

bBCD8_2:
	subi temp, 10
	brcs bBCD8_3
	inc temp1
	rjmp bBCD8_2

bBCD8_3:
	SUBI temp1, -48
	WR_DATA temp1

	subi temp, -10

	SUBI temp, -48
	WR_DATA temp

POPF
pop temp2
pop temp1
pop temp

ret

;=============================================================================
to_EEPROM:
	SBRS Flag, 7
	rjmp no_EEPROM
	
	cpi ZL, 0
	brne ZL_no_0
	inc ZL

ZL_no_0:

	CLR	ZH
	rcall WriteEEP
	inc ZL

	push temp
	mov temp, ZL
	push ZL
	clr ZL
	wdr
	rcall WriteEEP
	pop ZL
	pop temp
			
	no_EEPROM:
ret
;=============================================================================
.include "LCD4.asm"
.include "delays.asm"
.include "i2c.asm"
.include "ADC.asm"
.include "WDT.asm"
.include "EEPROM.asm"
;.include "sleep_mode.asm"

RH_table: .db 0, 1, 1, 2, 3, 3, 4, 4;
		  .db 5, 6, 6, 7, 8, 8, 9, 9 
		  .db 10, 11, 11, 12, 13, 13, 14, 15 
		  .db 15, 16, 16, 17, 18, 18, 19, 20 
		  .db 20, 21, 22, 22, 23, 23, 24, 25 
		  .db 25, 26, 27, 27, 28, 28, 29, 30 
		  .db 30, 31, 32, 32, 33, 34, 34, 35
		  .db 35, 36, 37, 37, 38, 39, 39, 40;
		  .db 41, 41, 42, 42, 43, 44, 44, 45 
		  .db 46, 46, 47, 47, 48, 49, 49, 50 
		  .db 51, 51, 52, 53, 53, 54, 54, 55 
		  .db 56, 56, 57, 58, 58, 59, 59, 60 
		  .db 61, 61, 62, 63, 63, 64, 65, 65 
		  .db 66, 66, 67, 68, 68, 69, 70, 70
		  .db 71, 72, 72, 73, 73, 74, 75, 75;
		  .db 76, 77, 77, 78, 78, 79, 80, 80 
		  .db 81, 82, 82, 83, 84, 84, 85, 85 
		  .db 86, 87, 87, 88, 89, 89, 90, 91 
		  .db 91, 92, 92, 93, 94, 94, 95, 96 
		  .db 96, 97, 97, 98, 99, 99, 100, 100

P_table:	.db	35, 38, 41, 44, 48, 51, 54, 57
			.db	61, 64, 67, 71, 74, 77, 80, 84 
			.db	87, 90, 93, 97,  0,  3,  6, 10 
			.db	13, 16, 20, 23, 26, 29, 33, 36 
			.db	39, 42, 46, 49, 52, 55, 59, 62 
			.db	65, 69, 72, 75, 78, 82, 85, 88 
			.db	91, 95, 98,  1,  4,  8, 11, 14 


