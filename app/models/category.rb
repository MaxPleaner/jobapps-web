class Category < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  def companies
    Company.where(category: self.name)
  end
end
