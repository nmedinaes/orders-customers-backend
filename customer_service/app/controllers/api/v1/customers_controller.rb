# frozen_string_literal: true

module Api
  module V1
    class CustomersController < ApplicationController
      def show
        @customer = Customer.find(params[:id])
        render json: {
          id: @customer.id,
          customer_name: @customer.customer_name,
          address: @customer.address,
          orders_count: @customer.orders_count
        }
      end

      def index
        customers = Customer.all.order(:id)
        render json: customers
      end
    end
  end
end
