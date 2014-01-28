require 'spec_helper'

describe Kakurenbo::SoftDeleteCore::Scopes do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }

  before :each do
    class ParanoidModel < ActiveRecord::Base; end
  end

  after :each do
    Object.class_eval{ remove_const :ParanoidModel }
  end

  context 'when call scope of' do
    before :each do
      @existing_model = ParanoidModel.create!
      @deleted_model  = ParanoidModel.create!(deleted_at: Time.now)
    end

    context 'default_scope' do
      it 'show existing model.' do
        expect(ParanoidModel.find_by(id: @existing_model.id)).not_to be_nil
      end

      it 'hide deleted model.' do
        expect(ParanoidModel.find_by(id: @deleted_model.id)).to be_nil
      end
    end

    context 'only_deleted' do
      it 'hide existing model.' do
        expect(ParanoidModel.only_deleted.find_by(id: @existing_model.id)).to be_nil
      end

      it 'show deleted model.' do
        expect(ParanoidModel.only_deleted.find_by(@deleted_model.id)).not_to be_nil
      end
    end

    context 'with_deleted' do
      it 'show existing model.' do
        expect(ParanoidModel.with_deleted.find_by(id: @existing_model.id)).not_to be_nil
      end

      it 'show deleted model.' do
        expect(ParanoidModel.with_deleted.find_by(@deleted_model.id)).not_to be_nil
      end
    end

    context 'without_deleted' do
      it 'show existing model.' do
        expect(ParanoidModel.without_deleted.find_by(id: @existing_model.id)).not_to be_nil
      end

      it 'hide deleted model.' do
        expect(ParanoidModel.without_deleted.find_by(id: @deleted_model.id)).to be_nil
      end
    end
  end
end
