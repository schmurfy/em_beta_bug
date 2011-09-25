
#
# basic thread pool, extracted from thin sources
#
module Rack
  class Threaded
    def initialize(app, options= {})
      @app = app
      @rescue_exception = options[:rescue_exception] || Proc.new { |env, e| [500, {}, "#{e.class.name}: #{e.message.to_s}"] }
      yield if block_given?
    end

    def call(env)      
      EM::defer do
        begin
          result = @app.call(env)
          env['async.callback'].call result
        rescue ::Exception => e
          env['async.callback'].call @rescue_exception.call(env, e)
        end
      end
      
      throw :async
    end
    
  end
end

EmBetaBug::Application.configure do
  puts "[WARN] Enabling threadsafe mode, reloader disabled."
  config.threadsafe!
  config.middleware.insert_before(Rack::Runtime, Rack::Threaded)
end
