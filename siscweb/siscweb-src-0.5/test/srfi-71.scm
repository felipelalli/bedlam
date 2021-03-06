; Examples for SRFI-71.
; Sebastian.Egner@philips.com, 1-Aug-2005, R5RS + SRFI-71.
;
; PLT 208:
;   (load "letvalues-plt.scm")
;   (require (lib "pretty.ss"))
;   (define pretty-write pretty-print)
;
; Scheme 48 1.2:
;   ,load letvalues-r5rs.scm
;   ,open pp
;   (define pretty-write p)
;
; Generic R5RS:
;(load "letvalues-r5rs.scm")

; Changes:
; Alessandro Colomba, Feb 2007
;    * minor changes for SISC (module, renames)

; SISC
(require-library 'util/srfi-71)

(module test/srfi-71
  (#|test-srfi-71|#) ; TODO: turn into a real module

  (import util/srfi-71)

  (define pretty-write write)

  ; --- a simple test engine ---

  (define my-equal?       equal?)
  (define my-pretty-write pretty-write)

  (define my-check-correct 0)
  (define my-check-wrong   0)

  (define (my-check-reset)
    (set! my-check-correct 0)
    (set! my-check-wrong   0))

  ; (my-check expr => desired-result)
  ;   evaluates expr and compares the value with desired-result.

  (define-syntax my-check
    (syntax-rules (=>)
      ((my-check expr => desired-result)
       (my-check-proc 'expr (lambda () expr) desired-result))))

  (define (my-check-proc expr thunk desired-result)
    (newline)
    (my-pretty-write expr)
    (display "  => ")
    (my-let ((actual-result (thunk)))
            (write actual-result)
            (if (my-equal? actual-result desired-result)
                (begin
                  (display " ; correct")
                  (set! my-check-correct (+ my-check-correct 1)) )
                (begin
                  (display " ; *** wrong ***, desired result:")
                  (newline)
                  (display "  => ")
                  (write desired-result)
                  (set! my-check-wrong (+ my-check-wrong 1))))
            (newline)))

  (define (my-check-summary)
    (begin
      (newline)
      (newline)
      (display "*** correct examples: ")
      (display my-check-correct)
      (newline)
      (display "*** wrong examples:   ")
      (display my-check-wrong)
      (newline)
      (newline)))

  (my-check-reset)

  ; --- test cases for unnamed let ---

  ; form2 with one value (i.e. ordinary let)
  (my-check (my-let () 1) => 1)
  (my-check (my-let ((x1 1)) x1) => 1)
  (my-check (my-let ((x1 1) (y1 2)) (list x1 y1)) => '(1 2))

  ; form2 with two
  (my-check (my-let ((x1 x2 (values 1 2))) (list x1 x2)) => '(1 2))
  (my-check (my-let ((x1 x2 x3 (values 1 2 3))) (list x1 x2 x3)) => '(1 2 3))

  ; form1 without rest arg
  (my-check (my-let (((values) (values))) 1) => 1)
  (my-check (my-let (((values x1) (values 1))) x1) => 1)
  (my-check (my-let (((values x1 x2) (values 1 2))) (list x1 x2)) => '(1 2))
  (my-check (my-let (((values x1 x2 x3) (values 1 2 3))) (list x1 x2 x3)) => '(1 2 3))

  ; form1 with rest arg only
  (my-check (my-let (((values . x0+) (values))) x0+) => '())
  (my-check (my-let (((values . x0+) (values 1))) x0+) => '(1))
  (my-check (my-let (((values . x0+) (values 1 2))) x0+) => '(1 2))
  (my-check (my-let (((values . x0+) (values 1 2 3))) x0+) => '(1 2 3))

  ; form1 with one and rest arg
  (my-check (my-let (((values x1 . x1+) (values 1))) (cons x1 x1+)) => '(1))
  (my-check (my-let (((values x1 . x1+) (values 1 2))) (cons x1 x1+)) => '(1 2))
  (my-check (my-let (((values x1 . x1+) (values 1 2 3))) (cons x1 x1+)) => '(1 2 3))

  ; form1 with two and rest arg
  (my-check (my-let (((values x1 x2 . x2+) (values 1 2)))
                    (cons x1 (cons x2 x2+)))
            => '(1 2))
  (my-check (my-let (((values x1 x2 . x2+) (values 1 2 3)))
                    (cons x1 (cons x2 x2+)))
            => '(1 2 3))

  ; --- test cases for named let ---

  ; ordinary form
  (my-check (my-let loop ((x 1)) (if (zero? x) x (loop (- x 1)))) => 0)

  ; using (values x)
  (my-check (my-let loop (((values x) 1)) (if (zero? x) x (loop (- x 1)))) => 0)

  ; --- test cases for let* ---

  ; We assume that let* is defined in terms of let but check
  ; if the scopes are correct.

  ; simple let
  (my-check (my-let* () 1) => 1)
  (my-check (my-let* ((x1 1)) x1) => 1)
  (my-check (my-let* (((values x1 x2 . x2+) (values 1 2 3)))
                     (cons x1 (cons x2 x2+)))
            => '(1 2 3))

  ; nested let
  (my-check (my-let* ((x1 1) (y1 x1)) (list x1 y1)) => '(1 1))
  (my-check (my-let* (((values x1 x2 . x2+) (values 1 2 3))
                      ((values y1 y2 . y2+) (apply values x1 x2 x2+)))
                     (list
                      (cons x1 (cons x2 x2+))
                      (cons y1 (cons y2 y2+))))
            => '((1 2 3) (1 2 3)))

  ; --- test cases for letrec ---

  ; original letrec
  (my-check (my-letrec () 1) => 1)
  (my-check (my-letrec ((x 1)) x) => 1)
  (my-check (my-letrec ((x 1) (y 2)) (list x y)) => '(1 2))
  (my-check (my-letrec ((x (lambda () (y))) (y (lambda () 1))) (x)) => 1)

  ; too few test cases...
  (my-check (my-letrec ((x y (values (lambda () (y))
                                     (lambda () 1))))
                       (x))
            => 1)

  ; --- nasty things ---

  (my-check (my-let ((values 1)) values) => 1)

  (my-check (my-let (((values values) 1)) values) => 1)

  (my-check (my-let (((values bad values) (values 1 2)))
                    (list bad values))
            => '(1 2))

  ; --- values->list etc. ---

  (my-check (values->list (values)) => '())
  (my-check (values->list (values 1)) => '(1))
  (my-check (values->list (values 1 2)) => '(1 2))
  (my-check (values->list (values 1 2 3)) => '(1 2 3))

  (my-check (values->vector (values)) => '#())
  (my-check (values->vector (values 1)) => '#(1))
  (my-check (values->vector (values 1 2)) => '#(1 2))
  (my-check (values->vector (values 1 2 3)) => '#(1 2 3))

  ; --- uncons etc. ---

  (my-check (values->vector (uncons   '(1 2 3 4 5))) => '#(1 (2  3  4  5)))
  (my-check (values->vector (uncons-2 '(1 2 3 4 5))) => '#(1  2 (3  4  5)))
  (my-check (values->vector (uncons-3 '(1 2 3 4 5))) => '#(1  2  3 (4  5)))
  (my-check (values->vector (uncons-4 '(1 2 3 4 5))) => '#(1  2  3  4 (5)))

  (my-check (values->vector (uncons-cons '((1 2) 3))) => '#(1 (2) (3)))

  (my-check (values->vector (unlist '(1 2 3))) => '#(1 2 3))
  (my-check (values->vector (unvector '#(1 2 3))) => '#(1 2 3))

  ; --- quo-rem ---

  (define (quo-rem x y)
    (values (quotient x y) (remainder x y))) ; could be computed together

  (my-check (my-let ((q r (quo-rem 13203 42)))
                    (list q r))
            => '(314 15))

  ; --- quicksort (i.e. splitting a list) ---

  (define (naive-quicksort xs)
    (define (split pivot lt eq gt xs)
      (if (null? xs)
          (values lt eq gt)
          (my-let ((x xr (uncons xs)))
                  (cond
                   ((< x pivot) (split pivot (cons x lt) eq gt xr))
                   ((= x pivot) (split pivot lt (cons x eq) gt xr))
                   (else        (split pivot lt eq (cons x gt) xr))))))
    (if (null? xs)
        '()
        (my-let* ((pivot xr (uncons xs)) ; naive
                  (lt eq gt (split pivot () (list pivot) () xr)))
                 (append (naive-quicksort lt)
                         eq
                         (naive-quicksort gt)))))

  (my-check (naive-quicksort '(3 1 4 1 5 9 2))
            => '(1 1 2 3 4 5 9))

  ; --- functional double-ended queue (deque) ---

  ; A deque q = [q[0] .. q[|q|-1]] is represented
  ; by a pair (f . r) of lists such that
  ;   q = [f[0] .. f[|f|-1] r[|r|-1] .. r[0]],
  ; maintaining the invariant
  ;   |f| * |r| = 0 implies |f| + |r| <= 1.

  (define deque:make   cons) ; should be a record-type
  (define deque:unmake uncons)

  (define (list->deque q)
    (my-let split ((n (quotient (length q) 2)) (rev-f '()) (rev-r q))
            (if (zero? n)
                (deque:make (reverse rev-f) (reverse rev-r))
                (split (- n 1) (cons (car rev-r) rev-f) (cdr rev-r)))))

  (define (reverse-list->deque rev-q)
    (my-let split ((n (quotient (length rev-q) 2)) (rev-f rev-q) (rev-r '()))
            (if (zero? n)
                (deque:make (reverse rev-f) (reverse rev-r))
                (split (- n 1) (cdr rev-f) (cons (car rev-f) rev-r)))))

  (define deque-empty (deque:make '() '()))

  (define (deque-empty? q) ; |q| = 0
    (my-let ((f r (deque:unmake q)))
            (and (null? f) (null? r))))

  (define (deque-cons x q) ; [x q[0] .. q[|q|-1]]
    (my-let ((f r (deque:unmake q)))
            (if (and (not (null? f)) (null? r))
                (list->deque (cons x f))
                (deque:make (cons x f) r))))

  (define (deque-snoc q x) ; [q[0] .. q[|q|-1] x]
    (my-let ((f r (deque:unmake q)))
            (if (and (null? f) (not (null? r)))
                (reverse-list->deque (cons x r))
                (deque:make f (cons x r)))))

  (define (deque-uncons q) ; q[0] q[1..|q|-1]
    (my-let* ((f r (deque:unmake q))
              (f0 f1+ (uncons f)))
             (values f0
                     (if (null? f1+)
                         (reverse-list->deque r)
                         (deque:make f1+ r)))))

  (define (deque-unsnoc q) ; q[0..|q|-2] q[|q|-1]
    (my-let* ((f r (deque:unmake q))
              (r0 r1+ (uncons r)))
             (values (if (null? r1+)
                         (list->deque f)
                         (deque:make f r1+))
                     r0)))

  (define (deque->list q) ; for illustration, (append f (reverse r))
    (my-let loop ((q q) (xs '()))
            (if (deque-empty? q)
                xs
                (my-let ((q x (deque-unsnoc q)))
                        (loop q (cons x xs))))))

  (define (deque:example n)
    (my-let ((q deque-empty))
            (do ((i 1 (+ i 1))) ((> i n) (deque->list q))
                (set! q (deque-cons (- i) (deque-snoc q i))))))

  (my-check (deque:example 4)
            => '(-4 -3 -2 -1 1 2 3 4))

  ; --- report ---

  (my-check-summary)
)
