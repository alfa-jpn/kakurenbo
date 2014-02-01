require 'spec_helper'

describe Kakurenbo::SoftDeleteCore do
  create_temp_table(:parent_models)                { |t| t.integer :child_id; t.datetime :deleted_at }
  create_temp_table(:normal_child_models)          { |t| t.integer :parent_model_id }
  create_temp_table(:paranoid_child_models)        { |t| t.integer :parent_model_id; t.datetime :deleted_at }
  create_temp_table(:paranoid_single_child_models) { |t| t.integer :parent_model_id; t.datetime :deleted_at }

  before :each do
    class NormalChildModel  < ActiveRecord::Base; end
    class ParanoidChildModel < ActiveRecord::Base; end
    class ParanoidSingleChildModel < ActiveRecord::Base; end
    class ParentModel < ActiveRecord::Base
      has_many :normal_child_models,   :dependent => :destroy
      has_many :paranoid_child_models, :dependent => :destroy

      has_one     :paranoid_single_child_model, :dependent => :destroy
      belongs_to  :child, :class_name => :ParanoidSingleChildModel, :dependent => :destroy
    end
  end

  after :each do
    Object.class_eval do
      remove_const :NormalChildModel
      remove_const :ParanoidChildModel
      remove_const :ParanoidSingleChildModel
      remove_const :ParentModel
    end
  end

  describe 'NormalChildModel' do
    before :each do
      @parent = ParentModel.create!
      @first  = @parent.normal_child_models.create!
      @second = @parent.normal_child_models.create!

      @hitori = NormalChildModel.create!
    end

    context 'when parent be destroyed' do
      it 'destroy children who parent has.' do
        expect{@parent.destroy}.to change(NormalChildModel, :count).by(-2)
      end

      it 'not destroy children who parent does not have.' do
        @parent.destroy
        expect(@hitori.reload.destroyed?).to be_false
      end
    end
  end

  describe 'ParanoidChildModel' do
    before :each do
      @parent = ParentModel.create!
      @first  = @parent.paranoid_child_models.create!
      @second = @parent.paranoid_child_models.create!
      @third  = @parent.paranoid_child_models.create!

      @hitori = ParanoidChildModel.create!
    end

    context 'when parent be destroyed' do
      it 'destroy children who parent has.' do
        expect{@parent.destroy}.to change(ParanoidChildModel, :count).by(-3)
        expect(@first.reload.destroyed?).to be_true
        expect(@second.reload.destroyed?).to be_true
        expect(@third.reload.destroyed?).to be_true
      end

      it 'not destroy children who parent does not have.' do
        @parent.destroy
        expect(@hitori.reload.destroyed?).to be_false
      end
    end

    context 'when parent be restored' do
      before :each do
        @parent.destroy
        @hitori.destroy
      end

      it 'restore children who parent has.' do
        expect{@parent.restore!}.to change(ParanoidChildModel, :count).by(3)
        expect(@first.reload.destroyed?).to be_false
        expect(@second.reload.destroyed?).to be_false
        expect(@third.reload.destroyed?).to be_false
      end

      it 'not restore children who parent does not have.' do
        @parent.restore!
        expect(@hitori.reload.destroyed?).to be_true
      end
    end

    context 'when delete child before parent was deleted' do
      before :each do
        # First, delete child.
        delete_at = 1.second.ago
        Time.stub(:now).and_return(delete_at)
        @first.destroy

        # Next, delete parent.
        Time.unstub(:now)
        @parent.destroy
      end

      it 'not restore child who deleted before parent was deleted' do
        expect{@parent.restore!}.to change(ParanoidChildModel, :count).by(2)
        expect(@first.reload.destroyed?).to be_true
      end

      it 'restore children who deleted after parent was deleted' do
        expect{@parent.restore!}.to change(ParanoidChildModel, :count).by(2)
        expect(@second.reload.destroyed?).to be_false
        expect(@third.reload.destroyed?).to be_false
      end
    end
  end

  describe 'ParanoidSingleChildModel(has_one)' do
    before :each do
      @parent = ParentModel.create!
      @first  = ParanoidSingleChildModel.create!(parent_model_id: @parent.id)

      @hitori = ParanoidSingleChildModel.create!
    end

    context 'when parent be destroyed' do
      it 'destroy child who parent has.' do
        expect{@parent.destroy}.to change(ParanoidSingleChildModel, :count).by(-1)
        expect(@first.reload.destroyed?).to be_true
      end

      it 'not destroy child who parent does not have.' do
        @parent.destroy
        expect(@hitori.reload.destroyed?).to be_false
      end
    end

    context 'when parent be restored' do
      before :each do
        @parent.destroy
        @hitori.destroy
      end

      it 'restore child who parent has.' do
        expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(1)
        expect(@first.reload.destroyed?).to be_false
      end

      it 'not restore child who parent does not have.' do
        @parent.restore
        expect(@hitori.reload.destroyed?).to be_true
      end
    end

    context 'when delete child before parent was deleted' do
      before :each do
        # First, delete child.
        delete_at = 1.second.ago
        Time.stub(:now).and_return(delete_at)
        @first.destroy

        # Next, delete parent.
        Time.unstub(:now)
        @parent.destroy
      end

      it 'not restore child who deleted before parent was deleted' do
        expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(0)
        expect(@first.reload.destroyed?).to be_true
      end
    end
  end

  describe 'ParanoidSingleChildModel(belongs_to)' do
    before :each do
      @first  = ParanoidSingleChildModel.create!
      @parent = ParentModel.create!(child_id: @first.id)

      @hitori = ParanoidSingleChildModel.create!
    end

    context 'when parent be destroyed' do
      it 'destroy child who parent has.' do
        expect{@parent.destroy}.to change(ParanoidSingleChildModel, :count).by(-1)
        expect(@first.reload.destroyed?).to be_true
      end

      it 'not destroy child who parent does not have.' do
        @parent.destroy
        expect(@hitori.reload.destroyed?).to be_false
      end
    end

    context 'when parent be restored' do
      before :each do
        @parent.destroy
        @hitori.destroy
      end

      it 'restore child who parent has.' do
        expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(1)
        expect(@first.reload.destroyed?).to be_false
      end

      it 'not restore child who parent does not have.' do
        @parent.restore
        expect(@hitori.reload.destroyed?).to be_true
      end
    end

    context 'when delete child before parent was deleted' do
      before :each do
        # First, delete child.
        delete_at = 1.second.ago
        Time.stub(:now).and_return(delete_at)
        @first.destroy

        # Next, delete parent.
        Time.unstub(:now)
        @parent.destroy
      end

      it 'not restore child who deleted before parent was deleted' do
        expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(0)
        expect(@first.reload.destroyed?).to be_true
      end
    end
  end

  describe 'ChildModels' do
    before :each do
      @parent = ParentModel.create!

      @normal_first    = @parent.normal_child_models.create!
      @normal_second   = @parent.normal_child_models.create!

      @paranoid_first  = @parent.paranoid_child_models.create!
      @paranoid_second = @parent.paranoid_child_models.create!

      @single_first    = ParanoidSingleChildModel.create!(parent_model_id: @parent.id)

      @normal_hitori   = NormalChildModel.create!
      @paranoid_hitori = ParanoidChildModel.create!
      @single_hitori   = ParanoidSingleChildModel.create!
    end

    context 'when parent be hard-destroyed' do
      it 'hard-destroy normal children who parent has.' do
        expect{@parent.destroy!}.to change(NormalChildModel, :count).by(-2)
      end

      it 'hard-destroy paranoid children who parent has.' do
        expect{@parent.destroy!}.to change{ParanoidChildModel.with_deleted.count}.by(-2)
      end

      it 'hard-destroy paranoid single child who parent has.' do
        expect{@parent.destroy!}.to change{ParanoidSingleChildModel.with_deleted.count}.by(-1)
      end

      it 'not destroy child who parent does not have.' do
        @parent.destroy!
        expect(@normal_hitori.reload.destroyed?).to   be_false
        expect(@paranoid_hitori.reload.destroyed?).to be_false
        expect(@single_hitori.reload.destroyed?).to   be_false
      end
    end
  end
end
