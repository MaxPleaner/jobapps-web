class AddCategoryToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :category, :string
  end
end
