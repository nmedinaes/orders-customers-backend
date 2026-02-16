# frozen_string_literal: true

customers_data = [
  { customer_name: "Juan García", address: "Calle 100 #15-20, Bogotá" },
  { customer_name: "María Rodríguez", address: "Cra 43A #1-50, Medellín" },
  { customer_name: "Carlos López", address: "Av 6N #28N-30, Cali" },
  { customer_name: "Ana Martínez", address: "Calle 34 #43-82, Barranquilla" },
  { customer_name: "Pedro Hernández", address: "Cra 19 #34-24, Cartagena" },
  { customer_name: "Laura Sánchez", address: "Calle 53 #23-45, Pereira" },
  { customer_name: "Andrés González", address: "Cra 7 #32-16, Bucaramanga" },
  { customer_name: "Sofia Ramírez", address: "Av 68 #100-10, Bogotá" },
  { customer_name: "Diego Torres", address: "Cra 50 #10-20, Manizales" },
  { customer_name: "Valentina Díaz", address: "Calle 10 #43-50, Medellín" }
]

customers_data.each do |attrs|
  Customer.find_or_create_by!(customer_name: attrs[:customer_name]) do |c|
    c.address = attrs[:address]
    c.orders_count = 0
  end
end
