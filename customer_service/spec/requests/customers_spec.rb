# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Customers API", type: :request do
  describe "GET /api/v1/customers/:id" do
    it "returns customer details" do
      customer = create(:customer, customer_name: "Alice Johnson", address: "123 Main St", orders_count: 3)
      get "/api/v1/customers/#{customer.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(customer.id)
      expect(json["customer_name"]).to eq("Alice Johnson")
      expect(json["address"]).to eq("123 Main St")
      expect(json["orders_count"]).to eq(3)
    end

    it "returns 404 when customer not found" do
      get "/api/v1/customers/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/customers" do
    it "returns list of customers" do
      create(:customer, customer_name: "Alice")
      create(:customer, customer_name: "Bob")
      get "/api/v1/customers"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end
  end
end
