# Ensure the Subscriber module is loaded first
require_dependency Rails.root.join("app/lib/domain_event/subscriber")

module DomainEvent
  def self.subscribe(event_name, handler)
    ActiveSupport::Notifications.subscribe(event_name) do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      handler.call(event)
    end
  end

  def self.register_all
    # Load all subscriber files
    Dir[Rails.root.join("app/subscribers/**/*.rb")].each do |file|
      require_dependency file
    end

    # Wire up each subscriber from the registry
    registry.each do |klass|
      subscribe(klass.event_name, klass.new)
    end
  end
end

DomainEvent.register_all