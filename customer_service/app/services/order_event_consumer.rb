# frozen_string_literal: true

require "bunny"
require "json"

class OrderEventConsumer
  EXCHANGE_NAME = "orders"
  QUEUE_NAME = "order_created_customer_service"
  ROUTING_KEY = "order.created"

  def self.run
    new.run
  end

  def run
    connection = Bunny.new(connection_url)
    connection.start

    channel = connection.create_channel
    exchange = channel.topic(EXCHANGE_NAME, durable: true)
    queue = channel.queue(QUEUE_NAME, durable: true)
    queue.bind(exchange, routing_key: ROUTING_KEY)

    queue.subscribe(block: true) do |_delivery_info, _properties, body|
      process_message(body)
    end
  rescue Bunny::TCPConnectionFailedForAllHosts, Bunny::ConnectionClosedError => e
    Rails.logger.error("OrderEventConsumer: #{e.message}")
  end

  def process_message(body)
    payload = JSON.parse(body)
    return unless payload["event_type"] == "order.created"

    customer_id = payload["customer_id"]
    customer = Customer.find_by(id: customer_id)
    customer&.increment_orders_count!
  rescue JSON::ParserError, ActiveRecord::RecordNotFound => e
    Rails.logger.error("OrderEventConsumer process_message: #{e.message}")
  end

  private

  def connection_url
    host = ENV.fetch("RABBITMQ_HOST", "rabbitmq")
    port = ENV.fetch("RABBITMQ_PORT", "5672")
    user = ENV.fetch("RABBITMQ_USER", "guest")
    pass = ENV.fetch("RABBITMQ_PASSWORD", "guest")
    "amqp://#{user}:#{pass}@#{host}:#{port}"
  end
end
