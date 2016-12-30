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
;;      - objects
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
;;      - door є {locked, open}
;;      - doorMaterial є {rawWood, chipBoard, metal, glass, plastic}
;;                       (bois brut, aggloméré, verre, plastique)
;;      - linkMaterial є {climbingRope, rustySteelChains, steelChains, twine, belt, plasticClamp}
;;                       (corde d'escalade, chaines rouillées, chaines inox, ficelle, ceinture, serrage plastique)
;;      - (cadr object) є {knife, axe, tensionWrench, pick, chainKey, doorKey, chair, speaker, camera, brokenGlass, glassBottle, hammer, bigWoodStick}
;;                        (couteau, hache, tendeur, piquet, clé chaines, clé porte, chaise, haut Parleur, caméra, morceau de verre, bouteille de verre, marteau, gros morceau de bois)
;;      - (caddr object) є [0, roomSize/2]

;; Ordre de priorité :
;;      - Se détacher les mains
;;      - Ouvrir la porte
;;      - Sortir de la salle

;; Initialisation :
;;      - vérification des données et demande des données nécessaires
;;      - personLegSize = personHeight*0.525
;;      - objectDistance = (caddr object)
;;      - linkBreakingStrengh = personLockPicking + personStrength + max(max(objectLinkLockPicking, objectLockPicking), objectStrength)
;;      - doorOpeningStrength = max(personLockPicking + max(objectLinkLockPicking, objectDoorPicking), personStrengh + objectStrength)

;; Règles (caddr = function to apply. Si = nil, equal)
;;      Récupérer un objet
;;      - (object knife) && ((personLegSize >= knifeDistance) || (hands free)) => (possessedObject knife)
;;      - (object axe) && ((personLegSize >= axeDistance) || (hands free)) => (possessedObject axe)
;;      - (object tensionWrench) && ((personLegSize >= tensionWrenchDistance) || (hands free)) => (possessedObject tensionWrench)
;;      - (object pick) && ((personLegSize >= pickDistance) || (hands free)) => (possessedObject pick)
;;      - (object chainKey) && ((personLegSize >= chainKeyDistance) || (hands free)) => (possessedObject chainKey)
;;      - (object doorKey) && ((personLegSize >= doorKeyDistance) || (hands free)) => (possessedObject doorKey)
;;      - (object chair) && ((personLegSize >= chairDistance) || (hands free)) => (possessedObject chair)
;;      - (object brokenGlass) && ((personLegSize >= brokenGlassDistance) || (hands free)) => (possessedObject brokenGlass)
;;      - (object glassBottle) && ((personLegSize >= glassBottleDistance) || (hands free)) => (possessedObject glassBottle)
;;      - (object hammer) && ((personLegSize >= hammerDistance) || (hands free)) => (possessedObject hammer)
;;      - (object bigWoodStick) && ((personLegSize >= bigWoodStickDistance) || (hands free)) => (possessedObject bigWoodStick)
;;      Casser des objets
;;      - (possessedObject chair) => (possessedObject bigWoodStick)
;;      - (possessedObject glassBottle) => (possessedObject brokenGlass)
;;      - (possessedObject camera) => (possessedObject brokenGlass)
;;      Utiliser des objets
;;      - (possessedObject camera) => (objectStrength 1)
;;      - (possessedObject knife) => (objectStrength 2)
;;      - (possessedObject bigWoodStick) => (objectStrength 3)
;;      - (possessedObject axe) => (objectStrength 4)
;;      - (possessedObject hammer) => (objectStrength 5)
;;      - (possessedObject tensionWrench) => (objectLockPicking 2)
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
(setq *FB*
    '(
        (personHeight 177)
        (personStrength 2)
        (personLockPicking 1)
        (roomHeight 250)
        (door locked)
        (doorMaterial metal)
        (linkMaterial rustySteelChains)
        (objects
            (knife 20)
            (glassBottle 250)
            (pick 200)
            (tensionWrench 150)
        )
    )
)

;; Représentation de la Base de Règles (Rule Base)

(setq *RB* '(
;;  Récupérer un objet
	(R0 (((object knife) ((personLegSize knifeDistance >=) (hands free) or)) (possessedObject knife))
	(R1 (((object axe) ((personLegSize axeDistance >=) (hands free) or)) (possessedObject axe))
	(R2 (((object tensionWrench) ((personLegSize tensionWrenchDistance >=) (hands free) or)) (possessedObject tensionWrench))
	(R3 (((object pick) ((personLegSize pickDistance >=) (hands free) or)) (possessedObject pick))
	(R4 (((object chainKey) ((personLegSize chainKeyDistance >=) (hands free) or)) (possessedObject chainKey))
	(R5 (((object doorKey) ((personLegSize doorKeyDistance >=) (hands free) or)) (possessedObject doorKey))
	(R6 (((object chair) ((personLegSize chairDistance >=) (hands free) or)) (possessedObject chair))
	(R7 (((object brokenGlass) ((personLegSize brokenGlassDistance >=) (hands free) or)) (possessedObject brokenGlass))
	(R8 (((object glassBottle) ((personLegSize glassBottleDistance >=) (hands free) or)) (possessedObject glassBottle))
	(R9 (((object hammer) ((personLegSize hammerDistance >=) (hands free) or)) (possessedObject hammer))
	(R10 (((object bigWoodStick) ((personLegSize bigWoodStickDistance >=) (hands free) or)) (possessedObject bigWoodStick))
;;  Récupérer le haut parleur accroché au plafond
	(R11 (((hands free) ((((personHeight 0.9 *) (/ personHeight 3) +) roomHeight >=) (hands free) or)) (possessedObject bigWoodStick))
;;  Casser des objets
	(R12 ((possessedObject chair) (possessedObject bigWoodStick))
	(R13 ((possessedObject glassBottle) (possessedObject brokenGlass))
	(R14 ((possessedObject camera) (possessedObject brokenGlass))
;;  Utiliser des objets
	(R15 ((possessedObject camera) (objectStrength 1))
	(R16 ((possessedObject knife) (objectStrength 2))
	(R17 ((possessedObject bigWoodStick) (objectStrength 3))
	(R18 ((possessedObject axe) (objectStrength 4))
	(R19 ((possessedObject hammer) (objectStrength 5))
	(R20 ((possessedObject tensionWrench) (objectLockPicking 2))
	(R21 ((possessedObject pick) (objectLockPicking 2))
	(R22 ((possessedObject brokenGlass) (objectLockPicking 1))
	(R23 (((possessedObject chainKey) ((linkMaterial rustySteelChains) (linkMaterial steelChains) or)) (objectLinkLockPicking 42))
	(R24 ((possessedObject doorKey) (objectDoorLockPicking 42))
;;  Casser ses liens
	(R25 ((linkMaterial twine) (linkHardness 1))
	(R26 ((linkMaterial belt) (linkHardness 2))
	(R27 ((linkMaterial plasticClamp) (linkHardness 3))
	(R28 ((linkMaterial climbingRope) (linkHardness 4))
	(R29 ((linkMaterial rustySteelChains) (linkHardness 5))
	(R30 ((linkMaterial steelChains) (linkHardness 6))
	(R31 ((linkBreakingStrengh linkHardness >=) (hands free))
;;  Ouvrir la porte
	(R32 ((doorMaterial glass) (doorHardness 3))
	(R33 ((doorMaterial chipBoard) (doorHardness 4))
	(R34 ((doorMaterial plastic) (doorHardness 5))
	(R35 ((doorMaterial rawWood) (doorHardness 6))
	(R36 ((doorMaterial metal) (doorHardness 7))
	(R37 ((doorOpeningStrength doorHardness >=) (door open))
;;  Sortir de la salle et gagner
	(R38 ((door open) (you escaped))
))