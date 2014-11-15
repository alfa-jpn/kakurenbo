module Kakurenbo
  module MixinARTransactions
    # Override methods.
    def self.included(base_class)
      base_class.class_eval do
        def destroy(options = {:hard => false})
          with_transaction_returning_status { super(options) }
        end
      end
    end
  end
end
