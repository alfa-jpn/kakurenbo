require 'spec_helper'

describe Kakurenbo::MixinARBase do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }

  create_temp_table(:parent_models)                { |t| t.integer :child_id; t.datetime :deleted_at }
  create_temp_table(:normal_child_models)          { |t| t.integer :parent_model_id }
  create_temp_table(:paranoid_child_models)        { |t| t.integer :parent_model_id; t.datetime :deleted_at }
  create_temp_table(:paranoid_single_child_models) { |t| t.integer :parent_model_id; t.datetime :deleted_at }

  context 'when define ParanoidModel' do
    before :each do
      class ParanoidModel < ActiveRecord::Base; end
    end

    after :each do
      Object.class_eval{ remove_const :ParanoidModel }
    end

    describe 'Callbacks' do
      before :each do
        @callback_model = ParanoidModel.create!
      end

      it 'before_restore.' do
        ParanoidModel.before_restore :before_restore_callback
        @callback_model.should_receive(:before_restore_callback).once
        @callback_model.run_callbacks(:restore)
      end

      it 'around_restore.' do
        ParanoidModel.around_restore :around_restore_callback
        @callback_model.should_receive(:around_restore_callback).once
        @callback_model.run_callbacks(:restore)
      end

      it 'after_restore.' do
        ParanoidModel.after_restore :after_restore_callback
        @callback_model.should_receive(:after_restore_callback).once
        @callback_model.run_callbacks(:restore)
      end
    end


    describe 'Scopes' do
      before :each do
        @normal_model  = ParanoidModel.create!
        @deleted_model = ParanoidModel.create!(deleted_at: Time.now)
      end

      context 'when use default_scope' do
        it 'show normal model.' do
          expect(ParanoidModel.find_by(id: @normal_model.id)).not_to be_nil
        end

        it 'hide deleted model.' do
          expect(ParanoidModel.find_by(id: @deleted_model.id)).to be_nil
        end
      end

      context 'when use only_deleted' do
        it 'show normal model.' do
          expect(ParanoidModel.only_deleted.find_by(id: @normal_model.id)).to be_nil
        end

        it 'show deleted model.' do
          expect(ParanoidModel.only_deleted.find_by(@deleted_model.id)).not_to be_nil
        end
      end

      context 'when use with_deleted' do
        it 'show normal model.' do
          expect(ParanoidModel.with_deleted.find_by(id: @normal_model.id)).not_to be_nil
        end

        it 'show deleted model.' do
          expect(ParanoidModel.with_deleted.find_by(@deleted_model.id)).not_to be_nil
        end
      end

      context 'when use without_deleted' do
        it 'show normal model.' do
          expect(ParanoidModel.without_deleted.find_by(id: @normal_model.id)).not_to be_nil
        end

        it 'hide deleted model.' do
          expect(ParanoidModel.without_deleted.find_by(id: @deleted_model.id)).to be_nil
        end
      end
    end


    describe 'Core' do
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

      context 'when destroy' do
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

        it 'alias_method deleted? to destroyed?' do
          expect(@model.deleted?).to be_false
        end
      end

      context 'when restore.(class method)' do
        before :each do
          @model.destroy
        end

        it 'with id restore of instance method.' do
          expect{
            ParanoidModel.restore(@model.id)
          }.to change(ParanoidModel, :count).by(1)

          expect(@model.reload.destroyed?).to be_false
        end

        it 'with ids restore of instance method.' do
          @model2 = ParanoidModel.create!
          @model2.destroy

          expect{
            ParanoidModel.restore([@model.id, @model2.id])
          }.to change(ParanoidModel, :count).by(2)

          expect(@model.reload.destroyed?).to be_false
          expect(@model2.reload.destroyed?).to be_false
        end
      end

      context 'when restore.(instance method)' do
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
      end
    end
  end


  context 'when define relation model' do
    before :all do
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

    describe 'NormalChildModel' do
      before :each do
        @parent = ParentModel.create!
        @first  = @parent.normal_child_models.create!
        @second = @parent.normal_child_models.create!
      end

      context 'when parent was destroyed' do
        it 'remove normal_child_models' do
          expect{@parent.destroy}.to change(NormalChildModel, :count).by(-2)
          expect(@first.destroyed?).to be_true
          expect(@second.destroyed?).to be_true
        end
      end
    end

    describe 'ParanoidChildModel' do
      before :each do
        @parent = ParentModel.create!
        @first  = @parent.paranoid_child_models.create!
        @second = @parent.paranoid_child_models.create!
        @third  = @parent.paranoid_child_models.create!
      end

      context 'when parent was destroyed' do
        it 'remove normal_child_models' do
          expect{@parent.destroy}.to change(ParanoidChildModel, :count).by(-3)
          expect(@first.reload.destroyed?).to be_true
          expect(@second.reload.destroyed?).to be_true
          expect(@third.reload.destroyed?).to be_true
        end

        it 'restore with normal_child_models' do
          @parent.destroy
          expect{@parent.restore!}.to change(ParanoidChildModel, :count).by(3)
          expect(@first.reload.destroyed?).to be_false
          expect(@second.reload.destroyed?).to be_false
          expect(@third.reload.destroyed?).to be_false
        end

        it 'not restore model that was deleted before parent was deleted.' do
          # Delete before parent was deleted.
          delete_at = 1.second.ago
          Time.stub(:now).and_return(delete_at)
          @first.destroy

          # Delete after first_child was deleted.
          Time.unstub(:now)
          @parent.destroy

          expect{@parent.restore!}.to change(ParanoidChildModel, :count).by(2)
          expect(@first.reload.destroyed?).to be_true
          expect(@second.reload.destroyed?).to be_false
          expect(@third.reload.destroyed?).to be_false
        end
      end
    end

    describe 'ParanoidSingleChildModel' do
      before :each do
        @parent = ParentModel.create!
        @first  = ParanoidSingleChildModel.create!(parent_model_id: @parent.id)
      end

      context 'when parent was destroyed' do
        it 'remove normal_child_models' do
          expect{@parent.destroy}.to change(ParanoidSingleChildModel, :count).by(-1)
          expect(@first.reload.destroyed?).to be_true
        end

        it 'restore with normal_child_models' do
          @parent.destroy
          expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(1)
          expect(@first.reload.destroyed?).to be_false
        end

        it 'not restore model that was deleted before parent was deleted.' do
          # Delete before parent was deleted.
          delete_at = 1.second.ago
          Time.stub(:now).and_return(delete_at)
          @first.destroy

          # Delete after first_child was deleted.
          Time.unstub(:now)
          @parent.destroy

          expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(0)
          expect(@first.reload.destroyed?).to be_true
        end
      end
    end

    describe 'ParanoidSingleChildModel' do
      before :each do
        @first  = ParanoidSingleChildModel.create!
        @parent = ParentModel.create!(child_id: @first.id)
      end

      context 'when parent was destroyed' do
        it 'remove normal_child_models' do
          expect{@parent.destroy}.to change(ParanoidSingleChildModel, :count).by(-1)
          expect(@first.reload.destroyed?).to be_true
        end

        it 'restore with normal_child_models' do
          @parent.destroy
          expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(1)
          expect(@first.reload.destroyed?).to be_false
        end

        it 'not restore model that was deleted before parent was deleted.' do
          # Delete before parent was deleted.
          delete_at = 1.second.ago
          Time.stub(:now).and_return(delete_at)
          @first.destroy

          # Delete after first_child was deleted.
          Time.unstub(:now)
          @parent.destroy

          expect{@parent.restore!}.to change(ParanoidSingleChildModel, :count).by(0)
          expect(@first.reload.destroyed?).to be_true
        end
      end
    end
  end
end
