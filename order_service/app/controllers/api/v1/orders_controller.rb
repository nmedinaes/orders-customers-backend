# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show]

      def index
        customer_id = params[:customer_id]
        return render json: { error: "customer_id is required" }, status: :unprocessable_content if customer_id.blank?

        page = (params[:page] || 1).to_i
        per_page = [(params[:per_page] || 20).to_i, 100].min
        orders = Order.by_customer(customer_id).order(created_at: :desc)
        total = orders.count
        orders = orders.offset((page - 1) * per_page).limit(per_page)
        render json: { orders: orders, total: total, page: page, per_page: per_page }
      end

      def show
        render json: @order
      end

      def create
        customer_id = order_params[:customer_id]
        customer_details = CustomerServiceClient.find(customer_id)

        unless customer_details
          return render json: { error: "Customer not found" }, status: :unprocessable_content
        end

        @order = Order.new(order_params)
        if @order.save
          OrderEventPublisher.publish(@order)
          response = @order.as_json.merge(
            customer_details: customer_details.to_h
          )
          render json: response, status: :created
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end

      def order_params
        params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
      end
    end
  end
end
