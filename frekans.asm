	list p='16f877a'
	#include<P16F877A.INC>
	
	cblock 0x20
	sayac1
	sayac2
	sayi_l
	sayi_h
	yedek_4bit
	veri
	gecikme1
	gecikme2
	bcd1
	bcd2
	bcd3
	bcd4
	bcd5
	sayi1_tmp
	sayi2_tmp
	endc
	
	org 0x00
	goto BASLA
	
	org 0x04
KESME
	btfsc INTCON,TMR0IF
	goto SANIYE
	banksel PIR1
	btfsc PIR1,CCP1IF
	goto SINYAL
	
	goto KESME_BITIR
	
SINYAL
	banksel PIR1
	bcf PIR1,CCP1IF
	incf sayi_l,f
	btfsc STATUS,Z
	incf sayi_h,f
	goto KESME_BITIR
	
SANIYE
	bcf INTCON,TMR0IF
	banksel TMR0
	movlw .131
	movwf TMR0
	decfsz sayac1,f
	goto KESME_BITIR
	decfsz sayac2,f
	goto KESME_BITIR
	
	movlw .250
	movwf sayac1
	movlw .4
	movwf sayac2
	
	call BCD_KODLA
	call BCD_YAZ
	
	call GECIKME_50MS
	
	clrf sayi_h
	clrf sayi_l
	goto KESME_BITIR
KESME_BITIR
	retfie
	
BCD_LOOKUP
	addwf PCL,f
	retlw '0'
	retlw '1'
	retlw '2'
	retlw '3'
	retlw '4'
	retlw '5'
	retlw '6'
	retlw '7'
	retlw '8'
	retlw '9'
	
BCD_KODLA
	clrf bcd1
	clrf bcd2
	clrf bcd3
	clrf bcd4
	clrf bcd5
	movf sayi_h,w
	btfss STATUS,Z
	call H_BITIR
	
	movf sayi_l,w
	btfsc STATUS,Z
	goto BCD_BITIR	
	movwf sayi2_tmp
dongu_l
	call BCD_KONTROL
	decfsz sayi2_tmp	
	goto dongu_l
	goto BCD_BITIR
	
H_BITIR
	movf sayi_h,w
	movwf sayi1_tmp
dongu_h_1
	movlw .0
	movwf sayi2_tmp
dongu_h
	call BCD_KONTROL
	decfsz sayi2_tmp
	goto dongu_h
	decfsz sayi1_tmp
	goto dongu_h_1
	return
	 
BCD_BITIR
	return
	
BCD_KONTROL
	incf bcd1,f
	movlw .10
	subwf bcd1,w
	btfss STATUS,Z
	return
	
	clrf bcd1

	incf bcd2,f
	movlw .10
	subwf bcd2,w
	btfss STATUS,Z
	return
	
	clrf bcd2
	
	incf bcd3,f
	movlw .10
	subwf bcd3,w
	btfss STATUS,Z
	return
	
	clrf bcd3
	
	incf bcd4,f
	movlw .10
	subwf bcd4,w
	btfss STATUS,Z
	return
	
	clrf bcd4
	
	incf bcd5,f
	movlw .10
	subwf bcd5,w
	btfss STATUS,Z
	return
	return
BCD_YAZ
	call EKRANI_TEMIZLE
	call GECIKME_5MS
	movf bcd5,w
	call BCD_LOOKUP
	call KARAKTER_GONDER

	movf bcd4,w
	call BCD_LOOKUP
	call KARAKTER_GONDER
	
	movf bcd3,w
	call BCD_LOOKUP
	call KARAKTER_GONDER
	
	movf bcd2,w
	call BCD_LOOKUP
	call KARAKTER_GONDER
	
	movf bcd1,w
	call BCD_LOOKUP
	call KARAKTER_GONDER
	
	movlw 'H'
	call KARAKTER_GONDER
	movlw 'z'
	call KARAKTER_GONDER
	return
GECIKME_200US
	movlw .66
	movwf gecikme1
g1
	decfsz gecikme1,f
	goto g1
	return
GECIKME_5MS
	movlw .100
	movwf gecikme1
gm
	movlw .20
	movwf gecikme2
gn
	decfsz gecikme2,f
	goto gn
	decfsz gecikme1,f
	goto gm
	return
GECIKME_50MS
	movlw .100
	movwf gecikme1
gx
	movlw .140
	movwf gecikme2
gy
	decfsz gecikme2,f
	goto gy
	decfsz gecikme1,f
	goto gx
	return
EKRANI_TEMIZLE
	movlw 0x01
	call KOMUT_GONDER
	return
DUSEN_KENAR
	banksel PORTB
	bsf PORTB,5
	call GECIKME_200US
	bcf PORTB,5
	return
GONDER_4BIT
	banksel PORTB
	andlw 0x0F
	movwf yedek_4bit
	movf PORTB,w
	andlw 0xF0
	iorwf yedek_4bit,w
	movwf PORTB
	call DUSEN_KENAR
	call GECIKME_200US
	return
KOMUT_GONDER
	banksel PORTB
	bcf PORTB,4
	movwf veri
	swapf veri,w
	call GONDER_4BIT
	movf veri,w
	call GONDER_4BIT
	return
KARAKTER_GONDER
	banksel PORTB
	movwf veri
	swapf veri,w
	bsf PORTB,4
	call GONDER_4BIT
	movf veri,w
	call GONDER_4BIT
	return
	
ON_AYARLAR
	banksel TRISC
	bsf TRISC,2
	bsf TRISC,0
	banksel CCP1CON
	movlw b'00000101'
	movwf CCP1CON
	banksel TMR0
	movlw .131
	movwf TMR0
	movlw .250
	movwf sayac1
	movlw .4
	movwf sayac2
	banksel OPTION_REG
	movlw b'10000010'
	movwf OPTION_REG
	banksel T1CON
	movlw b'00000001'
	movwf T1CON
	banksel TMR1L
	clrf TMR1L
	clrf TMR1H
	banksel PIE1
	bsf PIE1,CCP1IE
	bcf PIE1,TMR1IE
	bsf INTCON,TMR0IE
	bsf INTCON,PEIE
	bsf INTCON,GIE
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
	call GECIKME_5MS
	movlw 0x01
	call KOMUT_GONDER
	movlw 0x06
	call KOMUT_GONDER
	call GECIKME_5MS
	movlw 0x0D
	call KOMUT_GONDER
	
	return
	
BASLA
	call LCD_AYARLA
	call ON_AYARLAR
	goto $
END