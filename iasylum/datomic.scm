(require-extension (lib iasylum/jcode))

(module iasylum/datomic
  (datomic/query d/q
   datomic/smart-query d/sq
   datomic/smart-transact d/st
   datomic/connection
   datomic/temp-id d/id
   datomic/transact d/t
   datomic/transact-async
   datomic/db d/db
   datomic/make-latest-db-retriever
   datomic/make-with-one-connection-included-query-function
   datomic/make-with-one-connection-included-transact-function
   datomic/id
   datomic/uuid
   datomic/extract-time-millis-from-uuid
   datomic/make-empty-transaction-set
   datomic/push-transaction!
   datomic/extract-transaction-and-parameters-pair
   )

  (include "datomic-code.scm")
)
