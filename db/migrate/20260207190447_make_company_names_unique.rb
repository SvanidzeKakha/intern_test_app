class MakeCompanyNamesUnique < ActiveRecord::Migration[8.1]
  def change
    add_index :company_names, [:company_id, :name], unique: true
  end
end
