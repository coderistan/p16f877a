   	; dot matrix uzerinde gulen surat cizimi
   	list p='16f877a'
	#include<P16F877A.INC>
	__CONFIG h'3F31'
	
	index EQU 0x20
	gecikme1 EQU 0x21
	gecikme2 EQU 0x22
	gecikme3 EQU 0x23

	ORG 0x00
	GOTO BASLA
	
	ORG 0x04
	retfie
	
GECIKME
	movlw d'20'
	movwf gecikme1
G1
	movlw d'20'
	movwf gecikme2
G2
	decfsz gecikme2
	goto G2
	decfsz gecikme1
	goto G1
	decfsz gecikme3
	goto GECIKME
	movlw d'3'
	movwf gecikme3
	return
	
BASLA
	banksel TRISB
	clrf TRISB
	clrf TRISC
	banksel PORTB
	clrf PORTB
	clrf PORTC
	movlw 0x00
	movwf index
	movlw d'10'
	movwf gecikme3
	
DONGU
	movf index,w
	call l_portb
	movwf PORTB
	movf index,w
	call l_portc
	movwf PORTC
	incf index,f
	movf index,w
	sublw d'5'
	btfsc STATUS,Z
	clrf index
	bcf STATUS,Z
	call GECIKME
	goto DONGU
	
l_portb
	addwf PCL,f
	retlw b'11110111'
	retlw b'11011011'
	retlw b'11111101'
	retlw b'11011011'
	retlw b'11110111'
l_portc
	addwf PCL,f
	retlw b'00000001'
	retlw b'00000010'
	retlw b'00000100'
	retlw b'00001000'
	retlw b'00010000'

END