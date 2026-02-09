class CreateCompanyNames < ActiveRecord::Migration[8.1]
  def change
    create_table :company_names do |t|
      t.integer :company_id
      t.string :name
      t.boolean :is_current

      t.timestamps
    end
  end
end
