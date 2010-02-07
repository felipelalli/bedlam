;;; Code by Igor Hjelmstrom Vinhas Ribeiro - this is licensed under GNU GPL v2.

;(require-extension (lib iasylum/srfi-89))
;(require-extension (lib iasylum/match))

;; TODO - Merge all pumps

(module iasylum/iasylum
  (
   hashtable/values
   nyi
   vunless
   to-string
   display-string
   iasylum-write-string
   d
   w
   beanshell-server
   first-n-or-less
   assert
   alist->http-parameters-string
   run-remote-request
   pump-binary
   pump_binary-input-port->character-output-port   
   r r-split r/s r/d r-base
   dp
   )
  (import hashtable)

  (define hashtable/values
    (lambda (ht)
      (hashtable/map (lambda (k v) v) ht)))

  (define-syntax nyi
    (lambda (x)    
      (syntax-case x ()
        ((_ fname) (syntax (_ fname #t)))
        ((_ fname dummy-value)
         (let* ((symbolic-name (syntax-object->datum (syntax fname)))
                (str-name (symbol->string symbolic-name)))
           (with-syntax ((symbolic-identifier (datum->syntax-object (syntax _) symbolic-name))
                         (str-name (datum->syntax-object (syntax _) str-name)))
             (syntax
              (define symbolic-identifier
                (lambda p
                  (log-debug (string-append "NYI: " str-name " - not yet implemented. Return ") dummy-value)
                  dummy-value)))))))))

  (define-syntax vunless
    (syntax-rules ()
      ((_ test e1 e2 ...)
       (let ((test-value test))
         (if (not test-value)
             (begin e1 e2 ...)
             test-value
             )))))


  
  (define to-string (lambda (f o) (with-output-to-string (lambda () (f o)))))
  
  (define display-string (lambda (o) (to-string display o)))
  
  (define iasylum-write-string (lambda (o) (to-string write o)))

  (define (beanshell-server port)
   (j "bsh.Interpreter i = new bsh.Interpreter();                
       i.set(\"portnum\", port ); i.eval(\"setAccessibility(true)\"); i.eval(\"show()\");
       i.eval(\"server(portnum)\");"
    `((port ,(->jint port)))))
  
  (define (first-n-or-less l n)
    (if (or (eqv? '() l) (= n 0)) '()
        (cons (car l) (first-n-or-less (cdr l) (- n 1)))))
  
  (define (assert v m)
    (unless v (error m)) v)

  (define alist->http-parameters-string
    (lambda (alist)   
      (define me
        (match-lambda
         ;; make sure this also works with regular lists.
         ;; this has to be before to avoid proper lists
         ;; being matched as pairs (which they are).
         (((k   v)  ) (me (list (cons k v))))
         (((k1 v1) . xa) (me `((,k1 . ,v1) . ,xa)))
         
         ;; alist cases.
         (((k .  v)  ) (string-append k "=" v))
         (((k1 . v1) . xa) (string-append k1 "=" v1 "&" (me  xa)))
         ))
      (me alist)))
  

  ;(run-remote-request "www.iasylum.net" 80 test-request "/tmp/tst11.txt")
; (define test-request "GET http://localhost:8080/ HTTP/1.1\nHost: localhost:8080\nUser-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.7) Gecko/2009030822 Gentoo Firefox/3.0.7\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\nAccept-Language: en-us,en;q=0.5\nAccept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\nCache-Control: max-age=0\nConnection: close\n\n")
;;  "GET /\n\n\n"
;  )


  
    ;; (define (pump-binary i o)
    ;;    (let ((a (read-byte i)))
    ;;      (if (eof-object? a) 'done 
    ;;          (begin (write-byte a o) (pump-binary i o)))))
    (define (pump-binary i o)      
      (define mbuffer (make-buffer 65000))
      (import networking) (import binary-io) (import custom-io)
      (define (loop)
        (let ((a (read-block mbuffer 0 (buffer-length mbuffer) i)))
          (if (eof-object? a) 'done 
              (begin (write-block mbuffer 0 a o)  (loop)))))
      (loop))
  
  (define (run-remote-request host port request url)
    (import networking) (import binary-io)  (import custom-io)
    (call-with-binary-output-file
     url
     (lambda (out-f)
       (let* ((socket (open-tcp-socket host port))
              (out (open-socket-output-port       socket "ISO-8859-1" #t))
              (in  (open-binary-socket-input-port socket)))
         (display request out)
         (flush-output-port out)
         (pump-binary in out-f)
         (close-socket socket)
         ))))
  
  (define (pump_binary-input-port->character-output-port i-b o lock)
    (define i (open-character-input-port i-b))
    
    (define mbuffer (make-string 65000))
    (define (loop)
      (let ((a (read-string mbuffer 0 (string-length mbuffer) i)))
        (if (eof-object? a) 'done 
            (begin
              (mutex/lock! lock)
              (write-string mbuffer 0 a o)
              (mutex/unlock! lock)
              (loop)))))
    (loop))

  (define r
    (lambda* (cmd-string (get-return-code #f))
        (define process-return-code)
        (define result (open-output-string))  
        (define output-lock (mutex/new))

        (set! process-return-code (r-base cmd-string result output-lock result output-lock))
        
        (let ((final-result (get-output-string result)))
          (if get-return-code
              (list process-return-code final-result)
                final-result))))

  (define r-split
    (lambda (cmd-string)
      (define process-return-code)
      (define result-out (open-output-string))      
      (define out-lock (mutex/new))
      (define result-err (open-output-string))      
      (define err-lock (mutex/new))

      (set! process-return-code (r-base cmd-string result-out out-lock result-err err-lock))
        
        (let ((final-result-out (get-output-string result-out))
              (final-result-err (get-output-string result-err)))          
          (list process-return-code final-result-out final-result-err))))

  (define r/d
    (lambda (cmd-string)
      (define l (mutex/new))
      (r-base cmd-string (current-output-port) l (current-output-port) l)
      (void)))
  
  (define r-base
    (lambda* (cmd-string stdout stdout-output-lock stderr stderr-output-lock)
        (define process (spawn-process "bash" (list "-c" cmd-string)))
        (define process-lock (mutex/new))
        (define process-return-code)
        (define stdout-thread)
        (define stderr-thread)
        
        (define (grab-results stream-retriever output-stream stream-lock)
          (thread/spawn
           (lambda ()
             (define processInputStream)             
             (mutex/lock! process-lock)
             (set! processInputStream (stream-retriever process))
             (mutex/unlock! process-lock)
             
             (pump_binary-input-port->character-output-port processInputStream output-stream stream-lock)             
             (mutex/unlock! ending-lock))))

        (set! stdout-thread (grab-results get-process-stdout stdout stdout-output-lock))
        (set! stderr-thread (grab-results get-process-stderr stderr stderr-output-lock))
        
        (set! process-return-code (wait-for-process process))

        (thread/join stdout-thread)
        (thread/join stderr-thread)
        process-return-code))


  (define r/s (lambda p (r (apply string-append p))))

   ;; Defines a parameter.
  (define-syntax dp
    (lambda (x)    
      (syntax-case x ()
        ((_ fname value)
         (let* ((symbolic-name (syntax-object->datum (syntax fname))))
           (with-syntax ((symbolic-identifier (datum->syntax-object (syntax _) symbolic-name)))
             (syntax
              (begin
                (define symbolic-identifier
                  (make-parameter value)))))))
        ((_ fname) (syntax (_ fname #f))))))

  (define d)
  (define w)
  
  (set! d (let ((m (mutex/new))) (lambda p (mutex/lock! m) (for-each display p) (mutex/unlock! m) (void))))
  (set! w (let ((m (mutex/new))) (lambda p (mutex/lock! m) (for-each write p) (mutex/unlock! m) (void))))
  
  ;; (define d (lambda p (for-each display p)))
  
  )