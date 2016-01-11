#!/usr/bin/env ruby

require 'bunny'
require 'logger'
require 'ostruct'

module Messaging

  # Message Receiver subscribes to a rabbit queue with a given name.
  # It then listens for incoming messages.
  class MessageReceiver

    def self.single_queue_receiver(options = OpenStruct.new, queue_id:)
      yield(options) if block_given?
      self.new(options.to_h) do |channel|
        channel.queue(queue_id)
      end
    end

    def self.broadcast_receiver(options = OpenStruct.new, broadcast_id:)
      yield(options) if block_given?
      self.new(options.to_h) do |channel|
        queue = channel.queue('', exclusive: true)
        queue.bind(channel.fanout(broadcast_id))
        queue
      end
    end


    # subscribe to queue and execute given block whenever a message is received.
    #
    # Non-blocking implementation of the start method.
    def start(&block)
      subscribe(false, &block)
    end

    # Basically the same as +start+ only that this implementation
    # block the current thread.
    def start!(&block)
      @logger.info ' [*] Waiting for messages. To exit press CTRL+C'
      subscribe(true, &block)
    end

    def close
      @queue.close
      @conn.close
    end

    private

    def initialize(options=nil)
      @logger = Logger.new(STDOUT)

      @conn = Bunny.new(options)
      @conn.start
      channel = @conn.create_channel

      @queue = yield(channel)
      @logger.debug 'EventReceiver ready. Waiting to start'
    end

    # Subscribe to the queue and execute the given block.
    #
    # This is where the actual work gets done. Can be called
    # in either blocking or non-blocking mode using the parameter 'blocking'
    def subscribe(blocking = false, &block)
      begin
        @queue.subscribe(block: blocking) do |_, properties, body|
          @logger.debug "Delivery Info: (omitted for brevity) --- Properties: #{properties} --- Body: #{body}"
          block.call(body)
        end
      rescue Interrupt => _
        @conn.close
        @logger.info 'Received Interrupt. Exit'
        exit(0)
      end
    end

  end
end
