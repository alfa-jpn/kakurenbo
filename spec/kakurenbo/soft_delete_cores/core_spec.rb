require 'spec_helper'

describe Kakurenbo::SoftDeleteCore do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }

  before :each do
    class ParanoidModel < ActiveRecord::Base; end
  end

  after :each do
    Object.class_eval{ remove_const :ParanoidModel }
  end

  describe 'Instance of paranoid model' do
    before :each do
      @model = ParanoidModel.create!
    end

    context 'when delete' do
      it 'soft-delete model.' do
        expect{
          @model.delete
        }.to change(ParanoidModel, :count).by(-1)
      end

      it 'not hard-delete model.' do
        expect{
          @model.delete
        }.to change{
          ParanoidModel.all.with_deleted.count
        }.by(0)
      end

      it 'call callbacks nothing.' do
        ParanoidModel.before_destroy :before_destroy_callback
        ParanoidModel.after_destroy  :after_destroy_callback
        ParanoidModel.after_commit   :after_commit_callback

        @model.should_receive(:before_destroy_callback).exactly(0).times
        @model.should_receive(:after_destroy_callback).exactly(0).times
        @model.should_receive(:after_commit_callback).exactly(0).times

        @model.delete
      end

      it 'not call callbacks other.' do
        ParanoidModel.before_update :before_update_callback
        ParanoidModel.before_save   :before_save_callback
        ParanoidModel.validate      :validate_callback

        @model.should_receive(:before_update_callback).exactly(0).times
        @model.should_receive(:before_save_callback).exactly(0).times
        @model.should_receive(:validate_callback).exactly(0).times

        @model.delete
      end
    end

    context 'when delete!' do
      it 'hard-delete model.' do
        expect{
          @model.delete!
        }.to change{
          ParanoidModel.all.with_deleted.count
        }.by(-1)
      end
    end

    context 'when destroy(class method)' do
      before :each do
        @model2 = ParanoidModel.create!
      end

      it 'with id, destroy model.' do
        expect{
          ParanoidModel.destroy(@model.id)
        }.to change(ParanoidModel, :count).by(-1)

        expect(@model.reload.destroyed?).to be_true
      end

      it 'with ids, destroy models.' do
        expect{
          ParanoidModel.destroy([@model.id, @model2.id])
        }.to change(ParanoidModel, :count).by(-2)

        expect(@model.reload.destroyed?).to be_true
        expect(@model2.reload.destroyed?).to be_true
      end
    end

    context 'when destroy(instance method)' do
      it 'soft-delete model.' do
        expect{
          @model.destroy
        }.to change(ParanoidModel, :count).by(-1)
      end

      it 'not hard-delete model.' do
        expect{
          @model.destroy
        }.to change{
          ParanoidModel.all.with_deleted.count
        }.by(0)
      end

      it 'call callbacks of destroy.' do
        ParanoidModel.before_destroy :before_destroy_callback
        ParanoidModel.after_destroy  :after_destroy_callback
        ParanoidModel.after_commit   :after_commit_callback

        @model.should_receive(:before_destroy_callback).once
        @model.should_receive(:after_destroy_callback).once
        @model.should_receive(:after_commit_callback).once.and_return(true)

        @model.destroy
      end

      it 'not call callbacks without destroy.' do
        ParanoidModel.before_update :before_update_callback
        ParanoidModel.before_save   :before_save_callback
        ParanoidModel.validate      :validate_callback

        @model.should_receive(:before_update_callback).exactly(0).times
        @model.should_receive(:before_save_callback).exactly(0).times
        @model.should_receive(:validate_callback).exactly(0).times

        @model.destroy
      end
    end

    context 'when destroy!' do
      it 'hard-delete model.' do
        expect{
          @model.destroy!
        }.to change{
          ParanoidModel.all.with_deleted.count
        }.by(-1)
      end
    end

    context 'when destroyed?' do
      it 'false if model not destroyed.' do
        expect(@model.destroyed?).to be_false
      end

      it 'false if model destroyed.' do
        @model.destroy
        expect(@model.destroyed?).to be_true
      end

      it 'alias deleted? to destroyed?' do
        expect(@model.deleted?).to be_false
      end
    end

    context 'when restore(class method)' do
      before :each do
        @model.destroy

        @model2 = ParanoidModel.create!
        @model2.destroy
      end

      it 'with id, restore model.' do
        expect{
          ParanoidModel.restore(@model.id)
        }.to change(ParanoidModel, :count).by(1)

        expect(@model.reload.destroyed?).to be_false
      end

      it 'with ids, restore models.' do
        expect{
          ParanoidModel.restore([@model.id, @model2.id])
        }.to change(ParanoidModel, :count).by(2)

        expect(@model.reload.destroyed?).to be_false
        expect(@model2.reload.destroyed?).to be_false
      end
    end

    context 'when restore(instance method)' do
      before :each do
        @model.destroy
      end

      it 'restore model' do
        expect{
          @model.restore!
        }.to change(ParanoidModel, :count).by(1)

        expect(@model.reload.destroyed?).to be_false
      end

      it 'call callbacks of restore.' do
        ParanoidModel.before_restore :before_restore_callback
        ParanoidModel.after_restore  :after_restore_callback
        ParanoidModel.after_commit   :after_commit_callback

        @model.should_receive(:before_restore_callback).once
        @model.should_receive(:after_restore_callback).once
        @model.should_receive(:after_commit_callback).once.and_return(true)

        @model.restore!
      end

      it 'not call callbacks without restore.' do
        ParanoidModel.before_update :before_update_callback
        ParanoidModel.before_save   :before_save_callback
        ParanoidModel.validate      :validate_callback

        @model.should_receive(:before_update_callback).exactly(0).times
        @model.should_receive(:before_save_callback).exactly(0).times
        @model.should_receive(:validate_callback).exactly(0).times

        @model.restore!
      end

      it 'alias recover to restore!' do
        expect{
          @model.restore!
        }.to change(ParanoidModel, :count).by(1)

        expect(@model.reload.destroyed?).to be_false
      end
    end
  end
end
