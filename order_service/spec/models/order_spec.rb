# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      order = build(:order, customer_id: 1, product_name: "Widget", quantity: 2, price: 9.99, status: "pending")
      expect(order).to be_valid
    end

    it "is invalid without customer_id" do
      order = build(:order, customer_id: nil)
      expect(order).not_to be_valid
      expect(order.errors[:customer_id]).to include("can't be blank")
    end

    it "is invalid without product_name" do
      order = build(:order, product_name: nil)
      expect(order).not_to be_valid
      expect(order.errors[:product_name]).to include("can't be blank")
    end

    it "is invalid with quantity less than 1" do
      order = build(:order, quantity: 0)
      expect(order).not_to be_valid
      expect(order.errors[:quantity]).to include("must be greater than 0")
    end

    it "is invalid with negative price" do
      order = build(:order, price: -1)
      expect(order).not_to be_valid
    end

    it "is invalid with invalid status" do
      order = build(:order, status: "invalid_status")
      expect(order).not_to be_valid
      expect(order.errors[:status]).to include("is not included in the list")
    end

    it "is valid with allowed statuses" do
      %w[pending processing shipped delivered cancelled].each do |status|
        order = build(:order, status: status)
        expect(order).to be_valid
      end
    end
  end

  describe "scopes" do
    it "returns orders filtered by customer_id" do
      order1 = create(:order, customer_id: 1)
      order2 = create(:order, customer_id: 2)
      order3 = create(:order, customer_id: 1)

      expect(Order.by_customer(1)).to contain_exactly(order1, order3)
    end
  end
end
