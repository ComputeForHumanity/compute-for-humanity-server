class AddRecruitsTable < ActiveRecord::Migration
  def change
    create_table :recruits, id: false do |t|
      t.string :uuid, null: false
      t.integer :n_recruits, default: 0
    end

    add_index :recruits, :uuid, unique: true
  end
end
