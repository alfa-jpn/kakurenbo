require 'spec_helper'

describe Kakurenbo::SoftDeleteCore::Callbacks do
  create_temp_table(:paranoid_models){ |t| t.datetime :deleted_at }

  before :each do
    class ParanoidModel < ActiveRecord::Base; end
  end

  after :each do
    Object.class_eval{ remove_const :ParanoidModel }
  end

  context 'when run callback of restore' do
    before :each do
      @callback_model = ParanoidModel.create!
    end

    after :each do
      @callback_model.run_callbacks(:restore)
    end

    it 'call before_restore.' do
      ParanoidModel.before_restore :before_restore_callback
      expect(@callback_model).to receive(:before_restore_callback).once
    end

    it 'call around_restore.' do
      ParanoidModel.around_restore :around_restore_callback
      expect(@callback_model).to receive(:around_restore_callback).once
    end

    it 'call after_restore.' do
      ParanoidModel.after_restore :after_restore_callback
      expect(@callback_model).to receive(:after_restore_callback).once
    end
  end
end
