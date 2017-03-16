;;; TP3

;; Vous vous réveillez dans une salle, seul. Il n'y a pas de fenêtres, pas d'issues possibles à part une porte devant vous.
;; L'ampoule au dessus de votre tête clignote. Vous êtes attachés et pouvez à peine bouger.
;; Une voix vous indique qu'il faut que vous vous échappiez.

;; Le système expert va vous indiquer si vous pouvez sortir de la salle. Des objets seront disposés autour de vous, certains à portée ou pas.
;; Votre taille, votre force et vos compétences en crochetage pourront vous permettre de vous échapper de façon plus ou moins violente.

;; But = être sorti de la salle.
;; Faits
;;      - taille de la personne en cm en présupposant que c'est un adulte
;;      - la force de la personne
;;      - le niveau de compétence en crochetage de la personne
;;      - la hauteur de la salle en cm
;;      - l'état de la porte
;;      - le matériau de la porte
;;      - le matériau des liens
;;      - les objets et leur éloignement de la personne
;;              Note : les objets possédés sont à 0 d'éloignement

;; Valeurs possibles
;;      - personHeight є [50, 280]
;;      - personStrength є {0, 1, 2, 3, 4}
;;      - personLockPicking є {0, 1, 2, 3}
;;      - roomHeight є [180, 500]
;;      - doorMaterial є {rawWood, chipBoard, metal, glass, plastic}
;;                       (bois brut, aggloméré, verre, plastique)
;;      - linkMaterial є {climbingRope, rustySteelChains, steelChains, twine, belt, plasticClamp}
;;                       (corde d'escalade, chaines rouillées, chaines inox, ficelle, ceinture, serrage plastique)
;;      - object є {knife, axe, chainKey, doorKey, chair, camera, brokenGlass, glassBottle, hammer, bigWoodStick}
;;                       (couteau, hache, cle chaines, cle porte, chaise, camera, morceau de verre, bouteille de verre, marteau, gros morceau de bois)

;; Profondeur :
;;      - Se détacher les mains
;;      - Ouvrir la porte
;;      - Sortir de la salle

;; Initialisation :
;;      - vérification des données et demande des données nécessaires
;;      - personLegSize = personHeight*0.525

;; Exemple de Bases de Faits (Fact Base)

;; (setq *FB*
;; 	'(
;; 		(personHeight 177)
;; 		(personStrength 2)
;; 		(personLockPicking 3)
;; 		(roomHeight 250)
;; 		(doorMaterial metal)
;; 		(linkMaterial twine)
;; 		(object knife)
;; 		(knifeDistance 20)
;; 		(object glassBottle)
;; 		(glassBottleDistance 250)
;; 	)
;; )

;; (setq *FB*
;; 	'(
;; 		(personHeight 150)
;; 		(personStrength 4)
;; 		(personLockPicking 0)
;; 		(roomHeight 100)
;; 		(doorMaterial rawWood)
;; 		(linkMaterial belt)
;; 		(object hammer)
;; 		(hammerDistance 20)
;; 	)
;; )

;; (setq *FB*
;; 	'(
;; 		(personStrength 3)
;; 		(doorMaterial metal)
;; 		(linkMaterial steelChains)
;; 		(object doorKey)
;; 		(doorKeyDistance 100)
;; 	)
;; )


;; Représentation de la Base de Règles (Rule Base)
;; 51 regles

(setq *RB* '(
;;  Récupérer un objet
	(OKN ((knife object find-object) (knifeDistance personLegSize <=)) (possessedObject knife) "Vous recuperez un couteau avec votre pied.")
	(OAX ((axe object find-object) (axeDistance personLegSize <=)) (possessedObject axe) "Vous recuperez une hache avec votre pied.")
	(OCK ((chainKey object find-object) (chainKeyDistance personLegSize <=)) (possessedObject chainKey) "Vous recuperez une cle de cadenas avec votre pied.")
	(ODK ((doorKey object find-object) (doorKeyDistance personLegSize <=)) (possessedObject doorKey) "Vous recuperez une cle de porte avec votre pied.")
	(OCH ((chair object find-object) (chairDistance personLegSize <=)) (possessedObject chair) "Vous recuperez une chaise avec votre jambe.")
	(OGL ((brokenGlass object find-object) (brokenGlassDistance personLegSize <=)) (possessedObject brokenGlass) "Vous recuperez un morceau de verre avec votre pied.")
	(OGB ((glassBottle object find-object) (glassBottleDistance personLegSize <=)) (possessedObject glassBottle) "Vous recuperez une bouteille en verre avec votre pied.")
	(OHA ((hammer object find-object) (hammerDistance personLegSize <=)) (possessedObject hammer) "Vous recuperez un marteau avec votre pied.")
	(OWS ((bigWoodStick object find-object) (bigWoodStickDistance personLegSize <=)) (possessedObject bigWoodStick) "Vous recuperez un gros morceau de bois avec votre pied.")
;;	Récupérer un objet en ayant les mains libres
	(PKN ((knife object find-object) (hands free)) (possessedObject knife) "Vous ramassez un couteau.")
	(PAX ((axe object find-object) (hands free)) (possessedObject axe) "Vous ramassez une hache.")
	(PCK ((chainKey object find-object) (hands free)) (possessedObject chainKey)  "Vous ramassez une cle de cadenas.")
	(PDK ((doorKey object find-object) (hands free)) (possessedObject doorKey) "Vous ramassez une cle de porte.")
	(PCH ((chair object find-object) (hands free)) (possessedObject chair)  "Vous ramassez une chaise.")
	(PGL ((brokenGlass object find-object) (hands free)) (possessedObject brokenGlass)  "Vous ramassez un morceau de verre.")
	(PGB ((glassBottle object find-object) (hands free)) (possessedObject glassBottle)  "Vous ramassez une bouteille en verre.")
	(PHA ((hammer object find-object) (hands free)) (possessedObject hammer) "Vous ramassez un marteau.")
	(PWS ((bigWoodStick object find-object) (hands free)) (possessedObject bigWoodStick) "Vous ramassez un gros morceau de bois.")
	(PCA ((camera object find-object) (hands free)) (possessedObject camera) "Vous ramassez une camera.")
;;  Récupérer le haut parleur accroché au plafond
	(PSP ((hands free) (((personHeight 0.9 *) (personHeight 3 /) +) roomHeight >=)) (possessedObject camera)  "Vous arrachez la camera qui vous filmait au plafond.")
;;  Casser des objets
	(BCH ((chair possessedObject find-object)) (possessedObject bigWoodStick) "Vous arrachez un pied a la chaise. Vous obtenez un gros morceau de bois.")
	(BGB ((glassBottle possessedObject find-object)) (possessedObject brokenGlass)  "Vous cassez votre bouteille. Vous obtenez des morceaux de verre.")
	(BCA ((camera possessedObject find-object)) (possessedObject brokenGlass) "Vous cassez la lentille de la camera. Vous obtenez des morceaux de verre.")
;;  Casser ses liens
	(BTWST ((personStrength 3 >=) (linkMaterial twine)) (hands free) "Vous cassez vos liens a mains nues. Vous avez les mains libres !")
	(BBEST ((personStrength 4 >=) (linkMaterial belt)) (hands free) "Vous cassez vos liens a mains nues. Vous avez les mains libres !")
	(BTWKN ((knife possessedObject find-object) (linkMaterial twine)) (hands free) "Vous cassez vos liens grace a votre couteau. Vous avez les mains libres !")
	(BBEKN ((knife possessedObject find-object) (linkMaterial belt)) (hands free) "Vous cassez vos liens grace a votre couteau. Vous avez les mains libres !")
	(BPCKN ((knife possessedObject find-object) (linkMaterial plasticClamp)) (hands free) "Vous cassez vos liens grace a votre couteau. Vous avez les mains libres !")
	(BCRKN ((knife possessedObject find-object) (linkMaterial climbingRope) (personStrength 3 >=)) (hands free) "Vous cassez vos liens grace a votre couteau. Vous avez les mains libres !")
	(BTWGL ((brokenGlass possessedObject find-object) (linkMaterial twine)) (hands free) "Vous cassez vos liens grace a un morceau de verre. Vous avez les mains libres !")
	(BRCCK ((chainKey possessedObject find-object) (linkMaterial rustySteelChains)) (hands free) "Vous ouvrez le cadenas des chaines qui vous maintenaient grace a votre cle. Vous avez les mains libres !")
	(BSCCK ((chainKey possessedObject find-object) (linkMaterial steelChains)) (hands free) "Vous ouvrez le cadenas des chaines qui vous maintenaient grace a votre cle. Vous avez les mains libres !")
;;  Crocheter ses liens
	(BLKKN ((knife possessedObject find-object) (personLockPicking 2 >=)) (hands free) "Vous crochetez le cadenas des chaines qui vous maintenaient grace a votre couteau. Vous avez les mains libres !")
;;  Casser la porte
	(BGLST ((hands free) (doorMaterial glass) (personStrength 2 >=)) (door open) "Vous defoncez la porte avec votre épaule.")
	(BCBST ((hands free) (doorMaterial chipBoard) (personStrength 3 >=)) (door open) "Vous defoncez la porte avec votre épaule.")
	(BPLST ((hands free) (doorMaterial plastic) (personStrength 4 =)) (door open) "Vous defoncez la porte avec votre épaule.")
	(BGLCA ((hands free) (camera possessedObject find-object) (doorMaterial glass) (personStrength 2 >=)) (door open) "Vous defoncez la porte a l'aide de votre camera.")
	(BCBCA ((hands free) (camera possessedObject find-object) (doorMaterial chipBoard) (personStrength 3 >=)) (door open) "Vous defoncez la porte a l'aide de votre camera.")
	(BGLWS ((hands free) (bigWoodStick possessedObject find-object) (doorMaterial glass)) (door open) "Vous defoncez la porte a l'aide de votre gros morceau de bois.")
	(BCBWS ((hands free) (bigWoodStick possessedObject find-object) (doorMaterial chipBoard)) (door open) "Vous defoncez la porte a l'aide de votre gros morceau de bois.")
	(BPLWS ((hands free) (bigWoodStick possessedObject find-object) (doorMaterial plastic) (personStrength 2 >=)) (door open) "Vous defoncez la porte a l'aide de votre gros morceau de bois.")
	(BGLHA ((hands free) (hammer possessedObject find-object) (doorMaterial glass)) (door open) "Vous cassez la porte a l'aide de votre marteau.")
	(BCBHA ((hands free) (hammer possessedObject find-object) (doorMaterial chipBoard)) (door open) "Vous cassez la porte a l'aide de votre marteau.")
	(BPLHA ((hands free) (hammer possessedObject find-object) (doorMaterial plastic)) (door open) "Vous cassez la porte a l'aide de votre marteau.")
	(BRWHA ((hands free) (hammer possessedObject find-object) (doorMaterial rawWood) (personStrength 3 >=)) (door open) "Vous cassez la porte a l'aide de votre marteau.")
	(BGLAX ((hands free) (axe possessedObject find-object) (doorMaterial glass)) (door open) "Vous cassez la porte a l'aide de votre hache.")
	(BCBAX ((hands free) (axe possessedObject find-object) (doorMaterial chipBoard)) (door open) "Vous cassez la porte a l'aide de votre hache.")
	(BPLAX ((hands free) (axe possessedObject find-object) (doorMaterial plastic)) (door open) "Vous cassez la porte a l'aide de votre hache.")
	(BRWAX ((hands free) (axe possessedObject find-object) (doorMaterial rawWood) (personStrength 2 >=)) (door open) "Vous cassez la porte a l'aide de votre hache.")
;; 	Crocheter la porte
	(BDRKN ((hands free) (knife possessedObject find-object) (personLockPicking 2 >=)) (door open) "Vous crochetez la serrure de la porte a l'aide de votre couteau.")
	(BDRDK ((hands free) (doorKey possessedObject find-object)) (door open) "Vous ouvrez la porte grace a votre cle.")
;;  Sortir de la salle et gagner
	(WIN ((door open)) (you escaped) "Vous pouvez enfin sortir ! Alors que vous depassez le pas de la porte, la voix vous felicite dans un dernier ricanement.")
))