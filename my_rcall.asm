divY8L:
	push temp2
	clr temp2
  lsrror:
	lsr YH
	ror YL
	inc temp2
	cpi temp2, 1
	brne lsrror
	pop temp2
ret
;-----------------------------------------------------------------------------