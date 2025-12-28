module Orders
  class Create
    def initialize(params)
      @params = params
    end

    def call
      order = Order.new(@params)
      if order.save
        publish_order_created(order)
        Result.success(order)
      else
        Result.failure(order.errors)
      end
    end

    private

    def publish_order_created(order)
      ActiveSupport::Notifications.instrument("order.created",
        order_id: order.id
      )
    end
  end
end