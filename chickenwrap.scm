;; chickenwrap - modify i3bar's input with custom CHICKEN-code
;; © 2013, Axel Wagner <mail+chickenwrap@merovius.de>
;; See LICENSE for details and README.md for usage

(use medea)
(use environments)

;; First we define an execution-environment for the transformers
(define load-env (environment-copy (interaction-environment)))

; Define a hook for full-line-transformations
(define line-transformers '())
(define (transform-line fn)
  (set! line-transformers (append line-transformers (list fn))))
(environment-extend! load-env 'transform-line transform-line #f)

; Define a hook for single-block-transformations
(define block-transformers '())


;; Load all transformers in $HOME/.config/chickenwrap
(for-each (lambda (file)
	    (load file (lambda (expr)
			 (eval expr load-env))))
	  (glob (format "~A/.config/chickenwrap/*.scm" (get-environment-variable "HOME"))))


;; Reconfigure medea to use lists for arrays and hashtables for objects
(alist-update! 'array identity (json-parsers)) ; parse arrays into lists
(alist-update! 'object alist->hash-table (json-parsers)) ; parse objects into hash-tables

(let ((json-unparse-alist (alist-ref list? (json-unparsers))) ; save the alist-unparser
      (json-unparse-vector (alist-ref vector? (json-unparsers)))) ; and the vector-unparser
  (json-unparsers (alist-update! hash-table? (lambda (h)
					       (json-unparse-alist (hash-table->alist h)))
				 (json-unparsers))) ; convert hash-tables to alists and call the saved unparser
  (json-unparsers (alist-update! list? (lambda (l)
					 (json-unparse-vector (list->vector l)))
				 (json-unparsers)))) ; convert lists to vectors and call the saved unparser
      
;; We need a few helpers
(define read-statusline (lambda ()
			  (if (char=? (peek-char) #\,)
			      (read-char))
			  (read-json (read-line))))

(define write-statusline (lambda (blocks)
			   (write-json blocks)
			   (format #t "~N,")))

(define pass-on-first-two-lines (lambda ()
				  (write-line (read-line))
				  (write-line (read-line))
				  #f))

; We throw away the first two lines, the version-information and the inital \#[
(pass-on-first-two-lines)
(let loop ()
  (let ((line (read-statusline)))
    (for-each (lambda (fn)
		(set! line (fn line)))
	      line-transformers)
    (write-statusline line)
    (loop)))
