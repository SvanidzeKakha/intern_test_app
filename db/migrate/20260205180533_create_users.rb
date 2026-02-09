class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :fname
      t.string :lname
      t.string :phone
      t.string :county
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
