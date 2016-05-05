class AddJobsToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :jobs, :text
  end
end
