class CreateDonors < ActiveRecord::Migration[8.1]
  def change
    create_table :donors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.index :email, unique: true

      t.timestamps
    end
  end
end
