(load "TP3 - Definition precise des regles et des faits.cl")

;; Algo :
;	function check(goal)
;		done := FB.contains(goal)
;		for rule in candidate-rules(goal) and while not done
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

(setq *currentPath* nil)

(defun assoc-multi (element alist)
	(let (result)
		(setq result
			(remove nil
				(mapcar #'(lambda (elmt)
					(when (equal (first elmt) element)
						elmt
					)
				) alist)
			)
		)
		(if (equal (list-length result) 1)
			(car result)
			result
		)
	)
)

(defun find-object (object objects)
	(if (find-if #'listp objects)
		(find object objects :key #'cadr)
		(find object objects)
	)
)

(defun tab (depth)
  (dotimes (i depth) (format t "    "))
)

(defun ruleName (rule)
	rule
)

;Règles candidates
(defun candidate-rules (goal)
    (let ((result nil) candidateName)
		(if (equal (second goal) 'possessedObject)
			(setq candidateName (list (second goal) (first goal)))
			(setq candidateName (list (first goal) (second goal)))
		)
        (dolist (currentRule *RB*)
            (when (equal candidateName (conclusion currentRule))
				;;(format t "Current Rules ~s~%" currentRule)
                (push currentRule result)
            )
        )
        result
    )
)

; Returns the conditions of a rule
(defun conditions (rule)
	(cadr rule)
)

; Returns the conclusion of a rule
(defun conclusion (rule)
	(caddr rule)
)


; Evaluates a condition
(defun eval-condition (condition &optional (depth 0))
	(tab depth)
    (if (numeric-condition condition)
        (eval-numeric condition)
        (eval-fact condition)
    )
)


; Returns true if rule is numeric condition, NIL otherwise
(defun numeric-condition (condition)
    (third condition)
)


; Return the value of a numeric condition by doing its operation
(defun eval-numeric (condition)
	;(format t "condition de eval-numeric ~s~%" condition)

	(cond 
		((equal (first condition) t)
			;(format t "res t = ~s~%" (eval (list (third condition) (first condition) (second condition))))
		)
		((or (equal (second condition) 'object) (equal (second condition) 'possessedObject))
			;(format t "(apply ~s (~s ~s))" (third condition) (first condition) (assoc-multi (second condition) *FB*))
			;(format t "res list = ~s~%" (apply (third condition) (list (first condition) (assoc-multi (second condition) *FB*))))
		)
		((assoc-multi (first condition) *FB*)
			;(format t "res atom = ~s~%" (eval (list (third condition) (second (assoc-multi (first condition) *FB*)) (second condition))))
		)
		(t
			;(format t "res nil = ~s~%" nil)
		)
	)

	(cond 
		((equal (first condition) t)
        	(eval (list (third condition) (first condition) (second condition)))
		)
		((or (equal (second condition) 'object) (equal (second condition) 'possessedObject))
			(apply (third condition) (list (first condition) (assoc-multi (second condition) *FB*)))
		)
		((assoc-multi (first condition) *FB*)
        	(eval (list (third condition) (second (assoc-multi (first condition) *FB*)) (second condition)))
		)
		(t
			nil
		)
	)
)


; Return the value of a condition by checking wether a fact is in the factbase or not
(defun eval-fact (condition)
	;(format t "condition de eval-fact ~s~%" condition)
	;(format t "res fact = ~s~%" (equal (second (assoc-multi (first condition) *FB*)) (second condition)))
    (equal (second (assoc-multi (first condition) *FB*)) (second condition))
)


;;Moteur

;Fonction escape
(defun escape ()
	(let ((personHeight (second (assoc-multi 'personHeight *FB*))))
		(if personHeight
			(setq personLegSize (* 0.525 personHeight))
			(loop while (not (numberp personHeight))
				do (progn
					(format t "Veuillez indiquer la taille de la personne captive.~%")
					(setq personHeight (read))
				)
			)
		)
	)
	;(when (check '(hands free))
	;	(when (check '(door open))
			(check '(you escaped))
	;	)
	;)
)

;Fonction check
(defun check (goal)
	(let ((done (eval-condition goal)))
		;(format t "Goal = ~s~%" goal)
		(when (not done)
			;; If done is false
			(loop for rule in (candidate-rules goal)
			    while (not done)
			    do
				(unless (find rule *currentPath*)
					(push rule *currentPath*)
					(setq done (check_and rule))
				)
			)
		)
		done
	)
)

;Fonction check_and
(defun check_and (rule)
	(let ((ok T))
		(when ok
			;; If ok is true
			(loop for c in (conditions rule)
			    while ok
			    do (setq ok (check c))
			)
		)
		(when ok
			(unless (find (conclusion rule) *FB* :test #'equal)
				(format t "[DONE] ~s~%" rule)
				(push (conclusion rule) *FB*)
			)
		)
		;(unless ok
		;	(format t "oooooooooooooh ~s is not ok~%" rule)
		;)
		ok
	)
)