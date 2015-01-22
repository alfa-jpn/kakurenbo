require 'spec_helper'

#
#               NormalChildModel         [has_many]
# ParentModel < ParanoidChildModel       [has_many]
#               ParanoidSingleChildModel [has_many][belongs_to]
#
describe Kakurenbo::Core do
  create_temp_table(:parent_models)                { |t| t.integer :child_belongs_to_id; t.datetime :deleted_at }
  create_temp_table(:normal_child_models)          { |t| t.integer :parent_model_id }
  create_temp_table(:paranoid_child_models)        { |t| t.integer :parent_model_id; t.datetime :deleted_at }
  create_temp_table(:paranoid_single_child_models) { |t| t.integer :parent_model_id; t.datetime :deleted_at }

  subject :subject_hard_delete do
    create_unrelated_children
    expect { parent.destroy!(hard: true) }.to change{ child_class.with_deleted.count }.by(children.length * -1)
  end

  subject :subject_soft_delete do
    create_unrelated_children
    expect { parent.destroy! }.to change(child_class, :count).by(children.length * -1)
  end

  subject :subject_restore do
    create_unrelated_children
    expect { parent.destroy! }.to change(child_class, :count).by(children.length * -1)
    expect { parent.restore! }.to change(child_class, :count).by(children.length)
  end

  subject :subject_not_restore do
    parent.destroy!
    expect { parent.restore! }.not_to change(child_class, :count)
  end

  subject :subject_destroy_child_with_where do
    expect { destroy_child_with_where }.to change(child_class, :count).by(2)
  end

  let :create_unrelated_children do
    [
      child_class.create!,
      child_class.create!,
    ]
  end

  let :destroy_children do
    children.each {|child| child.destroy!}
  end

  let :destroy_child_with_where do
    parent.normal_child_models.where(id: children.first.id).destroy_all
  end

  let :parent do
    parent_class.create!
  end

  let :parent_class do
    ParentModel.tap do |parent_class|
      parent_class.has_many :normal_child_models,   :dependent => :destroy
      parent_class.has_many :paranoid_child_models, :dependent => :destroy

      parent_class.has_one     :child_has_one, :class_name => :ParanoidSingleChildModel, :dependent => :destroy
      parent_class.belongs_to  :child_belongs_to, :class_name => :ParanoidSingleChildModel, :dependent => :destroy
    end
  end

  describe 'NormalChildModel' do
    let :child_class do
      NormalChildModel
    end

    let :children do
      [
        parent.normal_child_models.create!,
        parent.normal_child_models.create!,
        parent.normal_child_models.create!,
      ]
    end

    context 'when parent is destroyed' do
      it 'related children will be destroyed.' do
        subject_soft_delete
      end
    end

    context 'when child is deleted by destroy_all with where,' do
      it 'child will be delete.' do
        subject_destroy_child_with_where
      end
    end
  end

  describe 'ParanoidChildModel(has_many)' do
    let :child_class do
      ParanoidChildModel
    end

    let :children do
      [
        parent.paranoid_child_models.create!,
        parent.paranoid_child_models.create!,
        parent.paranoid_child_models.create!,
      ]
    end

    context 'when parent is destroyed' do
      it 'related children will be destroyed.' do
        subject_soft_delete
      end
    end

    context 'when parent is hard-destroyed' do
      it 'related children will be hard-destroyed.' do
        subject_hard_delete
      end
    end

    context 'when parent is restored' do
      it 'related children will be restored.' do
        subject_restore
      end

      context 'when children are deleted, before restore parent' do
        before :each do
          destroy_children
        end

        it 'related children will be not restored.' do
          subject_not_restore
        end
      end
    end
  end

  describe 'ParanoidSingleChildModel(has_one)' do
    let :child_class do
      ParanoidSingleChildModel
    end

    let :children do
      [
        parent.create_child_has_one!
      ]
    end

    context 'when parent is destroyed' do
      it 'related children will be destroyed.' do
        subject_soft_delete
      end
    end

    context 'when parent is hard-destroyed' do
      it 'related children will be hard-destroyed.' do
        subject_hard_delete
      end
    end

    context 'when parent is restored' do
      it 'related children will be restored.' do
        subject_restore
      end

      context 'when children are deleted, before restore parent' do
        before :each do
          destroy_children
        end

        it 'related children will be not restored.' do
          subject_not_restore
        end
      end
    end
  end

  describe 'ParanoidSingleChildModel(belongs_to)' do
    let :child_class do
      ParanoidSingleChildModel
    end

    let :children do
      [
        parent.create_child_belongs_to!
      ]
    end

    context 'when parent is destroyed' do
      it 'related children will be destroyed.' do
        subject_soft_delete
      end
    end

    context 'when parent is hard-destroyed' do
      it 'related children will be hard-destroyed.' do
        subject_hard_delete
      end
    end

    context 'when parent is restored' do
      it 'related children will be restored.' do
        subject_restore
      end

      context 'when children are deleted, before restore parent' do
        before :each do
          destroy_children
        end

        it 'related children will be not restored.' do
          subject_not_restore
        end
      end
    end
  end
end
