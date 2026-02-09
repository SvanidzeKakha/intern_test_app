class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :industry
      t.string :size

      t.timestamps
    end
  end
end
