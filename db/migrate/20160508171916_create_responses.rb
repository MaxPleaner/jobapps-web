class CreateResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :responses do |t|
      t.integer :company_id
      t.text :content
      t.boolean :pinned
      t.boolean :followup
      t.timestamps
    end
  end
end
