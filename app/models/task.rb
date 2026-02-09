class Task < ApplicationRecord
	validates :title, presence: true
	validates :title, length: { minimum: 3 }
	validates :status, presence: true
	scope :new_first, -> {order(created_at: :desc)}

end
