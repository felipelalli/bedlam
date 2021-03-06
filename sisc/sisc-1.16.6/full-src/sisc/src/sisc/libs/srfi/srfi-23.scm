(module _srfi-23 (_error)
  (define _error error))
(module srfi-23 (error)
  (import _srfi-23)
  (define (error msg . args)
    (if (null? args)
        (_error msg)
        (_error (string-append msg ": ~a") (apply list args))))
  (add-feature 'srfi-23))
