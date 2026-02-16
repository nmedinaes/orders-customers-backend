# frozen_string_literal: true

require "rails_helper"

RSpec.describe CustomerServiceClient do
  let(:client) { described_class.new(base_url: "http://test-customer-service:3000") }

  describe "#find" do
    it "returns customer details when customer exists" do
      customer_data = {
        id: 1,
        customer_name: "Alice Johnson",
        address: "123 Main St",
        orders_count: 5
      }
      stub_request(:get, "http://test-customer-service:3000/api/v1/customers/1")
        .to_return(status: 200, body: customer_data.to_json, headers: { "Content-Type" => "application/json" })

      result = client.find(1)

      expect(result).not_to be_nil
      expect(result.customer_id).to eq(1)
      expect(result.customer_name).to eq("Alice Johnson")
      expect(result.address).to eq("123 Main St")
      expect(result.orders_count).to eq(5)
    end

    it "returns nil when customer not found" do
      stub_request(:get, "http://test-customer-service:3000/api/v1/customers/999")
        .to_return(status: 404, body: "", headers: {})

      result = client.find(999)

      expect(result).to be_nil
    end
  end

  describe ".find" do
    it "delegates to instance" do
      stub_request(:get, %r{/api/v1/customers/1})
        .to_return(status: 200, body: { id: 1, customer_name: "Test", address: "Addr", orders_count: 0 }.to_json)

      result = described_class.find(1)

      expect(result.customer_name).to eq("Test")
    end
  end
end
