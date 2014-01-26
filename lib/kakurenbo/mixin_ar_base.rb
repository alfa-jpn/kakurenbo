module Kakurenbo
  module MixinARBase
    # Extend ClassMethods after include.
    def self.included(base_class)
      base_class.extend ClassMethods
    end

    module ClassMethods
      # Initialize Kakurenbo in child class.
      def inherited(child_class)
        child_class.instance_eval {
          next unless column_names.include?('deleted_at')
          remodel_as_soft_delete
        }
        super
      end

      # Remodel Model as soft-delete.
      #
      # @options [Hash] option
      #   default: {
      #     :column => :deleted_at
      #   }
      def remodel_as_soft_delete(options = {})
        options.reverse_merge!(
          :column => :deleted_at
        )

        unless paranoid?
          alias_method :delete!,  :delete
          alias_method :destroy!, :destroy

          class_attribute :kakurenbo_column
          self.kakurenbo_column = options[:column]

          include Kakurenbo::SoftDeleteCore
        end
      end
      alias_method :acts_as_paranoid, :remodel_as_soft_delete

      # Will be override this method, if class is soft_delete.
      def paranoid?
        false
      end
    end

    def paranoid?
      self.class.paranoid?
    end
  end
end
