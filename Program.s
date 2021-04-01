; PERRIER Pierre, CE-OUGNA Sarah - ESIEE Paris
; 12/2018 - Evalbot (Cortex M3 de Texas Instrument)
; Projet - CacheBot (Jeu de cache-cache entre deux robots)



		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
		; Import des fonctions du fichier RK_Led_Switch_Bumper.s
		IMPORT LED_SWITCH_INIT 				; Initialise les LED, Switchs et Bumpers
		IMPORT ALLUME_DROITE				; Allume la LED Droite
		IMPORT ALLUME_GAUCHE				; Allume la LED Gauche
		IMPORT ETEINT_DROITE				; Eteint la LED Droite
		IMPORT ETEINT_GAUCHE				; Eteint la LED Gauche
			
		; Import des fonctions du fichier RK_Moteur.s
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche


__main	

		; Configure les LED, Switchs et Bumpers
		BL  LED_SWITCH_INIT

		; Configure les PWM + GPIO
		BL	MOTEUR_INIT	   


; Lis l'état du bouton poussoir 1, si le bouton est poussé, alors le programme va à la branche "Cache",
; Sinon, le programme va à la branche "ReadState2" qui lit le bouton poussoir 2
ReadState
		ldr r11,[r7]
		CMP r11,#0x00
		BNE ReadState2
		BL Cache
		
		
; Lis l'état du bouton poussoir 2, si le bouton est poussé, alors le programme va à la branche "Cherche",
; Sinon, le programme retourne à la branche "ReadState" qui lit le bouton poussoir 1
ReadState2
		ldr r11,[r10]
		CMP r11,#0x00
		BNE ReadState
		BL Cherche
		
		
; Branche du programme de celui qui se cache
Cache	
		; Allumer la LED droite
		BL ALLUME_DROITE	
		
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		
		; Evalbot avance droit devant
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_AVANT
		
		; Avancement pendant une période (deux WAIT)
		BL	WAIT	; BL (Branchement vers le lien WAIT); possibilité de retour à la suite avec (BX LR)
		BL	WAIT
		
		; Rotation à gauche de l'Evalbot pendant une demi-période (1 seul WAIT), il fait donc ici un quart de tour
		BL	MOTEUR_GAUCHE_ARRIERE   ; MOTEUR_GAUCHE_INVERSE
		BL	WAIT
		
		; Avancement pendant une période (deux WAIT)
		BL	MOTEUR_GAUCHE_AVANT
		BL	WAIT
		BL	WAIT
		
		; Désactiver les deux moteurs droit et gauche, le robot s'arrête donc
		BL	MOTEUR_DROIT_OFF
		BL	MOTEUR_GAUCHE_OFF
		
		; Allumer la LED Gauche (Les deux LEDs sont donc allumées)
		BL ALLUME_GAUCHE
		
		;Fin du programme de celui qui se cache, on retourne à la branche ReadState, qui lit l'état du Switch 1
		; On peut ainsi recommencer la partie
		BL ReadState	


; Branche du programme de celui qui cherche
Cherche	
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON

; Ici débute la boucle qui fera suivre un pattern à notre robot
loop	
		; Eteindre la LED Gauche puis allumer la LED droite
		BL ETEINT_GAUCHE
		BL ALLUME_DROITE
		
		; Evalbot avance droit devant
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_AVANT
		
		; Avancement pendant deux périodes (quatre WAIT),
		; A chaque étape de l'avancement, 
		; On vérifie s'il y a collision en lisant l'état des Bumpers grâce à la branche ReadCollision
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		
		; Rotation à gauche de l'Evalbot pendant une demi-période (1 seul WAIT), il fait donc ici un quart de tour
		BL	MOTEUR_GAUCHE_ARRIERE   ; MOTEUR_GAUCHE_INVERSE
		BL	WAIT
		
		; Avancement du robot pendant 1 WAIT, tout en vérifiant s'il y a collision
		BL	MOTEUR_GAUCHE_AVANT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		
		; De nouveau rotation à gauche pendant une demi-période (1 seul WAIT), il refait donc un quart de tour
		BL	MOTEUR_GAUCHE_ARRIERE   ; MOTEUR_GAUCHE_INVERSE
		BL	WAIT
		
		; Eteindre la LED droite puis allumer la LED gauche
		BL ETEINT_DROITE
		BL ALLUME_GAUCHE
		
		; Avancement pendant deux périodes (quatre WAIT),
		; A chaque étape de l'avancement, 
		; On vérifie s'il y a collision en lisant l'état des Bumpers grâce à la branche ReadCollision
		BL	MOTEUR_GAUCHE_AVANT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		
		; Rotation à droite de l'Evalbot pendant une demi-période (1 seul WAIT), il fait donc un quart de tour
		BL	MOTEUR_DROIT_ARRIERE   ; MOTEUR_GAUCHE_INVERSE
		BL	WAIT
		
		; Avancement du robot pendant 1 WAIT, tout en vérifiant s'il y a collision
		BL	MOTEUR_DROIT_AVANT  ; MOTEUR_GAUCHE_INVERSE
		BL 	ReadCollision
		BL	WAIT
		BL 	ReadCollision
		
		; Rotation à droite de l'Evalbot pendant une demi-période (1 seul WAIT), il refait donc un quart de tour
		BL	MOTEUR_DROIT_ARRIERE   ; MOTEUR_GAUCHE_INVERSE
		BL	WAIT 
		
		; Le robot vient d'effectuer un aller-retour avec un décalage vers la gauche,
		; Il ne lui reste plus qu'à effectuer ce même pattern de déplacement
		; Jusqu'à ce qu'il entre en contact avec le robot qui se cache
		BL 	loop 	; Retour au début de la branche loop
		
		
; Branche vérifiant l'état des Bumpers : si un des deux est appuyé, 
; Cela signifie que notre robot est entré en contact avec l'autre, 
; On va alors à la branche GAGNE
; Sinon, on revient où on en était dans le code avec BX LR
ReadCollision
		ldr r11,[r5]
		CMP r11,#0x00
		BEQ GAGNE 
		ldr r11,[r4]
		CMP r11,#0x00
		BEQ GAGNE 
		BX LR
		
		
; Code à effectuer par le robot qui cherche une fois qu'il a trouvé l'autre robot (donc gagné)
GAGNE   
		; Désactiver les deux moteurs droit et gauche, le robot s'arrête donc
		BL	MOTEUR_DROIT_OFF
		BL	MOTEUR_GAUCHE_OFF
		
		; Eteindre les deux LEDs (Droite et Gauche)
		BL 	ETEINT_GAUCHE
		BL 	ETEINT_DROITE
		
		; Faire clignoter les LEDs en appelant successivement les fonctions d'allumage et d'éteinte
		; Elles s'allument (pendant une demi-periode WAIT2) et s'éteignent deux fois chacune
		BL  ALLUME_DROITE
		BL	WAIT2
		BL 	ETEINT_DROITE
		BL  ALLUME_GAUCHE
		BL	WAIT2
		BL 	ETEINT_GAUCHE
		BL  ALLUME_DROITE
		BL	WAIT2
		BL 	ETEINT_DROITE
		BL  ALLUME_GAUCHE
		BL	WAIT2
		BL 	ETEINT_GAUCHE
		
		; Fin du programme de celui qui cherche, on retourne à la branche ReadState, qui lit l'état du Switch 1 
		; On peut ainsi recommencer la partie
		BL	ReadState


; Boucle d'attente pour le déplacement
WAIT	ldr r1, =0x8FFFFF
wait1	subs r1, #1
        bne wait1
		
		; retour à la suite du lien de branchement
		BX	LR
		
; Boucle d'attente pour le clignotement des LED
WAIT2	ldr r1, =0x002FFFFF
wait2	subs r1, #1
        bne wait2
		
		; retour à la suite du lien de branchement
		BX	LR

		NOP
        END
