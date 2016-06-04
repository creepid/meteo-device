ADC_INIT:
	;push OSRG
	;ldi OSRG, 0<<MUX0
	ori OSRG, (1<<ADLAR)|(1<<REFS0);|(0<<MUX0)
	out ADMUX, OSRG

	ldi OSRG,(1<<ADPS0)|(1<<ADPS2)|(1<<ADFR)|(1<<ADSC)|(1<<ADEN);|(1<<ADIE)
	out ADCSR, OSRG

	;pop OSRG
RET
