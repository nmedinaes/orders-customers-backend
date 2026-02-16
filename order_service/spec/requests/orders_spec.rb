# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Orders API", type: :request do
  before do
    customer_response = {
      id: 1,
      customer_name: "María García",
      address: "Calle 80 #12-30, Medellín",
      orders_count: 0
    }.to_json
    stub_request(:get, %r{/api/v1/customers/1})
      .to_return(status: 200, body: customer_response, headers: { "Content-Type" => "application/json" })
  end

  describe "GET /api/v1/orders" do
    it "returns orders for a customer" do
      order = create(:order, customer_id: 1, product_name: "Widget", quantity: 2, price: 19.99)
      get "/api/v1/orders", params: { customer_id: 1 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["orders"].size).to eq(1)
      expect(json["orders"].first["product_name"]).to eq("Widget")
      expect(json["orders"].first["customer_id"]).to eq(1)
      expect(json["total"]).to eq(1)
      expect(json["page"]).to eq(1)
      expect(json["per_page"]).to eq(20)
    end

    it "returns error when customer_id is missing" do
      get "/api/v1/orders"
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("customer_id is required")
    end

    it "returns empty array when no orders exist" do
      get "/api/v1/orders", params: { customer_id: 999 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["orders"]).to eq([])
      expect(json["total"]).to eq(0)
    end
  end

  describe "POST /api/v1/orders" do
    it "creates an order when customer exists" do
      expect(OrderEventPublisher).to receive(:publish).with(instance_of(Order))
      post "/api/v1/orders", params: {
        order: {
          customer_id: 1,
          product_name: "Gadget",
          quantity: 3,
          price: 29.99,
          status: "pending"
        }
      }, as: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["product_name"]).to eq("Gadget")
      expect(json["quantity"]).to eq(3)
      expect(json["customer_details"]["customer_name"]).to eq("María García")
      expect(Order.count).to eq(1)
    end

    it "returns error when customer not found" do
      stub_request(:get, %r{/api/v1/customers/999})
        .to_return(status: 404, body: "", headers: {})
      post "/api/v1/orders", params: {
        order: {
          customer_id: 999,
          product_name: "Gadget",
          quantity: 1,
          price: 9.99
        }
      }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Customer not found")
    end

    it "returns validation errors for invalid order" do
      post "/api/v1/orders", params: {
        order: {
          customer_id: 1,
          product_name: "",
          quantity: -1,
          price: -5
        }
      }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end

  describe "GET /api/v1/orders/:id" do
    it "returns a single order" do
      order = create(:order, customer_id: 1, product_name: "Widget")
      get "/api/v1/orders/#{order.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(order.id)
      expect(json["product_name"]).to eq("Widget")
    end
  end
end
