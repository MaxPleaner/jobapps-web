class AddStarredToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :starred, :boolean
  end
end
