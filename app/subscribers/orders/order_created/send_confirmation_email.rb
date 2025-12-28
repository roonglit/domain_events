module Orders
  module OrderCreated
    class SendConfirmationEmail
      include DomainEvents::Subscriber

      handles_event "order.created"

      def call(event)
        order_id = event.payload[:order_id]
        order = Order.find(order_id)
        p "---> Sending confirmation email for Order ##{order.id}"
      end
    end
  end
end