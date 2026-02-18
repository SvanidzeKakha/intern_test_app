class User < ApplicationRecord
  belongs_to :company
  has_many :user_product_interests
  has_many :products, through: :user_product_interests

  def self.search(query)
    if query.present?
      sanitized = ActiveRecord::Base.sanitize_sql_like(query)
      where("email LIKE ?","%#{sanitized}%")
    else
      all
    end
  end
end