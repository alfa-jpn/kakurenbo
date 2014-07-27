module Kakurenbo
  module MixinARAssociations
    module Association
      # Extend ClassMethods after include.
      def self.included(base_class)
        base_class.class_eval { alias_method_chain :scope, :deleted }
      end

      # Load deleted model, if owner is deleted.
      def scope_with_deleted
        if @owner.paranoid? and @owner.destroyed? and klass.paranoid?
          col = klass.arel_table[klass.kakurenbo_column]
          owner_deleted_at = @owner.send(@owner.class.kakurenbo_column)
          condition = col.eq(nil).or(col.gteq(owner_deleted_at))

          scope_without_deleted.with_deleted.where(condition)
        else
          scope_without_deleted
        end
      end
    end
  end
end
