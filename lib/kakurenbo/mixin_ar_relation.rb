module Kakurenbo
  module MixinARRelation
    # Override methods.
    def self.included(base_class)
      base_class.class_eval do
        alias_method :hard_delete_all, :delete_all

        # delete selected id or ids.
        #
        # @param id      [Integer, Array<Integer>] ID or IDs.
        # @param options [Hash]                    options.
        # @option options [Boolean] hard (false) if hard-delete.
        def delete(id, options = {:hard => false})
          delete_all({:id => id}, options)
        end

        # delete all record.
        #
        # @param conditions [Object] conditions.
        # @param options    [Hash] options.
        # @option options [Boolean] hard (false) if hard-delete.
        def delete_all(conditions = nil, options = {:hard => false})
          return hard_delete_all(conditions) unless klass.paranoid?

          if conditions
            where(conditions).delete_all(nil, options)
          else
            if options[:hard]
              hard_delete_all
            else
              update_all({ klass.kakurenbo_column => Time.now })
            end
          end
        end

        # destroy selected id or ids.
        #
        # @param id      [Integer, Array<Integer>] ID or IDs.
        # @param options [Hash]                    options.
        # @option options [Boolean] hard (false) if hard-delete.
        def destroy(id,  options = {:hard => false})
          destroy_all({:id => id}, options)
        end

        # destroy all record.
        #
        # @param conditions [Object] conditions.
        # @param options    [Hash]   options.
        # @option options [Boolean] hard (false) if hard-delete.
        def destroy_all(conditions = nil, options = {:hard => false})
          if conditions
            where(conditions).destroy_all(nil, options)
          else
            to_a.each {|object| object.destroy(options) }.tap { reset }
          end
        end

        # restore selected id or ids.
        #
        # @param id      [Integer, Array<Integer>] ID or IDs.
        # @param options [Hash]                    options.
        # @option options [Boolean] recursive (true) if restore recursive.
        def restore(id, options = {:recursive => true})
          restore_all({:id => id}, options)
        end

        # restore all record.
        #
        # @param conditions [Object] conditions.
        # @param options    [Hash]   options.
        # @option options [Boolean] recursive (true) if restore recursive.
        def restore_all(conditions = nil, options = {:recursive => true})
          if conditions
            where(conditions).restore_all(nil, options)
          else
            to_a.each {|object| object.restore(options) }.tap { reset }
          end
        end
      end
    end
  end
end
