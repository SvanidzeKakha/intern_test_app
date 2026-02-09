class User < ApplicationRecord
  belongs_to :company
  has_many :user_product_interests
  has_many :products, through: :user_product_interests
end