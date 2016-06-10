class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :name, unique: true
      t.text :desc
      t.text :applied
      t.text :todo
      t.text :skip
      t.text :rejected
      t.string :notlaughing

      t.timestamps
    end
  end
end
