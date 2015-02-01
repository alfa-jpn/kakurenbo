module Kakurenbo
  module MixinARBase
    # Extend ClassMethods after include.
    def self.included(base_class)
      base_class.extend ClassMethods
    end

    module ClassMethods
      delegate :restore, :restore_all, {:to => :with_deleted}

      # Initialize Kakurenbo in child class.
      def inherited(child_class)
        super

        child_class.define_singleton_method :table_name= do |value|
          super(value)
          if has_kakurenbo_column?
            remodel_as_soft_delete
          else
            remodel_as_original
          end
        end

        child_class.instance_eval do
          remodel_as_soft_delete if has_kakurenbo_column?

          # Reset @table name, because ActiveRecord doesn't expect initialized at here.
          remove_instance_variable(:@table_name) if instance_variable_defined? :@table_name
        end
      end

      # Remodel Model as normal.
      # @note Restore to original model.
      def remodel_as_original
        if paranoid?
          alias_method :delete,   :hard_delete
          alias_method :destroy,  :hard_destroy
          alias_method :destroy!, :hard_destroy!

          define_singleton_method(:paranoid?) { false }
        end
      end

      # Remodel Model as soft-delete.
      #
      # @params option [Hash] option.
      # @option option [Symbol] column column of kakurenbo.
      def remodel_as_soft_delete(options = {})
        options.reverse_merge!(
          :column => :deleted_at
        )

        unless paranoid?
          alias_method :hard_delete,   :delete
          alias_method :hard_destroy,  :destroy
          alias_method :hard_destroy!, :destroy!

          class_attribute :kakurenbo_column
          include Kakurenbo::Core
        end

        self.kakurenbo_column = options[:column]
      end
      alias_method :acts_as_paranoid, :remodel_as_soft_delete

      # Will be override this method, if class is soft_delete.
      def paranoid?
        false
      end

      private
      # Check if Model has kakurenbo_column.
      #
      # @return [Boolean] result.
      def has_kakurenbo_column?
        begin
          table_exists? and column_names.include?('deleted_at')
        rescue
          false
        end
      end
    end

    def paranoid?
      self.class.paranoid?
    end
  end
end
