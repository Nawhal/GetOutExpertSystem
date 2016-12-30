(load "TP3 - Définition précise des règles et des faits.cl")

;; Algo :
;	function check(goal)
;		done := FB.contains(goal)
;		for rule in candidateRules(goal) and while not done
;			done := check_and(rule)
;		end
;		done
;	end
;;
;	function check_and(rule)
;		ok := true
;		for p in previous(rule) and ok
;			ok := check(p)
;		end
;		ok
;	end




;;Fonctions de service

;Règles candidates
(defun candidateRules (rule)

)

(defun previous (rule)

)


;;Moteur

;Fonction check
(defun check (goal)
	(let ((done (find goal *FB*)))
		(if (not done)
			;; If done is false
			(dolist (rule (candidateRules goal) done)
				(setq done (check_and(rule)))
				(if done (return) nil)
			)
			;; If done is true
			done
		)
		done
		)
)

;Fonction check_and
(defun check_and (rule)
	(let ((ok T))
		(if (ok)
			;; If ok is true
			(dolist (p previous(rule) ok)
				(setq ok (check(p)))
				(if (not ok) (return) nil)
			)
			;; If ok is false
			done
		)
	done
	)
)
