;ZH:ZL - �����, temp - ������������ ����

WriteEEP:
   sbic EECR, EEWE
   rjmp WriteEEP
   out EEARH, ZH
   out EEARL, ZL
  out EEDR, temp
   sbi EECR, EEMWE
   sbi EECR, EEWE
ret

;------------------------------------------------------
;ZH:ZL - �����, temp - ��������� ����

ReadEEP:
   sbic EECR, EEWE
   rjmp ReadEEP
   out EEARH, ZH
   out EEARL, ZL
   sbi EECR, EERE
   in temp, EEDR
ret

;------------------------------------------------------

	