require 'rspec'
require_relative 'spec_helper'

describe 'Sending broadcast messages' do

  let :broadcast_id do
    'rspec'
  end

  it 'sends multicast messages' do
    configure = -> (config) {
      config.host = '127.0.0.1'
      config.port = 5672
      config.ssl = false
      config.vhost = '/'
      config.user = 'guest'
      config.pass = 'guest'
      config.heartbeat = :server
      config.frame_max = 131072
      config.auth_mechanism = 'PLAIN'
    }
    sender = Messaging::MessageEmitter.broadcast_sender(broadcast_id: broadcast_id, &configure)
    receiver_one = Messaging::MessageReceiver.broadcast_receiver(broadcast_id: broadcast_id, &configure)
    receiver_two = Messaging::MessageReceiver.broadcast_receiver(broadcast_id: broadcast_id, &configure)

    test_message = 'test'
    received_one = received_two = nil
    receiver_one.start { |body| received_one = body }
    receiver_two.start { |body| received_two = body }

    sender.publish test_message

    expect(received_one).to eq test_message
    expect(received_two).to eq test_message
  end
end