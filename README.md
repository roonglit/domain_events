# Domain Events Demo

A Rails demonstration project showcasing how to implement a clean domain events pattern using ActiveSupport::Notifications with automatic subscriber registration.

## Overview

This project demonstrates a simple yet powerful pattern for decoupling business logic using domain events. When something important happens in your application (like creating an order), you can publish an event that multiple subscribers can react to independently.

## Architecture

The implementation consists of three main components:

1. **Event Publisher**: Services that publish events when domain actions occur
2. **Subscriber Registry**: Automatically discovers and registers all event subscribers
3. **Event Subscribers**: Handlers that react to specific events

### How It Works

```
┌─────────────┐      publishes      ┌──────────────────┐
│   Service   │ ─────────────────> │ ActiveSupport::  │
│             │                     │  Notifications   │
└─────────────┘                     └──────────────────┘
                                            │
                                            │ notifies
                                            ▼
                                    ┌──────────────────┐
                                    │   Subscribers    │
                                    │  (auto-wired)    │
                                    └──────────────────┘
```

## Usage

### 1. Publishing an Event

In your service objects, use `ActiveSupport::Notifications.instrument` to publish events:

```ruby
# app/services/orders/create.rb
module Orders
  class Create
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
```

### 2. Creating a Subscriber

Create a subscriber class that includes `DomainEvent::Subscriber` and declares which event it handles:

```ruby
# app/subscribers/orders/order_created/send_confirmation_email.rb
module Orders
  module OrderCreated
    class SendConfirmationEmail
      include DomainEvent::Subscriber

      handles_event "order.created"

      def call(event)
        order_id = event.payload[:order_id]
        order = Order.find(order_id)
        # Send confirmation email logic here
        puts "---> Sending confirmation email for Order ##{order.id}"
      end
    end
  end
end
```

### 3. Automatic Registration

Subscribers are automatically discovered and registered at application initialization. No manual wiring required!

The initializer (`config/initializers/domain_events.rb`) automatically:
- Loads all subscriber files from `app/subscribers/**/*.rb`
- Registers each subscriber with its declared event
- Wires up the event handlers

## File Structure

```
app/
├── lib/
│   └── domain_events/
│       └── subscriber.rb          # Base subscriber module with DSL
├── services/
│   └── orders/
│       └── create.rb              # Example service that publishes events
└── subscribers/
    └── orders/
        └── order_created/
            └── send_confirmation_email.rb  # Example subscriber

config/
└── initializers/
    └── domain_events.rb           # Auto-registration setup
```

## Adding New Events

To add a new event to your application:

1. **Publish the event** in your service/model:
   ```ruby
   ActiveSupport::Notifications.instrument("your.event.name",
     your_data: value
   )
   ```

2. **Create a subscriber** in `app/subscribers/`:
   ```ruby
   class YourSubscriber
     include DomainEvent::Subscriber

     handles_event "your.event.name"

     def call(event)
       # Handle the event
       data = event.payload[:your_data]
     end
   end
   ```

3. **Restart your application** - the subscriber will be automatically registered!

## Benefits

- **Decoupling**: Publishers don't know about subscribers
- **Single Responsibility**: Each subscriber handles one specific reaction
- **Easy Testing**: Test publishers and subscribers independently
- **Scalability**: Add new subscribers without modifying existing code
- **Auto-discovery**: No manual registration required

## Event Naming Convention

Use dot notation for event names to create clear namespaces:

- `order.created` - When a new order is created
- `order.shipped` - When an order is shipped
- `user.registered` - When a user signs up
- `payment.processed` - When a payment completes

## Setup

```bash
bundle install
rails db:create db:migrate
rails server
```

## Example

Try creating an order through the Rails console:

```ruby
Orders::Create.new(name: "Test Order").call
# => ---> Sending confirmation email for Order #1
```

The event is automatically published and all registered subscribers are notified!
