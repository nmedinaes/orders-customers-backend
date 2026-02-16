# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.bigint :customer_id, null: false, index: true
      t.string :product_name, null: false
      t.integer :quantity, null: false, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
