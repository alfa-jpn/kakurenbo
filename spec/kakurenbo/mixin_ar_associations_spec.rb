require 'spec_helper'

#
#               NormalChildModel                 [has_many]
# ParentModel < ParanoidChildModel               [has_many]
#               ParanoidSingleChildModel         [has_many][belongs_to]
#               ParentChild - ParanoidChildModel [intermediate]
#
describe Kakurenbo::MixinARAssociations::Association do
  create_temp_table(:parent_models)                { |t| t.integer :child_belongs_to_id; t.datetime :deleted_at }
  create_temp_table(:normal_child_models)          { |t| t.integer :parent_model_id }
  create_temp_table(:paranoid_child_models)        { |t| t.integer :parent_model_id; t.datetime :deleted_at }
  create_temp_table(:paranoid_single_child_models) { |t| t.integer :parent_model_id; t.datetime :deleted_at }
  create_temp_table(:parents_children)             { |t| t.integer :parent_model_id; t.integer :paranoid_child_model_id; t.datetime :deleted_at }

  subject do
    parent.destroy!
  end

  let :parent do
    parent_class.create!
  end

  let! :parents_child_class do
    ParentsChild.tap do |parents_child_class|
      parents_child_class.belongs_to :parent_model
      parents_child_class.belongs_to :paranoid_child_model
    end
  end

  let :parent_class do
    ParentModel.tap do |parent_class|
      parent_class.has_many :normal_child_models,   :dependent => :destroy
      parent_class.has_many :paranoid_child_models, :dependent => :destroy

      parent_class.has_one     :child_has_one, :class_name => :ParanoidSingleChildModel, :dependent => :destroy
      parent_class.belongs_to  :child_belongs_to, :class_name => :ParanoidSingleChildModel, :dependent => :destroy

      parent_class.has_many :parents_children, :dependent => :destroy
      parent_class.has_many :children, :through => :parents_children, :source => :paranoid_child_model
    end
  end

  describe 'NormalChildModel(has_many)' do
    let! :children do
      [
        parent.normal_child_models.create!,
        parent.normal_child_models.create!,
        parent.normal_child_models.create!,
      ]
    end

    context 'when destroyed parent is loaded' do
      it 'related children will be not loaded.' do
        expect(subject.normal_child_models.size).to eq(0)
      end
    end
  end

  describe 'ParanoidChildModel(has_many)' do
    let! :children do
      [
        parent.paranoid_child_models.create!,
        parent.paranoid_child_models.create!,
        parent.paranoid_child_models.create!,
      ]
    end

    context 'when destroyed parent is loaded' do
      it 'related children will be loaded.' do
        expect(subject.paranoid_child_models(true)).to contain_exactly(*children)
      end
    end
  end

  describe 'ParanoidSingleChildModel(has_one)' do
    let! :children do
      [
        parent.create_child_has_one!
      ]
    end

    context 'when destroyed parent is loaded' do
      it 'related children will be loaded.' do
        expect(subject.child_has_one(true)).to eq(*children)
      end
    end
  end

  describe 'ParanoidSingleChildModel(belongs_to)' do
    let! :children do
      [
        parent.create_child_belongs_to!
      ]
    end

    context 'when destroyed parent is loaded' do
      it 'related children will be loaded.' do
        expect(subject.child_belongs_to(true)).to eq(*children)
      end
    end
  end

  # Not Support ActiveRecord < 4.1
  unless ActiveRecord::VERSION::STRING < "4.1"
    describe 'ParanoidChild(intermediate table)' do
      let! :children do
        [
          parent.children.create!,
          parent.children.create!,
          parent.children.create!,
        ]
      end

      context 'when destroyed parent is loaded' do
        it 'related children will be loaded.' do
          expect(subject.children(true)).to contain_exactly(*children)
        end
      end
    end
  end
end
