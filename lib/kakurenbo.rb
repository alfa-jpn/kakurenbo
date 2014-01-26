# require need modules.
require "active_support"
require "active_record"

# require kakurenbo modules.
require "kakurenbo/version"
require "kakurenbo/mixin_ar_base"
require "kakurenbo/soft_delete_core"

# Kakurenbo Mixin to ActiveRecord::Base.
ActiveRecord::Base.send :include, Kakurenbo::MixinARBase
