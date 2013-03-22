;; chickenwrap - modify i3bar's input with custom CHICKEN-code
;; © 2013, Axel Wagner <mail+chickenwrap@merovius.de>
;; See LICENSE for details and README.md for usage

(use medea)
(use miscmacros)
(use environments)

;; First we define an execution-environment for the transformers
(define load-env (environment-copy (interaction-environment)))

; Define a hook for full-line-transformations
(define line-transformers '())
(define transform-line (lambda (fn)
			 (set! line-transformers (if (eqv? line-transformers '())
						     (list fn)
						     (join (list line-transformers (list fn)))))))
(environment-extend! load-env 'transform-line transform-line #f)


;; Load all transformers in $HOME/.config/chickenwrap
(for-each (lambda (file)
	    (load file (lambda (expr)
			 (eval expr load-env))))
	  (glob (format "~A/.config/chickenwrap/*.scm" (get-environment-variable "HOME"))))


;; We need a few helpers
(define read-statusline (lambda ()
			  (if (char=? (peek-char) #\,)
			      (read-char))
			  (vector->list (read-json (read-line)))))

(define write-statusline (lambda (blocks)
			   (write-json (list->vector blocks))
			   (format #t "~N")))

(define pass-on-first-two-lines (lambda ()
				  (write-line (read-line))
				  (write-line (read-line))
				  #f))

; We throw away the first two lines, the version-information and the inital \#[
(pass-on-first-two-lines)
(while #t
       (let ((line (read-statusline)))
	 (for-each (lambda (fn)
		     (set! line (fn line)))
		   line-transformers)
	 (write-statusline line)))
