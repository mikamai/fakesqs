require 'fakesqs/actions/change_message_visibility'
require 'fakesqs/actions/create_queue'
require 'fakesqs/actions/delete_queue'
require 'fakesqs/actions/list_queues'
require 'fakesqs/actions/get_queue_url'
require 'fakesqs/actions/send_message'
require 'fakesqs/actions/receive_message'
require 'fakesqs/actions/delete_message'
require 'fakesqs/actions/delete_message_batch'
require 'fakesqs/actions/purge_queue'
require 'fakesqs/actions/send_message_batch'
require 'fakesqs/actions/get_queue_attributes'
require 'fakesqs/actions/set_queue_attributes'

module FakeSQS

  InvalidAction = Class.new(ArgumentError)

  class API

    attr_reader :queues, :options

    def initialize(options = {})
      @queues    = options.fetch(:queues)
      @options   = options
      @run_timer = true
      @timer     = Thread.new do
        while @run_timer
          queues.timeout_messages!
          sleep(5)
        end
      end
    end

    def call(action, *args)
      if FakeSQS::Actions.const_defined?(action)
        action = FakeSQS::Actions.const_get(action).new(options)
        queues.transaction do
          action.call(*args)
        end
      else
        fail InvalidAction, "Unknown (or not yet implemented) action: #{action}"
      end
    end

    # Fake actions

    def reset
      queues.reset
    end

    def expire
      queues.expire
    end

    def stop
      @run_timer = false
    end

  end
end
