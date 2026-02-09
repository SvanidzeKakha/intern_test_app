class Product < ApplicationRecord
  has_many :user_product_interests
  has_many :users, through: :user_product_interests
  has_many :product_names
end