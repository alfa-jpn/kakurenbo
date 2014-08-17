require 'spec_helper'

describe Kakurenbo::MixinARBase do
  describe ActiveRecord::Base do
    describe 'class_methods' do
      subject { ActiveRecord::Base.methods }

      it 'has #paranoid?' do
        expect(subject).to include(:paranoid?)
      end

      it 'has #acts_as_paranoid' do
        expect(subject).to include(:acts_as_paranoid)
      end
    end

    describe 'instance_methods' do
      subject { ActiveRecord::Base.instance_methods }

      it 'has #paranoid?' do
        expect(subject).to include(:paranoid?)
      end
    end
  end


  describe 'class of HardDelete' do
    create_temp_table(:hard_deletes) {}
    subject { HardDelete }

    it '#paranoid? return falsey.' do
      expect(subject.paranoid?).to be_falsey
    end

    context 'when change SoftDelete into HardDelete' do
      create_temp_table(:soft_deletes) {|t| t.datetime :deleted_at}
      subject do
        SoftDelete.tap do |c|
          c.class_eval { self.table_name='hard_deletes' }
        end
      end

      it '#paranoid? return falsey.' do
        expect(subject.paranoid?).to be_falsey
      end
    end
  end


  describe 'class of SoftDelete' do
    create_temp_table(:soft_deletes) {|t| t.datetime :deleted_at}
    subject { SoftDelete }

    it '#paranoid? return truthy.' do
      expect(subject.paranoid?).to be_truthy
    end

    context 'when set other column on kakurenbo_column' do
      create_temp_table(:other_columns) {|t| t.datetime :destroyed_at}
      subject do
        OtherColumn.tap do |c|
          c.class_eval { acts_as_paranoid :column => :destroyed_at }
        end
      end

      it '#paranoid? return truthy.' do
        expect(subject.paranoid?).to be_truthy
      end

      it 'kakurenbo_column is `:destroyed_at`.' do
        expect(subject.kakurenbo_column).to eq(:destroyed_at)
      end
    end

    context 'when set other table_name on table_name.' do
      before :all do
        class HaiyoreNyarukoSan < ActiveRecord::Base
          self.table_name='soft_deletes'
        end
      end

      subject { HaiyoreNyarukoSan }

      it '#table_name return soft_deletes' do
        expect(subject.table_name).to eq('soft_deletes')
      end

      it '#paranoid? return truthy.' do
        expect(subject.paranoid?).to be_truthy
      end
    end
  end


  describe 'abstract_class' do
    before :all do
      class Parent < ActiveRecord::Base
        self.abstract_class = true
      end
      class Child < Parent; end
    end

    after :all do
      Object.send(:remove_const, :Parent)
      Object.send(:remove_const, :Child)
    end

    it '.table_name of Child return `children`' do
      expect(Child.table_name).to eq('children')
    end
  end
end
