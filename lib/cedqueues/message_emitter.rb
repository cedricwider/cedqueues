require 'ostruct'

module Messaging
  class MessageEmitter

    def self.single_queue_sender(options = OpenStruct.new, queue_id:)
      yield(options) if block_given?
      self.new(connect_settings: options.to_h,
               publish_args: {routing_key: queue_id},
               exchange_creator: -> (channel) {
                 channel.queue queue_id
                 channel.default_exchange
               })
    end

    def self.broadcast_sender(options = OpenStruct.new, broadcast_id:)
      yield(options) if block_given?
      self.new(connect_settings: options.to_h,
               exchange_creator: -> (channel) {
                 channel.fanout(broadcast_id)
               })
    end

    def publish(content, properties = nil)
      conn = Bunny.new(@connect_settings)
      conn.start

      channel = conn.create_channel
      exchange = @exchange_creator.call(channel)

      exchange.publish(content, properties || @publish_args)

      conn.close
    end

    private

    def initialize(connect_settings:, publish_args: {}, exchange_creator:)
      @connect_settings = connect_settings
      @publish_args = publish_args
      @exchange_creator = exchange_creator
    end

  end
end
