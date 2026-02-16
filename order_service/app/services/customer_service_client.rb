# frozen_string_literal: true

require "httparty"

class CustomerServiceClient
  def initialize(base_url: nil)
    @base_url = base_url || ENV.fetch("CUSTOMER_SERVICE_URL", "http://customer_service:3000")
  end

  def find(customer_id)
    url = "#{@base_url}/api/v1/customers/#{customer_id}"
    response = HTTParty.get(url, headers: { "Accept" => "application/json" })
    unless response.success?
      Rails.logger.warn("CustomerServiceClient: GET #{url} failed - status=#{response.code} body=#{response.body&.slice(0, 200)}")
      return nil
    end

    OpenStruct.new(
      customer_id: response.parsed_response["id"],
      customer_name: response.parsed_response["customer_name"],
      address: response.parsed_response["address"],
      orders_count: response.parsed_response["orders_count"]
    )
  end

  class << self
    def find(customer_id)
      new.find(customer_id)
    end
  end
end
