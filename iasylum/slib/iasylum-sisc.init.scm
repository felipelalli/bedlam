;;; "sisc.init" Initialization for SLIB for SISC-1.16.6 -*-scheme-*-
;;; Author: matthias@sorted.org (Matthias Radestock)
;;;
;;; Based on:
;;; "Template.scm" configuration template of *features* for Scheme
;;; Author: Aubrey Jaffer
;;;
;;; This code is in the public domain.

;;;TODO:
;;; * implement |system|

;;;;import vicinity support
;;(require-extension (srfi 59))

;;; srfi-59
(define (program-vicinity)
  (current-directory))

(define library-vicinity
  (let ((lib-path
	 (string-append
	  (or
              (string-append (iasylum-bedlam-location-parameter) "iasylum/slib/3b2")
              (getenv "sisc.slib")
	      (getenv "sisc.lib")
	      (error "You must define the sisc.slib or sisc.lib property"))
	  "/")))
    (lambda () lib-path)))

(define implementation-vicinity
  (let ((impl-path
	 (string-append         
	  (or
              (string-append (iasylum-bedlam-location-parameter) "iasylum/slib/implementation-vicinity/")
              (getenv "sisc.home")
	      (error "You must define the sisc.home property"))
	  "/")))
    (lambda () impl-path)))

(define (user-vicinity) "")

(define (home-vicinity)
  (string-append
   (or (getenv "user.home")
       (error "You must define the user.home property"))
   "/"))

(define in-vicinity normalize-url)

(define (sub-vicinity vicinity name)
  (string-append vicinity name "/"))

(define (make-vicinity pathname) pathname)

(define (pathname->vicinity pathname)
  (let loop ((i (- (string-length pathname) 1)))
    (cond ((negative? i) "")
	  ((vicinity:suffix? (string-ref pathname i))
	   (substring pathname 0 (+ i 1)))
	  (else (loop (- i 1))))))

(define (vicinity:suffix? chr)
  (eqv? chr #\/))
;;; end srfi-59

;;@ (software-type) should be set to the generic operating system type.
;;; UNIX, VMS, MACOS, AMIGA and MS-DOS are supported.
(define (software-type)
  (define (string-starts-with-ci? s1 s2)
    (let ([l (string-length s2)])
      (and (not (< (string-length s1) l))
           (string-ci=? (substring s1 0 l) s2))))
  (let ([osn (getenv "os.name")])
    (cond [(string-starts-with-ci? osn "win") 'ms-dos]
          [(string-starts-with-ci? osn "mac") 'macos]
          [(string-starts-with-ci? osn "os/2") 'os2]
          [(string-starts-with-ci? osn "openvms") 'vms]
          [(string-starts-with-ci? osn "vax") 'vax]
          [else 'unix])))

;;@ (scheme-implementation-type) should return the name of the scheme
;;; implementation loading this file.
(define (scheme-implementation-type) 'sisc)

;;@ (scheme-implementation-home-page) should return a (string) URI
;;; (Uniform Resource Identifier) for this scheme implementation's home
;;; page; or false if there isn't one.
(define (scheme-implementation-home-page)
  "http://sisc.sourceforge.net/")

;;@ (scheme-implementation-version) should return a string describing
;;; the version the scheme implementation loading this file.
(define (scheme-implementation-version)
  (getprop 'version (get-symbolic-environment '*sisc*)))

;@
(define (with-load-pathname path thunk)
  (parameterize
   ([current-url path])
   (thunk)))

;;@ SLIB:FEATURES is a list of symbols naming the (SLIB) features
;;; initially supported by this implementation.
(define slib:features
  '(
    source				;can load scheme source files
					;(SLIB:LOAD-SOURCE "filename")
;;;	compiled			;can load compiled files
					;(SLIB:LOAD-COMPILED "filename")
    vicinity
    srfi-59
    srfi-96

	       ;;; Scheme report features
    ;; R5RS-compliant implementations should provide all 9 features.
    r5rs				;conforms to
    eval				;R5RS two-argument eval
    values				;R5RS multiple values
    dynamic-wind			;R5RS dynamic-wind
    macro				;R5RS high level macros
    delay				;has DELAY and FORCE
    multiarg-apply		     ;APPLY can take more than 2 args.
    char-ready?
    rev4-optional-procedures		;LIST-TAIL, STRING-COPY,
					;STRING-FILL!, and VECTOR-FILL!

    ;; These four features are optional in both R4RS and R5RS
    multiarg/and-		   ;/ and - can take more than 2 args.
    rationalize
    transcript			     ;TRANSCRIPT-ON and TRANSCRIPT-OFF
    with-file				;has WITH-INPUT-FROM-FILE and
					;WITH-OUTPUT-TO-FILE

    r4rs				;conforms to
    ieee-p1178				;conforms to
    r3rs				;conforms to
;;;	rev2-procedures			;SUBSTRING-MOVE-LEFT!,
					;SUBSTRING-MOVE-RIGHT!,
					;SUBSTRING-FILL!,
					;STRING-NULL?, APPEND!, 1+,
					;-1+, <?, <=?, =?, >?, >=?

    object-hash				;has OBJECT-HASH

    full-continuation			;can return multiple times
    ieee-floating-point		   ;conforms to IEEE Standard 754-1985
					;IEEE Standard for Binary
					;Floating-Point Arithmetic.

		;;; Other common features

    srfi-0			 ;srfi-0, COND-EXPAND finds all srfi-*
;;;	sicp				;runs code from Structure and
					;Interpretation of Computer
					;Programs by Abelson and Sussman.
    defmacro				;has Common Lisp DEFMACRO
    record			     ;has user defined data structures
    string-port			       ;has CALL-WITH-INPUT-STRING and
					;CALL-WITH-OUTPUT-STRING
;;;	sort
    pretty-print
;;;	object->string
;;;	format				;Common-lisp output formatting
;;;	trace				;has macros: TRACE and UNTRACE
;;;	compiler			;has (COMPILER)
;;;	ed				;(ED) is editor
;;;	system				;posix (system <string>)
;;;	getenv				;posix (getenv <string>)
;;;	program-arguments		;returns list of strings (argv)
    current-time	       ;returns time in seconds since 1/1/1970

    line-i/o
	  ;;; Implementation Specific features
    ))

;;; import SISC record support, to stop SLIB using its own
(import record)

(import string-io)

;;@
(define (current-time) (quotient (system-time) 1000))
;;@
(define object-hash hash-code)

;;@ (FILE-POSITION <port> . <k>)
(define (file-position . args) #f)

;;@ (OUTPUT-PORT-WIDTH <port>)
(define (output-port-width . arg)
  (let ((env-width-string (getenv "COLUMNS")))
    (if (and env-width-string
             (let loop ((remaining (string-length env-width-string)))
               (or (zero? remaining)
                   (let ((next (- remaining 1)))
                     (and (char-numeric? (string-ref env-width-string
                                                     next))
                          (loop next))))))
        (- (string->number env-width-string) 1)
        79)))

;;@ (OUTPUT-PORT-HEIGHT <port>)
(define (output-port-height . arg)
  (let ((env-height-string (getenv "LINES")))
    (if (and env-height-string
             (let loop ((remaining (string-length env-height-string)))
               (or (zero? remaining)
                   (let ((next (- remaining 1)))
                     (and (char-numeric? (string-ref env-height-string
                                                     next))
                          (loop next))))))
        (string->number env-height-string)
        24)))

;;@ (CURRENT-ERROR-PORT)
(define current-error-port
  (let ((port (current-output-port)))
    (lambda () port)))

;;@ (TMPNAM) makes a temporary file name.
(define tmpnam
  (let ((cntr 100))
    (lambda ()
      (set! cntr (+ 1 cntr))
      (let ((tmp (string-append "slib_" (number->string cntr))))
    (if (file-exists? tmp) (tmpnam) tmp)))))

;;@ (FILE-EXISTS? <string>)
;;(define (file-exists? f) #f)

;;@ (DELETE-FILE <string>)
(define (delete-file f) #f)

;;@ FORCE-OUTPUT flushes any pending output on optional arg output port
;;; use this definition if your system doesn't have such a procedure.
(define force-output flush-output-port)

;;; CALL-WITH-INPUT-STRING and CALL-WITH-OUTPUT-STRING are the string
;;; port versions of CALL-WITH-*PUT-FILE.

;;@ "rationalize" adjunct procedures.
;;(define (find-ratio x e)
;;  (let ((rat (rationalize x e)))
;;    (list (numerator rat) (denominator rat))))
;;(define (find-ratio-between x y)
;;  (find-ratio (/ (+ x y) 2) (/ (- x y) 2)))

;;@ CHAR-CODE-LIMIT is one greater than the largest integer which can
;;; be returned by CHAR->INTEGER.
(define char-code-limit 65536)

;;@ MOST-POSITIVE-FIXNUM is used in modular.scm
(define most-positive-fixnum (- (ashl 1 31) 1))

;;@ Return argument
(define (identity x) x)

;;@ SLIB:EVAL is single argument eval using the top-level (user) environment.
(define slib:eval eval)

;@
(define slib:warn
  (lambda args
    (let ((cep (current-error-port)))
      (if (provided? 'trace) (print-call-stack cep))
      (display "Warn: " cep)
      (for-each (lambda (x) (display #\  cep) (write x cep)) args))))

;;@ define an error procedure for the library
(define (slib:error . args)
  (if (provided? 'trace) (print-call-stack (current-error-port)))
  (let loop ([l args]
             [f ""])
    (if (null? l)
        (apply error f args)
        (loop (cdr l) (string-append f " ~a")))))
;@
(define (make-exchanger obj)
  (lambda (rep) (let ((old obj)) (set! obj rep) old)))
(define (open-file filename modes)
  (case modes
    ((r rb) (open-input-file filename))
    ((w wb) (open-output-file filename))
    (else (slib:error 'open-file 'mode? modes))))
;;;(define (port? obj) (or (input-port? port) (output-port? port)))
(define (call-with-open-ports . ports)
  (define proc (car ports))
  (cond ((procedure? proc) (set! ports (cdr ports)))
    (else (set! ports (reverse ports))
          (set! proc (car ports))
          (set! ports (reverse (cdr ports)))))
  (let ((ans (apply proc ports)))
    (for-each close-port ports)
    ans))
(define (close-port port)
  (cond ((input-port? port)
     (close-input-port port)
     (if (output-port? port) (close-output-port port)))
    ((output-port? port) (close-output-port port))
    (else (slib:error 'close-port 'port? port))))
;@
(define (browse-url url)
  (define (try cmd end) (zero? (system (string-append cmd url end))))
  (or (try "netscape-remote -remote 'openURL(" ")'")
      (try "netscape -remote 'openURL(" ")'")
      (try "netscape '" "'&")
      (try "netscape '" "'")))

;;@ define these as appropriate for your system.
(define slib:tab #\tab)
(define slib:form-feed #\page)

;;@ Support for older versions of Scheme.  Not enough code for its own file.
(define (last-pair l) (if (pair? (cdr l)) (last-pair (cdr l)) l))
(define t #t)
(define nil #f)

;;@ Define these if your implementation's syntax can support it and if
;;; they are not already defined.
(define (1+ n) (+ n 1))
(define (-1+ n) (+ n -1))
(define 1- -1+)

;;@ Define SLIB:EXIT to be the implementation procedure to exit or
;;; return if exiting not supported.
(define slib:exit exit)

;;@ Here for backward compatability
(define scheme-file-suffix
  (let ((suffix (case (software-type)
    	  ((NOSVE) "_scm")
    	  (else ".scm"))))
    (lambda () suffix)))

;;@ (SLIB:LOAD-SOURCE "foo") should load "foo.scm" or with whatever
;;; suffix all the module files in SLIB have.  See feature 'SOURCE.
(define (slib:load-source f) (load (string-append f (scheme-file-suffix))))

;;@ (SLIB:LOAD-COMPILED "foo") should load the file that was produced
;;; by compiling "foo.scm" if this implementation can compile files.
;;; See feature 'COMPILED.
(define slib:load-compiled load)

;;@ At this point SLIB:LOAD must be able to load SLIB files.
(define slib:load slib:load-source)

;;; If your implementation provides R4RS macros:
(define macro:eval slib:eval)
(define macro:load slib:load-source)

;;; If your implementation provides syntax-case macros:
(define syncase:eval slib:eval)
(define syncase:load slib:load-source)

;@
(define gentemp gensym)

;@
(define defmacro:load slib:load-source)

(slib:load (in-vicinity (library-vicinity) "require"))
