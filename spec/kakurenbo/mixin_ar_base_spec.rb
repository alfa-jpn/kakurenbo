require 'spec_helper'

describe Kakurenbo::MixinARBase do
  create_temp_table(:hard_deletes) {}
  create_temp_table(:soft_deletes) {|t| t.datetime :deleted_at}
  create_temp_table(:other_columns){|t| t.datetime :destroyed_at}
  create_temp_table(:other_table_name) {|t| t.datetime :deleted_at}

  context 'when mixin ActiveRecord::Base' do
    it 'has paranoid? in class methods.'do
      expect(ActiveRecord::Base.methods).to include(:paranoid?)
    end

    it 'has paranoid? in instance methods.' do
      expect(ActiveRecord::Base.instance_methods).to include(:paranoid?)
    end

    it 'has acts_as_paranoid in class methods.' do
      expect(ActiveRecord::Base.methods).to include(:acts_as_paranoid)
    end
  end

  context 'when define class of HardDelete' do
    before :all do
      class HardDelete < ActiveRecord::Base; end
    end

    it 'paranoid? return false.' do
      expect(HardDelete.paranoid?).to be_falsey
    end
  end

  context 'when define class of SoftDelete' do
    before :all do
      class SoftDelete < ActiveRecord::Base; end
    end

    it 'paranoid? return true.' do
      expect(SoftDelete.paranoid?).to be_truthy
    end
  end

  context 'when define class of OtherColumn' do
    before :all do
      class OtherColumn < ActiveRecord::Base
        acts_as_paranoid :column => :destroyed_at
      end
    end

    it 'paranoid? return true.' do
      expect(OtherColumn.paranoid?).to be_truthy
    end

    it 'kakurenbo_column is `:destroyed_at`.' do
      expect(OtherColumn.kakurenbo_column).to eq(:destroyed_at)
    end
  end

  context 'when define class of DiffTableName' do
    before :all do
      class DiffTableName < ActiveRecord::Base
        self.table_name='other_table_name'
      end
    end

    it 'table_name is right.' do
      expect(DiffTableName.table_name).to eq('other_table_name')
    end

    it 'paranoid? return true.' do
      expect(DiffTableName.paranoid?).to be_truthy
    end
  end
end
