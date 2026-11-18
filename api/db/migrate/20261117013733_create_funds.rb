class CreateFunds < ActiveRecord::Migration[8.1]
  def change
    create_table :funds do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.boolean :active, null: false, default: true
      t.boolean :is_default, null: false, default: false

      t.index :slug, unique: true
      t.index :is_default, unique: true, where: 'is_default = true'
      t.index :name, unique: true

      t.timestamps
    end
  end
end
