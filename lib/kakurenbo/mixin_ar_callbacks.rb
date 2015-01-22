module Kakurenbo
  module MixinARCallbacks
    # Override methods.
    def self.included(base_class)
      base_class.class_eval do
        def destroy(options = {:hard => false})
          run_callbacks(:destroy) { super(options) }
        end
      end
    end
  end
end

