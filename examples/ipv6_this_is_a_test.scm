(transform-line (lambda (line)
                  (for-each (lambda (block)
                              (if (and
				   (hash-table-exists? block 'name)
				   (string? (hash-table-ref block 'name))
				   (string=? (hash-table-ref block 'name) "ipv6"))
				  (hash-table-set! block 'full_text "DIES IST EIN TEST")))
                            line)
                  line))
