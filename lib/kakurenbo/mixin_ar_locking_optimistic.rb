module Kakurenbo
  module MixinARLockingOptimistic
    # Override methods.
    def self.included(base_class)
      base_class.class_eval do
       def destroy_row(options = {:hard => false})
          affected_rows = super(options)

          if locking_enabled? && affected_rows != 1
            raise ActiveRecord::StaleObjectError.new(self, "destroy")
          end

          affected_rows
        end
      end
    end
  end
end

