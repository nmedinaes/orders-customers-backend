# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    customer_name { "Test Customer" }
    address { "123 Test St" }
    orders_count { 0 }
  end
end
