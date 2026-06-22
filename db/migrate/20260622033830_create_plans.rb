class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :price_cents
      t.string :interval
      t.string :stripe_price_id
      t.text :features

      t.timestamps
    end
  end
end
