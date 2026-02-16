# frozen_string_literal: true

require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      customer = build(:customer, customer_name: "Laura Sánchez", address: "Calle 53 #23-45, Pereira")
      expect(customer).to be_valid
    end

    it "is invalid without customer_name" do
      customer = build(:customer, customer_name: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:customer_name]).to include("can't be blank")
    end

    it "is invalid without address" do
      customer = build(:customer, address: nil)
      expect(customer).not_to be_valid
    end

    it "is invalid with negative orders_count" do
      customer = build(:customer, orders_count: -1)
      expect(customer).not_to be_valid
    end
  end

  describe "#increment_orders_count!" do
    it "increments orders_count by 1" do
      customer = create(:customer, orders_count: 5)
      customer.increment_orders_count!
      expect(customer.reload.orders_count).to eq(6)
    end
  end
end
