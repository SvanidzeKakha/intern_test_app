class RemoveIsCurrentFromNameTables < ActiveRecord::Migration[8.1]
  def change
    remove_column :product_names, :is_current, :boolean
    remove_column :company_names, :is_current, :boolean
  end
end
