require 'spec_helper'

describe Kakurenbo::Core::Scopes do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }

  let!(:existing_model) { ParanoidModel.create! }
  let!(:deleted_model)  { ParanoidModel.create!(deleted_at: Time.now) }

  describe 'default_scope' do
    subject do
      ParanoidModel.find_by(id: model.id)
    end

    context 'when existing_model' do
      let(:model) { existing_model }

      it 'can get.' do
        expect(subject).not_to be_nil
      end
    end

    context 'when deleted_model' do
      let(:model) { deleted_model }

      it 'can not get.' do
        expect(subject).to be_nil
      end
    end
  end

  describe 'only_deleted' do
    subject do
      ParanoidModel.only_deleted.find_by(id: model.id)
    end

    context 'when existing_model' do
      let(:model) { existing_model }

      it 'can not get.' do
        expect(subject).to be_nil
      end
    end

    context 'when deleted_model' do
      let(:model) { deleted_model }

      it 'can get.' do
        expect(subject).not_to be_nil
      end
    end
  end

  describe 'with_deleted' do
    subject do
      ParanoidModel.with_deleted.find_by(id: model.id)
    end

    context 'when existing_model' do
      let(:model) { existing_model }

      it 'can get.' do
        expect(subject).not_to be_nil
      end
    end

    context 'when deleted_model' do
      let(:model) { deleted_model }

      it 'can get.' do
        expect(subject).not_to be_nil
      end
    end
  end

  describe 'without_deleted' do
    subject do
      ParanoidModel.without_deleted.find_by(id: model.id)
    end

    context 'when existing_model' do
      let(:model) { existing_model }

      it 'can get.' do
        expect(subject).not_to be_nil
      end
    end

    context 'when deleted_model' do
      let(:model) { deleted_model }

      it 'can not get.' do
        expect(subject).to be_nil
      end
    end
  end
end
