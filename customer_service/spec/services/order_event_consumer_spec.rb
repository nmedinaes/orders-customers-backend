# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderEventConsumer do
  describe "#process_message" do
    let(:consumer) { described_class.new }

    it "increments orders_count when valid order.created event" do
      customer = create(:customer, orders_count: 2)
      payload = {
        "event_type" => "order.created",
        "customer_id" => customer.id
      }.to_json

      consumer.send(:process_message, payload)

      expect(customer.reload.orders_count).to eq(3)
    end

    it "does nothing when customer does not exist" do
      payload = {
        "event_type" => "order.created",
        "customer_id" => 99999
      }.to_json

      expect { consumer.send(:process_message, payload) }.not_to raise_error
    end

    it "does nothing when event_type is not order.created" do
      customer = create(:customer, orders_count: 2)
      payload = {
        "event_type" => "order.updated",
        "customer_id" => customer.id
      }.to_json

      consumer.send(:process_message, payload)

      expect(customer.reload.orders_count).to eq(2)
    end
  end
end
