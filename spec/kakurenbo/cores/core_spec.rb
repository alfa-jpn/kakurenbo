require 'spec_helper'

describe Kakurenbo::Core do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }
  before :all do
    ParanoidModel.tap do |klass|
      klass.before_destroy    :callback_before_destroy
      klass.before_restore    :callback_before_restore
    end
  end

  subject :subject_hard_delete do
    expect {
      subject
    }.to change {
      model_class.with_deleted.find_by(:id => model.id)
    }.to(nil)
  end

  subject :subject_not_hard_delete do
    expect {
      subject
    }.not_to change {
      model_class.with_deleted.find_by(:id => model.id)
    }
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
    ParanoidModel.tap do |klass|
      allow_any_instance_of(klass).to receive(:callback_before_destroy)    { true }
      allow_any_instance_of(klass).to receive(:callback_before_restore)    { true }
    end
  end

  let :now do
    Time.now.tap do |now|
      allow(Time).to receive(:now) { now.dup }
    end
  end

  describe '#delete' do
    subject { model.delete }

    it 'record will be soft-deleted.' do
      subject_soft_delete
    end

    it 'record will not be hard-deleted.' do
      subject_not_hard_delete
    end

    context 'when with hard-delete option' do
      subject { model.delete(:hard => true) }

      it 'record will be hard-deleted.' do
        subject_hard_delete
      end
    end
  end

  describe '#destroy' do
    subject { model.destroy }

    it 'record will be soft-deleted.' do
      subject_soft_delete
    end

    it 'record will not be hard-deleted.' do
      subject_not_hard_delete
    end

    it 'return self' do
      expect(subject).to eq(model)
    end

    context 'when action is cancelled' do
      before :each do
        allow(model).to receive(:callback_before_destroy) { false }
      end

      it 'record will not be soft-deleted.' do
        expect { subject }.not_to change { model.reload.destroyed? }
      end

      it 'return falsey' do
        expect(subject).to be_falsey
      end
    end

    context 'when with hard-delete option' do
      subject { model.destroy(:hard => true) }

      it 'record will be hard-deleted.' do
        subject_hard_delete
      end
    end
  end

  describe '#destroy!' do
    subject { model.destroy! }
    context 'when action is cancelled' do
      before :each do
        allow(model).to receive(:callback_before_destroy) { false }
      end

      it 'raise ActiveRecord::RecordNotDestroyed' do
        expect{subject}.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end
  end

  describe '#destroyed?' do
    subject { model.destroyed? }

    context 'when model not deleted' do
      it 'return falsey' do
        expect(subject).to be_falsey
      end
    end

    context 'when model deleted' do
      before :each do
        model.destroy
      end

      it 'return truthy' do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#restore' do
    before :each do
      model.destroy
    end

    subject { model.restore }

    it 'record will be restored.' do
      subject_restore
    end

    it 'return self' do
      expect(subject).to eq(model)
    end

    context 'when action is cancelled' do
      before :each do
        allow(model).to receive(:callback_before_restore) { false }
      end

      it 'record will not be restored.' do
        expect { subject }.not_to change { model.reload.destroyed? }
      end

      it 'return falsey' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '#restore!' do
    subject { model.restore! }
    context 'when action is cancelled' do
      before :each do
        allow(model).to receive(:callback_before_restore) { false }
      end

      it 'raise ActiveRecord::RecordNotRestored' do
        expect{subject}.to raise_error(ActiveRecord::RecordNotRestored)
      end
    end
  end
end
