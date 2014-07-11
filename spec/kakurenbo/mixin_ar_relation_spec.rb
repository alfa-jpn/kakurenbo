require 'spec_helper'

describe Kakurenbo::MixinARRelation do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }

  subject :subject_hard_delete do
    expect {
      subject
    }.to change {
      model_class.with_deleted.find_by(:id => model.id)
    }.to(nil)
  end

  subject :subject_soft_delete do
    expect { subject }.to change { model.reload.destroyed? }.from(false).to(true)
  end

  subject :subject_restore do
    expect { subject }.to change { model.reload.destroyed? }.from(true).to(false)
  end

  let! :model do
    model_class.create!
  end

  let :model_class do
    ParanoidModel
  end

  describe '.delete' do
    subject { model_class.delete(model.id) }

    it 'record will be soft-deleted.' do
      subject_soft_delete
    end

    context 'when with hard-delete option' do
      subject { model_class.delete(model.id, :hard => true) }

      it 'record will be hard-deleted.' do
        subject_hard_delete
      end
    end
  end

  describe '.delete_all' do
    subject { model_class.delete_all }

    it 'record will be soft-deleted.' do
      subject_soft_delete
    end

    context 'when with hard-delete option' do
      subject { model_class.delete_all(nil, :hard => true) }

      it 'record will be hard-deleted' do
        subject_hard_delete
      end
    end
  end

  describe '.destroy' do
    subject { model_class.destroy(model.id) }

    it 'record will be soft-deleted.' do
      subject_soft_delete
    end

    context 'when with hard-delete option' do
      subject { model_class.destroy(model.id, :hard => true) }

      it 'record will be hard-deleted.' do
        subject_hard_delete
      end
    end
  end

  describe '.destroy_all' do
    subject { model_class.destroy_all }

    it 'record will be soft-deleted.' do
      subject_soft_delete
    end

    context 'when with hard-delete option' do
      subject { model_class.destroy_all(nil, :hard => true) }

      it 'record will be hard-deleted' do
        subject_hard_delete
      end
    end
  end

  describe '.restore' do
    before :each do
      model.destroy
    end

    subject { model_class.restore(model.id) }

    it 'record will be restored.' do
      subject_restore
    end
  end

  describe '.restore_all' do
    before :each do
      model.destroy
    end

    subject { model_class.restore_all }

    it 'record will be restored.' do
      subject_restore
    end
  end
end
