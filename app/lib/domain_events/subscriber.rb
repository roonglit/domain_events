module DomainEvents
  module Subscriber
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def handles_event(name)
        @event_name = name
        DomainEvents.registry << self
      end

      def event_name
        @event_name
      end
    end
  end

  def self.registry
    @registry ||= []
  end
end