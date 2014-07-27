require "rubygems"
require "bundler/setup"
require "kakurenbo"

RSpec.configure do |config|
  config.color = true
  config.mock_framework = :rspec
  config.before(:all) {
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
  }
end

# Use ActiveSupport::Inflector#classify
Inflector = Class.new.extend(ActiveSupport::Inflector)

# Create temp table for test.
#
# @param name   [Symbol]        Name of table.
# @param &block [Proc{|t|...}]  Definition column block.
def create_temp_table(name, &block)
  raise 'No block given!' unless block_given?

  class_name = Inflector.classify(name)

  before :all do
    migration = ActiveRecord::Migration.new
    migration.verbose = false
    migration.create_table name, &block

    mock_class = Class.new(ActiveRecord::Base) do
      define_singleton_method(:name){ class_name }
      reset_table_name
    end

    Object.const_set class_name, mock_class
  end

  after :all do
    migration = ActiveRecord::Migration.new
    migration.verbose = false
    migration.drop_table name

    Object.class_eval { remove_const class_name }
  end
end
