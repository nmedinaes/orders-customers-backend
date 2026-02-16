# frozen_string_literal: true

class Order < ApplicationRecord
  validates :customer_id, presence: true
  validates :product_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing shipped delivered cancelled] }

  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
end
