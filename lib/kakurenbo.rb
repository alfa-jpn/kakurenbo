# require need modules.
require "active_support"
require "active_record"

# require kakurenbo modules.
require "kakurenbo/version"
require "kakurenbo/mixin_ar_base"
require "kakurenbo/mixin_ar_associations"
require "kakurenbo/mixin_ar_relation"
require "kakurenbo/mixin_ar_transactions"
require "kakurenbo/mixin_ar_callbacks"
require "kakurenbo/mixin_ar_persistence"
require "kakurenbo/mixin_ar_locking_optimistic"
require "kakurenbo/core"

# Kakurenbo Add ActiveRecord::RecordNotRestored to ActiveRecord
class ActiveRecord::RecordNotRestored < ActiveRecord::RecordNotDestroyed; end

# Kakurenbo Mixin to ActiveRecord::Base.
ActiveRecord::Base.send :include, Kakurenbo::MixinARBase

# Kakurenbo Mixin to ActiveRecord::Relation.
ActiveRecord::Relation.send :include, Kakurenbo::MixinARRelation

# Kakurenbo Mixin to ActiveRecord::Associations
ActiveRecord::Associations::Association.send :include, Kakurenbo::MixinARAssociations::Association

# Kakurenbo Mixin to ActiveRecord::Transaction
ActiveRecord::Transactions.send :include, Kakurenbo::MixinARTransactions

# Kakurenbo Mixin to ActiveRecord::Callbacks
ActiveRecord::Callbacks.send :include, Kakurenbo::MixinARCallbacks

# Kakurenbo Mixin to ActiveRecord::Persistence
ActiveRecord::Persistence.send :include, Kakurenbo::MixinARPersistence

# Kakurenbo Mixin to ActiveRecord::Locking::Optimistic
ActiveRecord::Locking::Optimistic.send :include, Kakurenbo::MixinARLockingOptimistic
