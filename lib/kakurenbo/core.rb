module Kakurenbo
  module Core
    # Extend ClassMethods after include.
    def self.included(base_class)
      base_class.extend ClassMethods
      base_class.extend Callbacks
      base_class.extend Scopes
      base_class.extend Aliases
    end

    module Aliases
      def self.extended(base_class)
        base_class.instance_eval {
          alias_method :deleted?, :destroyed?
          alias_method :recover,  :restore
          alias_method :recover!, :restore!
        }
      end
    end

    module Callbacks
      def self.extended(base_class)
        # Regist callbacks.
        [:before, :around, :after].each do |on|
          base_class.define_singleton_method("#{on}_restore") do |*args, &block|
            set_callback(:restore, on, *args, &block)
          end
        end
        base_class.define_model_callbacks :restore
      end
    end

    module ClassMethods
      def paranoid?; true end
    end

    module Scopes
      def self.extended(base_class)
        base_class.instance_eval {
          scope :only_deleted,    ->{ with_deleted.where.not( kakurenbo_column => nil ) }
          scope :without_deleted, ->{ where(kakurenbo_column => nil) }
          if ActiveRecord::VERSION::STRING >= "4.1"
            scope :with_deleted,  ->{ unscope :where => kakurenbo_column }
          else
            scope :with_deleted,  ->{ all.tap{ |s| s.default_scoped = false } }
          end

          default_scope ->{ without_deleted }
        }
      end
    end

    # delete record.
    #
    # @param options [Hash] options.
    # @option options [Boolean] hard (false) if hard-delete.
    def delete(options = {:hard => false})
      if options[:hard]
        self.class.delete(self.id, options)
      else
        return if new_record? or destroyed?
        update_column kakurenbo_column, current_time_from_proper_timezone
      end
    end

    # destroy record and run callbacks.
    #
    # @param options [Hash] options.
    # @option options [Boolean] hard (false) if hard-delete.
    #
    # @return [Boolean, self] if action is cancelled, return false.
    def destroy(options = {:hard => false})
      if options[:hard]
        with_transaction_returning_status do
          hard_destroy_associated_records
          self.reload.hard_destroy
        end
      else
        return true if destroyed?
        with_transaction_returning_status do
          destroy_at = current_time_from_proper_timezone
          run_callbacks(:destroy){ update_column kakurenbo_column, destroy_at; self }
        end
      end
    end

    # destroy record and run callbacks.
    #
    # @param options [Hash] options.
    # @option options [Boolean] hard (false) if hard-delete.
    #
    # @return [self] self.
    def destroy!(options = {:hard => false})
      destroy(options) || raise(ActiveRecord::RecordNotDestroyed)
    end

    def destroy_row
      relation_for_destroy.delete_all(nil, :hard => true)
    end

    def destroyed?
      !send(kakurenbo_column).nil?
    end

    def kakurenbo_column
      self.class.kakurenbo_column
    end

    def persisted?
      !new_record?
    end

    # restore record.
    #
    # @param options [Hash] options.
    # @option options [Boolean] recursive (true) if restore recursive.
    #
    # @return [Boolean, self] if action is cancelled, return false.
    def restore(options = {:recursive => true})
      return false unless destroyed?

      with_transaction_returning_status do
        run_callbacks(:restore) do
          parent_deleted_at = send(kakurenbo_column)
          restore_associated_records(parent_deleted_at) if options[:recursive]
          update_column kakurenbo_column, nil
          self
        end
      end
    end

    # restore record.
    #
    # @param options [Hash] options.
    # @option options [Boolean] hard (false) if hard-delete.
    #
    # @return [self] self.
    def restore!(options = {:recursive => true})
      restore(options) || raise(ActiveRecord::RecordNotRestored)
    end

    private
    # get recoreds of association.
    #
    # @param association [ActiveRecord::Associations] association.
    # @return [Array or CollectionProxy] records.
    def associated_records(association)
      resource = send(association.name)
      if resource.nil?
        []
      elsif association.collection?
        resource.with_deleted
      else
        [resource]
      end
    end

    # Calls the given block once for each dependent destroy records.
    # @note Only call the class of paranoid.
    #
    # @param &block [Proc{|record|.. }] execute block.
    def each_dependent_destroy_records(&block)
      self.class.reflect_on_all_associations.each do |association|
        next unless association.options[:dependent] == :destroy
        next unless association.klass.paranoid?

        associated_records(association).each &block
      end
    end

    # Hard-Destroy associated records.
    def hard_destroy_associated_records
      each_dependent_destroy_records do |record|
        record.destroy(hard: true)
      end
    end

    # Restore associated records.
    # @note Not restore if deleted_at older than parent_deleted_at.
    #
    # @param parent_deleted_at [Time] The time when parent was deleted.
    def restore_associated_records(parent_deleted_at)
      each_dependent_destroy_records do |record|
        next unless record.destroyed?
        next unless parent_deleted_at <= record.send(kakurenbo_column)
        record.restore!
      end
    end
  end
end
