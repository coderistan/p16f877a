	; 16 bitlik iki sayidan buyuk olani bulma
	; sonuc enb_h enb_l icerisine koyulur
	list p='16f877a'
	#include<P16F877A.INC>
	
	cblock 0x20
	SAYI1_L
	SAYI2_L
	SAYI1_H
	SAYI2_H
	enb_h
	enb_l
	endc
	
	org 0x00
	goto BASLA
	
	org 0x04
	retfie


KONTROL
	bsf STATUS,C
	MOVF SAYI1_H,W
	SUBWF SAYI2_H,W
	BTFSC STATUS,Z
	GOTO LOW_BAK
	btfss STATUS,C
	goto SAYI1_BUYUK
	goto SAYI2_BUYUK

LOW_BAK
	bsf STATUS,C
	movf SAYI2_L,w
	subwf SAYI1_L,w
	BTFSC STATUS,Z 
	GOTO ESIT	
	btfsc STATUS,C
	goto SAYI1_BUYUK
	goto SAYI2_BUYUK
	
SAYI1_BUYUK
	banksel PORTB
	bsf PORTB,0
	goto KONTROL_BITIR
SAYI2_BUYUK
	bsf PORTB,1
	goto KONTROL_BITIR
ESIT
	banksel PORTB
	clrf PORTB
KONTROL_BITIR
	return
	
	BASLA
	BANKSEL TRISB
	CLRF TRISB
	BANKSEL PORTB
	CLRF PORTB
	BSF STATUS,C
	; sayý1 = FF F0
	MOVLW 0x0f
	MOVWF SAYI1_L
	MOVLW 0xFF
	MOVWF SAYI1_H
	; sayý2 = FF 0F
	MOVLW 0xf0
	MOVWF SAYI2_L
	MOVLW 0xFF
	MOVWF SAYI2_H
	CLRW
	CALL KONTROL
	goto $
END