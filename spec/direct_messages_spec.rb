require 'rspec'

require_relative 'spec_helper'

describe 'Sending direct messages' do

  it 'sends message to queue' do
    # given sender & receiver...
    emitter = Messaging::MessageEmitter.single_queue_sender(queue_id: 'rspec')
    receiver = Messaging::MessageReceiver.single_queue_receiver(queue_id: 'rspec')

    # ...and
    test_message = 'test'
    received_message = nil
    receiver.start do |body|
      received_message = body
    end

    # when
    emitter.publish(test_message)

    # then
    expect(received_message).to eq test_message
  end
end