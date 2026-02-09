class CreateProductNames < ActiveRecord::Migration[8.1]
  def change
    create_table :product_names do |t|
      t.integer :product_id
      t.string :name
      t.boolean :is_current

      t.timestamps
    end
  end
end
