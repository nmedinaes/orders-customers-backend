# frozen_string_literal: true

namespace :orders do
  desc "Start the order event consumer"
  task consumer: :environment do
    OrderEventConsumer.run
  end
end
