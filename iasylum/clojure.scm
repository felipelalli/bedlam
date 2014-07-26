;;; Code by Igor Hjelmstrom Vinhas Ribeiro - this is licensed under GNU GPL v2.

;;; This allows one to easily call Clojure code from inside Scheme code.

(require-extension (lib iasylum/jcode))

(module iasylum/clojure
  (clojure/run
   clojure/repl-start
   clj
   clojure/find-value-by-key
   symbol->clj-keyword
   clj-keyword->symbol
   clj-keyword->string
   )
  
  (include "clojure-code.scm"))
