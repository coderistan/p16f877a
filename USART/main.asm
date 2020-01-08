	list p='16f877a'
	#include<P16F877A.INC>
	__CONFIG h'3F31'
	
	cblock 0x20
	yedek_4bit
	veri
	gecikme1
	gecikme2
	tmp
	tmp2
	sayac1
	sayac2
	sayi
	sayi_l
	sayi_h
	bcd_1
	bcd_2
	bcd_3
	bcd_4
	bcd_5
	tmp_h
	tmp_l
	SATIR ; kursor için satýr
	SUTUN ; kursor için sütun
	endc 
	
	ORG 0x00
	goto BASLA
	org 0x04
; ############################################################## KESME KISMI
KESME
	btfsc INTCON,TMR0IF ; TMR0 KESMESI MI
	goto TMR0_KESME
	banksel PIR1
	btfsc PIR1,RCIF ; veri alým kesmesi mi?
	goto RC_KESME
	
	goto KESME_CIK

TMR0_KESME	
	banksel TMR0
	movlw .131
	movwf TMR0
	
	bcf INTCON,TMR0IF
	decfsz sayac1,f
	goto KESME_CIK
	decfsz sayac2,f
	goto KESME_CIK
	
	movlw .250
	movwf sayac1
	movlw .4
	movwf sayac2
	
	call BIR_SANIYE
	goto KESME_CIK
RC_KESME
	banksel PIR1
	bcf PIR1,RCIF
	
	banksel RCREG
	movf RCREG,w
	movwf tmp2
	
	banksel PORTC
	movlw '1'
	subwf tmp2,w
	btfss STATUS,Z ; gelen veri 1 midir?
	goto SONDUR ; deðilse ledi söndür
	goto YAK    ; 1 ise ledi yak
YAK
	bsf PORTC,0
	goto KESME_CIK
SONDUR
	bcf PORTC,0
KESME_CIK
	retfie
	
BIR_SANIYE
	bcf STATUS,C
	movlw .1
	addwf sayi_l,w
	movwf sayi_l
	btfss STATUS,C
	goto BITIR
	clrf sayi_l
	incf sayi_h,f
BITIR
	call CLEAN
	call BCD_YAZ
	return 
; ############################################################## KESME KISMI BITTI


; ############################################################## BCD KODLAMA KISMI
BCD_KODLA
	movf sayi_h,w
	movwf tmp_h
	btfss STATUS,Z
	call UST_BITIR
	movf sayi_l,w
	movwf tmp_l
	btfsc STATUS,Z
	return
d1
	call BCD_BASAMAK
	decfsz tmp_l,f
	goto d1
	return
	
UST_BITIR
	movlw 0x00
	movwf tmp_l
tt
	call BCD_BASAMAK
	decfsz tmp_l,f
	goto tt
	decfsz tmp_h,f
	goto UST_BITIR
	return
	
BCD_BASAMAK
	incf bcd_1,f
	movlw .10
	subwf bcd_1,w
	btfss STATUS,Z
	return
	
	clrf bcd_1
	incf bcd_2,f
	movlw .10
	subwf bcd_2,w
	btfss STATUS,Z
	return
	
	clrf bcd_2
	incf bcd_3,f
	movlw .10
	subwf bcd_3,w
	btfss STATUS,Z
	return
	
	clrf bcd_3
	incf bcd_4,f
	movlw .10
	subwf bcd_4,w
	btfss STATUS,Z
	return
	
	clrf bcd_4
	incf bcd_5,f
	movlw .10
	subwf bcd_5,w
	btfsc STATUS,Z
	clrf bcd_5
	return
BCD_YAZ
	clrf bcd_1
	clrf bcd_2
	clrf bcd_3
	clrf bcd_4
	clrf bcd_5
	call BCD_KODLA
	
	movf bcd_5,w
	call ASCII_LOOKUP
	call KARAKTER_YAZ
	
	movf bcd_4,w
	call ASCII_LOOKUP
	call KARAKTER_YAZ
	
	movf bcd_3,w
	call ASCII_LOOKUP
	call KARAKTER_YAZ

	movf bcd_2,w
	call ASCII_LOOKUP
	call KARAKTER_YAZ
	
	movf bcd_1,w
	call ASCII_LOOKUP
	call KARAKTER_YAZ
	return
; ################################################# BCD BITTI


; ####################################### GECIKMELER
GECIKME_50MS
	movlw .129
	movwf gecikme1
g1
	movlw .129
	movwf gecikme2
g2
	decfsz gecikme2
	goto g2
	decfsz gecikme1
	goto g1
	return
GECIKME_200US
	movlw .8
	movwf gecikme1
gx
	movlw .8
	movwf gecikme2
gy
	decfsz gecikme2,f
	goto gy
	decfsz gecikme1,f
	goto gx
	return
GECIKME_5MS
	movlw .40
	movwf gecikme1
gk
	movlw .40
	movwf gecikme2
gl
	decfsz gecikme2,f
	goto gl
	decfsz gecikme1,f
	goto gk
	return
GECIKME_KEY	; buton gecikmesi
	movlw .240
	movwf gecikme1
gn
	movlw .240
	movwf gecikme2
gm
	decfsz gecikme2,f
	goto gm
	decfsz gecikme1,f
	goto gn
	return
; ####################################### GECIKMELER BITTI

; ###########################################################LCD KISMI
KURSOR_KONUM
	movlw 0x80
	movf SATIR,f
	btfss STATUS,Z
	movlw 0xC0
	addwf SUTUN,w
	call KOMUT_GONDER
	return
DUSEN_KENAR
	banksel PORTB
	bsf PORTB,5
	call GECIKME_200US
	bcf PORTB,5
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
	call GECIKME_5MS
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
KARAKTER_YAZ
	movwf veri
	swapf veri,w
	banksel PORTB
	bsf PORTB,4
	call GONDER_4BIT
	movf veri,w
	bsf PORTB,4
	call GONDER_4BIT
	return
CLEAN
	movlw 0x01
	call KOMUT_GONDER
	return
ASCII_LOOKUP
	addwf PCL,f
	retlw 0x30
	retlw 0x31
	retlw 0x32
	retlw 0x33
	retlw 0x34
	retlw 0x35
	retlw 0x36
	retlw 0x37
	retlw 0x38
	retlw 0x39
LCD_AYARLA
	banksel TRISB
	clrf TRISB
	banksel PORTB
	
	call GECIKME_50MS
	bcf PORTB,4
	movlw 0x03
	call GONDER_4BIT
	call GECIKME_5MS
	call DUSEN_KENAR
	call GECIKME_200US
	call DUSEN_KENAR
	call GECIKME_200US
	
	bcf PORTB,4
	
	movlw 0x02
	call GONDER_4BIT
	call GECIKME_200US
	
	movlw 0x28
	call KOMUT_GONDER
	movlw 0x0F
	call KOMUT_GONDER
	call GECIKME_5MS
	movlw 0x01
	call KOMUT_GONDER
	movlw 0x06
	call KOMUT_GONDER
	movlw 0x0D
	call KOMUT_GONDER
		
	return
; ###########################################################LCD KISMI BITTI


TMR0_AYARLA
	movlw .250
	movwf sayac1
	movlw .4
	movwf sayac2
	banksel OPTION_REG
	movlw b'10000010'
	movwf OPTION_REG
	banksel TMR0
	movlw .131
	movwf TMR0
	movlw b'10100000'
	movwf INTCON
	return

USART_AYARLA
	banksel SPBRG
	movlw .25
	movwf SPBRG ; Baud hýzý 9600
	banksel TXSTA
	bcf TXSTA,4 ; asenkron modu
	bsf TXSTA,BRGH ; yüksek hýzda alým ve gönderim
	banksel RCSTA
	bsf RCSTA,7 ; seri portlar aktif
	bsf RCSTA,CREN ; sürekli alým aktif
	banksel PIE1
	bsf PIE1,TXIE ; gönderme kesmesi aktif
	bsf PIE1,RCIE ; alým kesmesi aktif
	; gönderilecek veri TXREG içine yüklenmelidir
	bsf INTCON,PEIE ; özel kesmeler aktif
	bsf INTCON,GIE ; tüm kesmeler aktif
	banksel TRISC
	bcf TRISC,0
	return
	
BASLA
	call LCD_AYARLA
	call TMR0_AYARLA
	call USART_AYARLA
DONGU
	goto DONGU
	END