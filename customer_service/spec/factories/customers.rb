# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    customer_name { "Carlos Rodríguez" }
    address { "Cra 15 #32-45, Bogotá" }
    orders_count { 0 }
  end
end
