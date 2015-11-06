module Messaging
  class MessageEmitter

    def initialize(queue_id: 'anonymous')
      @queue_id = queue_id
    end

    def publish(content)
      conn = Bunny.new
      conn.start

      channel = conn.create_channel
      q = channel.queue @queue_id

      channel.default_exchange.publish(content, routing_key: q.name)

      conn.close
    end

  end
end
