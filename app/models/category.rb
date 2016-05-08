class Category < ApplicationRecord
  validates :name, uniqueness: true

  def companies
    Company.where(category: self.name)
  end
end
