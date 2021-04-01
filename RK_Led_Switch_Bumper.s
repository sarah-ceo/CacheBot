; PERRIER Pierre, CE-OUGNA Sarah - ESIEE Paris
; 12/2018 - Evalbot (Cortex M3 de Texas Instrument)
; Projet - CacheBot (Jeu de cache-cache entre deux robots)
 
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000	; GPIO Port E (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Broches select
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5

BROCHE6_7			EQU 	0xC0		; boutons poussoirs 1&2
BROCHE6				EQU 	0x40		; bouton poussoirs 1
BROCHE7				EQU 	0x80		; bouton poussoirs 2

BROCHE0_1			EQU 	0x03		; bumpers 1&2
BROCHE0				EQU 	0x01		; bumper 1
BROCHE1				EQU 	0x02		; bumper 2

		AREA    |.text|, CODE, READONLY
	  	ENTRY
		
		; Export des fonctions contenues dans le fichier
		EXPORT LED_SWITCH_INIT
		EXPORT ALLUME_DROITE
		EXPORT ALLUME_GAUCHE
		EXPORT ETEINT_DROITE
		EXPORT ETEINT_GAUCHE

; Fonction d'initialisation (configuration des LED, Switchs et Bumpers)
LED_SWITCH_INIT

		; ;; Enable the Port E, F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)
		; ;;									
		ldr r8, = SYSCTL_PERIPH_GPIO  			;; RCGC2
        mov r0, #0x00000038  					;; Enable clock sur GPIO D et F où sont branchés les leds (0x28 == 0b111000)
		; ;;														 									      (GPIO::FEDCBA)
        str r0, [r8]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...
	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r8, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = BROCHE4_5 	
        str r0, [r8]
		
		ldr r8, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE4_5		
        str r0, [r8]
		
		ldr r8, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)
        ldr r0, = BROCHE4_5			
        str r0, [r8]
		
		mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (BROCHE4_5)
		mov r3, #BROCHE4_5		;; Allume LED1&2 portF broche 4&5 : 00110000
		
		ldr r8, = GPIO_PORTF_BASE + (BROCHE4_5<<1)  ; @data Register = @base + (mask<<1) ==> LED 1
		ldr r9, = GPIO_PORTF_BASE + (BROCHE4_5<<3)  ; @data Register = @base + (mask<<1) ==> LED 2
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION SWITCH

		ldr r7, = GPIO_PORTD_BASE+GPIO_I_PUR	;; Pul_up 
        ldr r0, = BROCHE6_7
        str r0, [r7]
		
		ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE6_7	
        str r0, [r7]     
		
		ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)  ;; @data Register = @base + (mask<<2) ==> Switcher 1
		ldr r10, = GPIO_PORTD_BASE + (BROCHE7<<2)  ;; @data Register = @base + (mask<<2) ==> Switcher 2
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration SWITCH
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION BUMPER

		ldr r5, = GPIO_PORTE_BASE+GPIO_I_PUR	;; Pul_up 
        ldr r0, = BROCHE0_1
        str r0, [r5]
		
		ldr r5, = GPIO_PORTE_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE0_1	
        str r0, [r5]     
		
		ldr r5, = GPIO_PORTE_BASE + (BROCHE0<<2)  ;; @data Register = @base + (mask<<2) ==> BUMPER 1
		ldr r4, = GPIO_PORTE_BASE + (BROCHE1<<2)  ;; @data Register = @base + (mask<<2) ==> BUMPER 2
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration BUMPER
		
		BX	LR
		
		
; Fonction pour allumer la LED Droite
ALLUME_DROITE

		str r3, [r8]  							; Allume LED1 portF broche 4 : 00010000 (contenu de r3)  
		BX	LR	
		
		
; Fonction pour éteindre la LED Droite
ETEINT_DROITE
		str r2, [r8]
		BX LR
		
		
; Fonction pour allumer la LED Gauche
ALLUME_GAUCHE

		str r3, [r9]  							; Allume LED2 portF broche 5 : 00100000 (contenu de r3)
		BX	LR	
		
		
; Fonction pour éteindre la LED Gauche		
ETEINT_GAUCHE
		str r2, [r9]
		BX LR
		
		END 