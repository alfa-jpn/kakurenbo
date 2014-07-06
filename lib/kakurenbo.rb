# require need modules.
require "active_support"
require "active_record"

# require kakurenbo modules.
require "kakurenbo/version"
require "kakurenbo/mixin_ar_base"
require "kakurenbo/mixin_ar_relation"
require "kakurenbo/core"

# Kakurenbo Add ActiveRecord::RecordNotRestored to ActiveRecord
class ActiveRecord::RecordNotRestored < ActiveRecord::RecordNotDestroyed; end

# Kakurenbo Mixin to ActiveRecord::Base.
ActiveRecord::Base.send :include, Kakurenbo::MixinARBase

# Kakurenbo Mixin to ActiveRecord::Relation.
ActiveRecord::Relation.send :include, Kakurenbo::MixinARRelation
