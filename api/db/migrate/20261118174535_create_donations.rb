class CreateDonations < ActiveRecord::Migration[8.1]
  def change
    create_table :donations do |t|
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "usd"
      t.integer :status, null: false, default: 0
      t.integer :frequency, null: false, default: 0
      t.references :donor, null: false, foreign_key: true
      t.references :fund, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.string :idempotency_key, null: false

      t.index :stripe_payment_intent_id, unique: true
      t.index :idempotency_key, unique: true


      t.timestamps
    end
  end
end
