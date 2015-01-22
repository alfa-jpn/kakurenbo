module Kakurenbo
  module MixinARPersistence
    # Override methods.
    def self.included(base_class)
      base_class.class_eval do
        def destroy(options = {:hard => false})
          raise ReadOnlyRecord if readonly?
          destroy_associations
          #destroy_row(options) if persisted?
          destroy_row if persisted?
          @destroyed = true
          freeze
        end

        private
        def destroy_row(options = {:hard => false})
          relation_for_destroy.delete_all(nil, options)
        end
      end
    end
  end
end
