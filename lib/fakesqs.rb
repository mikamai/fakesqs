require 'fakesqs/api'
require 'fakesqs/catch_errors'
require 'fakesqs/collection_view'
require 'fakesqs/error_response'
require 'fakesqs/message'
require 'fakesqs/queue'
require 'fakesqs/queue_factory'
require 'fakesqs/queues'
require 'fakesqs/responder'
require 'fakesqs/server'
require 'fakesqs/version'
require 'fakesqs/memory_database'
require 'fakesqs/file_database'

module FakeSQS

  def self.to_rack(options)

    require 'fakesqs/web_interface'
    app = FakeSQS::WebInterface

    if (log = options[:log])
      file = File.new(log, "a+")
      file.sync = true
      app.use Rack::CommonLogger, file
      app.set :log_file, file
      app.enable :logging
    end

    if options[:verbose]
      require 'fakesqs/show_output'
      app.use FakeSQS::ShowOutput
      app.enable :logging
    end

    if options[:daemonize]
      require 'fakesqs/daemonize'
      Daemonize.new(options).call
    end

    app.set :port, options[:port] if options[:port]
    app.set :bind, options[:host] if options[:host]
    app.set :server, options[:server] if options[:server]
    server = FakeSQS.server(port: options[:port], host: options[:host])
    app.set :api, FakeSQS.api(server: server, database: options[:database])
    app
  end

  def self.server(options = {})
    Server.new(options)
  end

  def self.api(options = {})
    db = database_for(options.fetch(:database) { ":memory:" })
    API.new(
      server: options.fetch(:server),
      queues: queues(db),
      responder: responder
    )
  end

  def self.queues(database)
    Queues.new(queue_factory: queue_factory, database: database)
  end

  def self.responder
    Responder.new
  end

  def self.queue_factory
    QueueFactory.new(message_factory: message_factory, queue: queue)
  end

  def self.message_factory
    Message
  end

  def self.queue
    Queue
  end

  def self.database_for(name)
    if name == ":memory:"
      MemoryDatabase.new
    else
      FileDatabase.new(name)
    end
  end

end
