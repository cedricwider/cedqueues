#!/usr/bin/env ruby

require 'bunny'
require 'logger'

require_relative 'event'
require_relative '../worklog'

module Messaging

  # Message Receiver subscribes to a rabbit queue with a given name.
  # It then listens for incoming messages.
  class MessageReceiver

    # initialize
    #
    # auto_recover: should be pretty self explanatory.
    # queue_id: The id of the queue to subscribe to.
    def initialize(auto_recover: false, queue_id: 'anonymous')
      @logger = Logger.new(STDOUT)
      @conn = Bunny.new(automatically_recover: auto_recover)
      @conn.start
      channel = @conn.create_channel
      @queue = channel.queue(queue_id)
      @logger.debug 'EventReceiver ready. Waiting to start'
    end

    # subscribe to the given queue and execute given block whenever a message is received.
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

    private

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
