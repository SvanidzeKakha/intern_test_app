class UserTableRenameCountryFix < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :county, :country
  end
end
