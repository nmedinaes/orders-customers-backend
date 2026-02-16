# frozen_string_literal: true

require "bunny"

class OrderEventPublisher
  EXCHANGE_NAME = "orders"
  ROUTING_KEY = "order.created"

  def self.publish(order)
    new.publish(order)
  end

  def publish(order)
    connection = Bunny.new(connection_url)
    connection.start

    channel = connection.create_channel
    exchange = channel.topic(EXCHANGE_NAME, durable: true)

    payload = {
      event_type: "order.created",
      order_id: order.id,
      customer_id: order.customer_id,
      product_name: order.product_name,
      quantity: order.quantity,
      price: order.price.to_s,
      status: order.status,
      created_at: order.created_at.iso8601
    }.to_json

    exchange.publish(payload, routing_key: ROUTING_KEY)
    connection.close
  rescue Bunny::TCPConnectionFailedForAllHosts, Bunny::ConnectionClosedError => e
    Rails.logger.error("OrderEventPublisher: #{e.message}")
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
