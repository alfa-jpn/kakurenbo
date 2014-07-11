require 'spec_helper'

describe Kakurenbo::Core::Callbacks do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }
  before :all do
    ParanoidModel.tap do |klass|
      klass.before_destroy    :callback_before_destroy
      klass.after_destroy     :callback_after_destroy
      klass.after_commit      :callback_after_commit

      klass.before_restore    :callback_before_restore
      klass.after_restore     :callback_after_restore

      klass.before_update     :callback_before_update
      klass.before_save       :callback_before_save
      klass.before_validation :callback_before_validation
    end
  end

  let! :model do
    model_class.create!
  end

  let :model_class do
    ParanoidModel.tap do |klass|
      allow_any_instance_of(klass).to receive(:callback_before_destroy)    { true }
      allow_any_instance_of(klass).to receive(:callback_after_destroy)     { true }
      allow_any_instance_of(klass).to receive(:callback_after_commit)      { true }

      allow_any_instance_of(klass).to receive(:callback_before_restore)    { true }
      allow_any_instance_of(klass).to receive(:callback_after_restore)     { true }

      allow_any_instance_of(klass).to receive(:callback_before_update)     { true }
      allow_any_instance_of(klass).to receive(:callback_before_save)       { true }
      allow_any_instance_of(klass).to receive(:callback_before_validation) { true }
    end
  end

  context 'when call #delete' do
    subject { model.delete }

    it 'destroy-callbacks will not be called.' do
      expect(model).not_to receive(:callback_before_destroy)
      expect(model).not_to receive(:callback_after_destroy)
      expect(model).not_to receive(:callback_after_commit)

      subject
    end

    it 'save-callbacks will not be called.' do
      expect(model).not_to receive(:callback_before_update)
      expect(model).not_to receive(:callback_before_save)
      expect(model).not_to receive(:callback_before_validation)

      subject
    end
  end

  context 'when call #destroy' do
    subject { model.destroy }

    it 'destroy-callbacks will be called.' do
      expect(model).to receive(:callback_before_destroy).once
      expect(model).to receive(:callback_after_destroy).once
      expect(model).to receive(:callback_after_commit).once

      subject
    end

    it 'save-callbacks will not be called.' do
      expect(model).not_to receive(:callback_before_update)
      expect(model).not_to receive(:callback_before_save)
      expect(model).not_to receive(:callback_before_validation)

      subject
    end
  end

  context 'when call #restore' do
    before :each do
      model.destroy!
    end

    subject { model.restore }

    it 'restore-callbacks will be called.' do
      expect(model).to receive(:callback_before_restore).once
      expect(model).to receive(:callback_after_restore).once
      expect(model).to receive(:callback_after_commit).once

      subject
    end

    it 'save-callbacks will not be called.' do
      expect(model).not_to receive(:callback_before_update)
      expect(model).not_to receive(:callback_before_save)
      expect(model).not_to receive(:callback_before_validation)

      subject
    end
  end
end
