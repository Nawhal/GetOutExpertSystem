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

;; Sources
;;      - personHeight
;;          (personne la plus petite : 54.6cm https://en.wikipedia.org/wiki/List_of_shortest_people#Men)
;;          (personne la plus grande : 272cm https://en.wikipedia.org/wiki/List_of_tallest_people#Men)
;;      - linkMaterial 
;;          (Corde d'escalade : http://climbing.about.com/od/climbingropes/fl/Can-a-Climbing-Rope-Break-in-a-Fall.htm)
;;      - object
;;          (Outils de crochetage : http://www.wikihow.com/Pick-a-Lock)
;;        Proportions humaines pour la récupération d'objets :
;;          (On considère la taille des jambes comme étant 52.5% de la taille de la personne,
;;          en considérant que la personne est adulte et qu'on prend la moyenne du pourcentage présenté
;;          sur le schéma suivant : https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2872302/#__sec12title)
;;          ("An average person, is generally 7-and-a-half heads tall (including the head)"
;;           La taille de la tête de la personne sera sonc de personHeight/7.5
;;           https://en.wikipedia.org/wiki/Body_proportions)
;;          (On considère que la main d'une personne mesure : personHeight*0.75/7.5 = personHeight*0.1
;;          et que le bras d'une personne mesure : personHeight*3.5/7.5 = personHeight*7/15
;;           http://www.paintdrawpaint.com/2011/01/drawing-basics-proportions-of-arm.html)
;;          (On considère qu'une personne debout à bras levés peut attraper quelque chose à la hauteur de :
;;           sa hauteur - celle de sa tête + celle de son bras - celle de sa main.
;;           => personHeight - personHeight/7.5 + personHeight*7/15 - personHeight*0.1
;;           => personHeight - personHeight*0.1 - personHeight*2/15 + personHeight*7/15
;;           => personHeight*0.9 + personHeight*5/15
;;           => personHeight*0.9 + personHeight*1/3)

;; Valeurs possibles
;;      - personHeight є [50, 280]
;;      - personStrength є {0, 1, 2, 3, 4}
;;      - personLockPicking є {0, 1, 2, 3}
;;      - roomHeight є [180, 500]
;;      - doorMaterial є {rawWood, chipBoard, metal, glass, plastic}
;;                       (bois brut, aggloméré, verre, plastique)
;;      - linkMaterial є {climbingRope, rustySteelChains, steelChains, twine, belt, plasticClamp}
;;                       (corde d'escalade, chaines rouillées, chaines inox, ficelle, ceinture, serrage plastique)
;;      - (cadr object) є {knife, axe, chainKey, doorKey, chair, speaker, camera, brokenGlass, glassBottle, hammer, bigWoodStick}
;;                        (couteau, hache, tendeur, piquet, clé chaines, clé porte, chaise, haut Parleur, caméra, morceau de verre, bouteille de verre, marteau, gros morceau de bois)
;;      - (caddr object) є [0, roomSize/2]

;; Profondeur :
;;      - Se détacher les mains
;;      - Ouvrir la porte
;;      - Sortir de la salle

;; Initialisation :
;;      - vérification des données et demande des données nécessaires
;;      - personLegSize = personHeight*0.525
;;      - objectDistance = (caddr object)

;; Règles (caddr = function to apply. Si = nil, equal)
;;      Récupérer un objet
;;      - (object knife) && ((personLegSize >= knifeDistance) || (hands free)) => (possessedObject knife)
;;      - (object axe) && ((personLegSize >= axeDistance) || (hands free)) => (possessedObject axe)
;;      - (object pick) && ((personLegSize >= pickDistance) || (hands free)) => (possessedObject pick)
;;      - (object chainKey) && ((personLegSize >= chainKeyDistance) || (hands free)) => (possessedObject chainKey)
;;      - (object doorKey) && ((personLegSize >= doorKeyDistance) || (hands free)) => (possessedObject doorKey)
;;      - (object chair) && ((personLegSize >= chairDistance) || (hands free)) => (possessedObject chair)
;;      - (object brokenGlass) && ((personLegSize >= brokenGlassDistance) || (hands free)) => (possessedObject brokenGlass)
;;      - (object glassBottle) && ((personLegSize >= glassBottleDistance) || (hands free)) => (possessedObject glassBottle)
;;      - (object hammer) && ((personLegSize >= hammerDistance) || (hands free)) => (possessedObject hammer)
;;      - (object bigWoodStick) && ((personLegSize >= bigWoodStickDistance) || (hands free)) => (possessedObject bigWoodStick)
;;      - (object camera) && ((personLegSize >= cameraDistance) || (hands free)) => (possessedObject camera)
;;      Casser des objets
;;      - (possessedObject chair) => (possessedObject bigWoodStick)
;;      - (possessedObject glassBottle) => (possessedObject brokenGlass)
;;      - (possessedObject camera) => (possessedObject brokenGlass)
;;      Utiliser des objets
;;      - (possessedObject camera) => (objecttrength 1)
;;      - (possessedObject knife) => (objecttrength 2)
;;      - (possessedObject bigWoodStick) => (objecttrength 3)
;;      - (possessedObject axe) => (objecttrength 4)
;;      - (possessedObject hammer) => (objecttrength 5)
;;      - (possessedObject pick) => (objectLockPicking 2)
;;      - (possessedObject brokenGlass) => (objectLinkLockPicking 1)
;;      - (possessedObject chainKey) && ((linkMaterial rustySteelChains) || (linkMaterial steelChains)) => (objectLinkLockPicking 42)
;;      - (possessedObject doorKey) => (objectDoorLockPicking 42)
;;      Casser ses liens
;;      - (linkMaterial twine) => (linkHardness 1)
;;      - (linkMaterial belt) => (linkHardness 2)
;;      - (linkMaterial plasticClamp) => (linkHardness 3)
;;      - (linkMaterial climbingRope) => (linkHardness 4)
;;      - (linkMaterial rustySteelChains) => (linkHardness 5)
;;      - (linkMaterial steelChains) => (linkHardness 6)
;;      - (linkBreakingStrengh >= linkHardness) => (hands free)
;;      Récupérer le haut parleur accroché au plafond
;;      - (hands free) && (personHeight*0.9 + personHeight*1/3 >= roomHeight) => (possessedObject speaker)
;;      Ouvrir la porte
;;      - (doorMaterial glass) => (doorHardness 3)
;;      - (doorMaterial chipBoard) => (doorHardness 4)
;;      - (doorMaterial plastic) => (doorHardness 5)
;;      - (doorMaterial rawWood) => (doorHardness 6)
;;      - (doorMaterial metal) => (doorHardness 7)
;;      - (doorOpeningStrength >= doorHardness) => (door open)
;;      Gagner
;;      - (door open) => (you escaped)

;; Exemple de Base de Faits (Fact Base)
;; (setq *FB*
;;     '(
;;         (personHeight 177)
;;         (personStrength 2)
;;         (personLockPicking 3)
;;         (roomHeight 250)
;;         (doorMaterial metal)
;;         (linkMaterial twine)
;; 		(object knife)
;; 		(object glassBottle)
;; 		(knifeDistance 20)
;; 		(glassBottleDistance 250)
;;     )
;; )

(setq *FB*
    '(
        (personHeight 177)
        (personStrength 2)
        (personLockPicking 3)
        (roomHeight 250)
        (doorMaterial metal)
        (linkMaterial twine)
		(object knife)
		(object glassBottle)
		(knifeDistance 20)
		(glassBottleDistance 250)
    )
)

;; (setq *FB*
;; 	'(
;; 		(hands free)
;; 		(personStrength 2)
;; 		(doorMaterial glass)
;; 	)
;; )


;; Représentation de la Base de Règles (Rule Base)

(setq *RB* '(
;;  Récupérer un objet
	(OKN ((knife object find-object) (knifeDistance personLegSize <=)) (possessedObject knife))
	(OAX ((axe object find-object) (axeDistance personLegSize <=)) (possessedObject axe))
	(OCK ((chainKey object find-object) (chainKeyDistance personLegSize <=)) (possessedObject chainKey))
	(ODK ((doorKey object find-object) (doorKeyDistance personLegSize <=)) (possessedObject doorKey))
	(OCH ((chair object find-object) (chairDistance personLegSize <=)) (possessedObject chair))
	(OGL ((brokenGlass object find-object) (brokenGlassDistance personLegSize <=)) (possessedObject brokenGlass))
	(OGB ((glassBottle object find-object) (glassBottleDistance personLegSize <=)) (possessedObject glassBottle))
	(OHA ((hammer object find-object) (hammerDistance personLegSize <=)) (possessedObject hammer))
	(OWS ((bigWoodStick object find-object) (bigWoodStickDistance personLegSize <=)) (possessedObject bigWoodStick))
;;	Récupérer un objet en ayant les mains libres
	(OKN ((knife object find-object) (hands free)) (possessedObject knife))
	(OAX ((axe object find-object) (hands free)) (possessedObject axe))
	(OCK ((chainKey object find-object) (hands free)) (possessedObject chainKey))
	(ODK ((doorKey object find-object) (hands free)) (possessedObject doorKey))
	(OCH ((chair object find-object) (hands free)) (possessedObject chair))
	(OGL ((brokenGlass object find-object) (hands free)) (possessedObject brokenGlass))
	(OGB ((glassBottle object find-object) (hands free)) (possessedObject glassBottle))
	(OHA ((hammer object find-object) (hands free)) (possessedObject hammer))
	(OWS ((bigWoodStick object find-object) (hands free)) (possessedObject bigWoodStick))
	(OCA ((camera object find-object) (hands free)) (possessedObject camera))
;;  Récupérer le haut parleur accroché au plafond
	(OSP ((hands free) (((personHeight 0.9 *) (personHeight 3 /) +) roomHeight >=)) (possessedObject camera))
;;  Casser des objets
	(BCH ((chair possessedObject find-object)) (possessedObject bigWoodStick))
	(BGB ((glassBottle possessedObject find-object)) (possessedObject brokenGlass))
	(BCA ((camera possessedObject find-object)) (possessedObject brokenGlass))
;;  Casser ses liens
	(UKN ((personStrength 3 >=) (linkMaterial twine)) (hands free))
	(UKN ((personStrength 4 >=) (linkMaterial belt)) (hands free))
	(UKN ((knife possessedObject find-object) (linkMaterial twine)) (hands free))
	(UKN ((knife possessedObject find-object) (linkMaterial belt)) (hands free))
	(UKN ((knife possessedObject find-object) (linkMaterial plasticClamp)) (hands free))
	(UKN ((knife possessedObject find-object) (linkMaterial climbingRope) (personStrength 3 >=)) (hands free))
	(UKN ((brokenGlass possessedObject find-object) (linkMaterial twine)) (hands free))
;; Crocheter ses liens
	(UTW ((chainKey possessedObject find-object) (linkMaterial rustySteelChains)) (hands free))
	(UTW ((chainKey possessedObject find-object) (linkMaterial steelChains)) (hands free))
;;  Casser la porte
	(DPLCA ((hands free) (doorMaterial glass) (personStrength 2 >=)) (door open))
	(DPLCA ((hands free) (doorMaterial chipBoard) (personStrength 3 >=)) (door open))
	(DPLCA ((hands free) (doorMaterial plastic) (personStrength 4 =)) (door open))
	(DGLCA ((hands free) (camera possessedObject find-object) (doorMaterial glass) (personStrength 2 >=)) (door open))
	(DCBCA ((hands free) (camera possessedObject find-object) (doorMaterial chipBoard) (personStrength 3 >=)) (door open))
	(DPLCA ((hands free) (bigWoodStick possessedObject find-object) (doorMaterial glass)) (door open))
	(DPLCA ((hands free) (bigWoodStick possessedObject find-object) (doorMaterial chipBoard)) (door open))
	(DPLCA ((hands free) (bigWoodStick possessedObject find-object) (doorMaterial plastic) (personStrength 2 >=)) (door open))
	(DPLCA ((hands free) (hammer possessedObject find-object) (doorMaterial glass)) (door open))
	(DPLCA ((hands free) (hammer possessedObject find-object) (doorMaterial chipBoard)) (door open))
	(DPLCA ((hands free) (hammer possessedObject find-object) (doorMaterial plastic)) (door open))
	(DPLCA ((hands free) (hammer possessedObject find-object) (doorMaterial rawWood) (personStrength 3 >=)) (door open))
	(DPLCA ((hands free) (axe possessedObject find-object) (doorMaterial glass)) (door open))
	(DPLCA ((hands free) (axe possessedObject find-object) (doorMaterial chipBoard)) (door open))
	(DPLCA ((hands free) (axe possessedObject find-object) (doorMaterial plastic)) (door open))
	(DPLCA ((hands free) (axe possessedObject find-object) (doorMaterial rawWood) (personStrength 2 >=)) (door open))
;; Crocheter la porte
	(DCRKN ((hands free) (knife possessedObject find-object) (personLockPicking 2 >=)) (door open))
	(OS42 ((doorKey possessedObject find-object)) (door open))
;;  Sortir de la salle et gagner
	(WIN ((door open)) (you escaped))
))