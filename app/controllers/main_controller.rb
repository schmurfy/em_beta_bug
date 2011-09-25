class MainController < ApplicationController
  def index
    http = load_page('http://google.com')
    render :text => "Done"
  end

private
  def load_page(url)
    th = Thread.current
    
    if th == EM::reactor_thread
      raise "Trying to issue an HTTP Request from the EventMachine thread, aborting..."
    end
    
    uri = URI.parse(url)
    http = EventMachine::Protocols::HttpClient.request(
        :host => uri.host,
        :port => uri.port,
        :request => uri.path
      )
    
    # does not work either
    # http = EM::HttpRequest.new(url).get(:head => {
    #     'user-agent'  => "Mac FireFox",
    #     'cookie'      => 'birthtime=-2208959999' # this takes care of the age check
    #   })

    http.callback do
      Rails.logger.debug("callback, waking up thread #{'%#x' % Thread.current.object_id}")
      th.wakeup
    end
    
    http.errback do
      Rails.logger.debug("errback, waking up thread #{'%#x' % Thread.current.object_id}")
      th.wakeup
    end
    
    Rails.logger.debug("[#{'%#x' % Thread.current.object_id}]Thread suspended")
    sleep
    
    Rails.logger.debug("[#{'%#x' % Thread.current.object_id}]Thread woken up")
    
    # test if loading was a success or not 
    # if http.error
    #   raise PageLoadFailed, http
    # end
    
    http
  end
end
