class ActsAsTaggableMigration < ActiveRecord::Migration
  def self.up
    create_table :logged_actions do |t|
      t.belongs_to :scope, :polymorphic => true
      t.text       :description
      t.text       :parameters
      t.timestamp  :created_at
    end

    add_index :logged_actions, [ :scope_type, :scope_id, :created_at ]
  end
  
  def self.down
    drop_table :logged_actions
  end
end