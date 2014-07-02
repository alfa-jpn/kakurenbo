require "rubygems"
require "bundler/setup"
require "kakurenbo"

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.before(:all) {
    Dir.mkdir('tmp') unless Dir.exists?('tmp')
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
  }
end

# Create temp table for test.
#
# @param name   [Symbol]        Name of table.
# @param &block [Proc{|t|...}]  Definition column block.
def create_temp_table(name, &block)
  raise 'No block given!' unless block_given?

  before :all do
    migration = ActiveRecord::Migration.new
    migration.verbose = false
    migration.create_table name, &block
  end

  after :all do
    migration = ActiveRecord::Migration.new
    migration.verbose = false
    migration.drop_table name
  end
end
