;===========~100��� 4���=========================
delay_mks:
	push r16
	ldi r16, 100
mks_delay_my:
	dec r16
	brne mks_delay_my
pop r16
ret
;======��������=4���:5 ������ ��� 50ms==========
delay_big:
	push r16
	push r17
	push r18
	
	LDI	R16,$40	; �������
	LDI	R17,$9C
	LDI	R18,$00
 
loop_delay_big:	
	SUBI	R16,1			
	SBCI	R17,0			
	SBCI	R18,0			
 
	BRCC	loop_delay_big			
	pop r18
	pop r17
	pop r16
ret
;======��������=4���:5 ������ ��� 1000ms==========
delay_very_big:
	push r16
	push r17
	push r18
	
	LDI	R16,$00	; �������
	LDI	R17,$35		
	LDI	R18,$0C
 
loop_delay_very_big:	
	SUBI	R16,1			
	SBCI	R17,0			
	SBCI	R18,0			
 
	BRCC	loop_delay_big			
	pop r18
	pop r17
	pop r16
ret
;=============================================================================
