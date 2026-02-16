# frozen_string_literal: true

class Customer < ApplicationRecord
  validates :customer_name, presence: true
  validates :address, presence: true
  validates :orders_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def increment_orders_count!
    increment!(:orders_count)
  end
end
