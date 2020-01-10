	; keypad uzerinde basilan tusu LCD ekranina yazan asm programi
	list p='16f877a'
	#include<P16F877A.INC>
	
	cblock 0x20
	yedek_4bit
	veri
	gecikme1
	gecikme2
	satir
	sutun
	endc
	
	org 0x00
	goto BASLA
	org 0x04
	retfie

GECIKME_200US
	movlw .66
	movwf gecikme1
d1
	decfsz gecikme1,f
	goto d1
	return
GECIKME_5MS
	movlw .100
	movwf gecikme1
d2
	movlw .20
	movwf gecikme2
d3
	decfsz gecikme2,f
	goto d3
	decfsz gecikme1,f
	goto d2
	return
GECIKME_50MS
	movlw .100
	movwf gecikme1
d4
	movlw .140
	movwf gecikme2
d5
	decfsz gecikme2,f
	goto d5
	decfsz gecikme1,f
	goto d4
	return
GECIKME_80MS
	movlw .250
	movwf gecikme1
d6
	movlw .250
	movwf gecikme2
d7
	decfsz gecikme2,f
	goto d7
	decfsz gecikme1,f
	goto d6
	return
GONDER_4BIT
	andlw 0x0F
	movwf yedek_4bit
	banksel PORTB
	movf PORTB,w
	andlw 0xF0
	iorwf yedek_4bit,w
	movwf PORTB
	call DUSEN_KENAR
	call GECIKME_200US
	return
KOMUT_GONDER
	movwf veri
	banksel PORTB
	bcf PORTB,4
	swapf veri,w
	call GONDER_4BIT
	bcf PORTB,4
	movf veri,w
	call GONDER_4BIT
	return
DUSEN_KENAR
	banksel PORTB
	bsf PORTB,5
	call GECIKME_200US
	bcf PORTB,5
	return
KARAKTER_GONDER
	movwf veri
	banksel PORTB
	bsf PORTB,4
	swapf veri,w
	call GONDER_4BIT
	bsf PORTB,4
	movf veri,w
	call GONDER_4BIT
	return
EKRANI_TEMIZLE
	movlw 0x01
	call KOMUT_GONDER
	call GECIKME_5MS
	return
LCD_AYARLA
	banksel TRISB
	clrf TRISB
	banksel PORTB
	call GECIKME_50MS
	bcf PORTB,4
	movlw 0x03
	call GONDER_4BIT
	call GECIKME_200US
	call DUSEN_KENAR
	call GECIKME_200US
	call DUSEN_KENAR
	call GECIKME_5MS
	
	bcf PORTB,4
	movlw 0x02
	call GONDER_4BIT
	call GECIKME_5MS
	
	movlw 0x28
	call KOMUT_GONDER
	movlw 0x0F
	call KOMUT_GONDER
	movlw 0x01
	call KOMUT_GONDER
	call GECIKME_5MS
	movlw 0x06
	call KOMUT_GONDER
	movlw 0x0D
	call KOMUT_GONDER
	
	return
KURSOR_KONUM
	movlw 0x80
	movf satir,f
	btfss STATUS,Z
	movlw 0xC0
	addwf sutun,w
	call KOMUT_GONDER
	call GECIKME_5MS
	return
YAZ_7
	movlw '7'
	call KARAKTER_GONDER
	return
YAZ_8
	movlw '8'
	call KARAKTER_GONDER
	return
YAZ_9
	movlw '9'
	call KARAKTER_GONDER
	return
YAZ_MUL
	movlw 'x'
	call KARAKTER_GONDER
	return
YAZ_DIV
	movlw '/'
	call KARAKTER_GONDER
	return
YAZ_SUB
	movlw '-'
	call KARAKTER_GONDER
	return
YAZ_ADD
	movlw '+'
	call KARAKTER_GONDER
	return
YAZ_4
	movlw '4'
	call KARAKTER_GONDER
	return
YAZ_5
	movlw '5'
	call KARAKTER_GONDER
	return
YAZ_6
	movlw '6'
	call KARAKTER_GONDER
	return
YAZ_1
	movlw '1'
	call KARAKTER_GONDER
	return
YAZ_2
	movlw '2'
	call KARAKTER_GONDER
	return
YAZ_3
	movlw '3'
	call KARAKTER_GONDER
	return
YAZ_0
	movlw '0'
	call KARAKTER_GONDER
	return

ON_AYARLAR
	banksel TRISD
	movlw b'11110000'
	movwf TRISD
	banksel PORTD
	clrf PORTD
	return
BASLA
	call LCD_AYARLA
	call ON_AYARLAR
DONGU
	bsf PORTD,0
	call SATIR1
	bcf PORTD,0
	bsf PORTD,1
	call SATIR2
	bcf PORTD,1
	bsf PORTD,2
	call SATIR3
	bcf PORTD,2
	bsf PORTD,3
	call SATIR4
	bcf PORTD,3
	call GECIKME_80MS
	goto DONGU
SATIR1
	banksel PORTD
	btfsc PORTD,4
	call YAZ_7
	btfsc PORTD,5
	call YAZ_8
	btfsc PORTD,6
	call YAZ_9
	btfsc PORTD,7
	call YAZ_DIV
	return
SATIR2
	banksel PORTD
	btfsc PORTD,4
	call YAZ_4
	btfsc PORTD,5
	call YAZ_5
	btfsc PORTD,6
	call YAZ_6
	btfsc PORTD,7
	call YAZ_MUL
	return
SATIR3
	banksel PORTD
	btfsc PORTD,4
	call YAZ_1
	btfsc PORTD,5
	call YAZ_2
	btfsc PORTD,6
	call YAZ_3
	btfsc PORTD,7
	call YAZ_SUB
	return
SATIR4
	banksel PORTD
	btfsc PORTD,4
	call EKRANI_TEMIZLE
	btfsc PORTD,5
	call YAZ_0
	btfsc PORTD,6
	call EKRANI_TEMIZLE
	btfsc PORTD,7
	call YAZ_ADD
	return
		
END