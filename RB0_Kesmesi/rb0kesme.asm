	list p='16f877a'
	#include<P16F877A.INC>
	
	durum EQU 0x20
	w_temp EQU 0x7d
	status_temp EQU 0x7e
	pclath_temp EQU 0x7f
	
	org 0x00
	goto BASLA
	
	org 0x04
KESME
	movwf w_temp
	movf STATUS,w
	movwf status_temp
	movf PCLATH,w
	movwf pclath_temp
	
	bcf INTCON,GIE
	bcf INTCON,INTF
	
	movlw b'00000010'
	xorwf durum,f
	
	bsf INTCON,GIE
	
	movf pclath_temp,w
	movwf PCLATH
	movf status_temp,w
	movwf STATUS
	swapf w_temp,f
	swapf w_temp,w
	retfie
	
BASLA
	movlw 0x02
	movwf durum
	banksel TRISB
	movlw b'00000001'
	movwf TRISB
	bsf INTCON,INTE
	bsf INTCON,GIE
	banksel OPTION_REG
	bsf OPTION_REG,INTEDG
	banksel PORTB
	clrf PORTB
	
DONGU
	movf durum,w
	movwf PORTB
	GOTO DONGU
	
END
