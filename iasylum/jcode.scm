;;; Code by Igor Hjelmstrom Vinhas Ribeiro - this is licensed under GNU GPL v2.

;;; This allows one to easily call Java code from inside Scheme code.

(require-extension (lib iasylum/srfi-89))
(require-extension (lib iasylum/match))

(module iasylum/jcode
  (j
   _n_   
   _0_
   _1_
   _2_
   _3_
   _4_
   ->jobject
   
     ; s2j convenience exports
     java-new
     ;;classes
     java-class
     java-class?
     java-class-name
     java-class-flags
     java-class-declaring-class
     java-class-declared-superclasses
     java-class-declared-classes
     java-class-declared-constructors
     java-class-declared-methods
     java-class-declared-fields
     java-class-precedence-list
     define-java-class
     define-java-classes
     ;;constructors
     java-constructor?
     java-constructor-name
     java-constructor-flags
     java-constructor-declaring-class
     java-constructor-parameter-types
     java-constructor-procedure
     java-constructor-method
     ;;methods
     java-method?
     java-method-name
     java-method-flags
     java-method-declaring-class
     java-method-parameter-types
     java-method-return-type
     java-method-procedure
     java-method-method
     generic-java-method
     define-generic-java-method
     define-generic-java-methods
     ;;fields
     java-field?
     java-field-name
     java-field-flags
     java-field-declaring-class
     java-field-type
     java-field-accessor-procedure
     java-field-modifier-procedure
     java-field-accessor-method
     java-field-modifier-method
     generic-java-field-accessor
     generic-java-field-modifier
     define-generic-java-field-accessor
     define-generic-java-field-modifier
     define-generic-java-field-accessors
     define-generic-java-field-modifiers
     ;;arrays
     java-array-class
     java-array?
     java-array-new
     java-array-ref
     java-array-set!
     java-array-length
     ;;proxies
     java-proxy-class
     java-proxy-dispatcher
     define-java-proxy
     ;;misc
     s2j/clear-reflection-cache!
     java-synchronized
     java-wrap
     java-unwrap
     java-null
     java-object?
     java-interface?
     java-null?
     ;;primitive types
     <jvalue>
     <jvoid>
     <jboolean>
     <jchar>
     <jbyte>
     <jshort>
     <jint>
     <jlong>
     <jfloat>
     <jdouble>
     ;;conversions
     ->jboolean
     ->jchar
     ->jbyte
     ->jshort
     ->jint
     ->jlong
     ->jfloat
     ->jdouble
     ->jstring
     ->jarray
     ->boolean
     ->character
     ->number
     ->string
     ->symbol
     ->vector
     ->list
     jnull
     initialize-s2j-exception-handling
     display-java-stack-trace
   )
  (import s2j)
  (include "jcode-code.scm"))