require 'bundler'
Bundler.require
require 'sinatra/reloader' if development?
Dotenv.load

module Simple
  # Default application
  class App < Sinatra::Base
    enable :sessions
    set :session_secret, ENV['APP_SECRET']

    get '*' do
      case error_type
      when 'random_error'
        random_error
      when 'maintenance'
        maintenance
      when 'ddos'
        ddos
      end
    end

    private

    def error_type
      ENV['ERROR_TYPE'] || 'random_error'
    end

    def random_error
      method = [:refresh,
                :not_found,
                :maintenance,
                :maintenance_json].sample(1).first
      send(method)
    end

    def ddos
      if (count_requests % retry_limit) == 0
        reset_requests
        convert_to_real_response
      else
        refresh
      end
    end

    def refresh
      slim :refresh
      headers \
        'Cache-Control' => 'no-cache',
        'Connection' => 'Close',
        'Content-Type' => 'text/html',
        'charset' => 'iso-8859-1',
        'Pragma' => 'no-cache',
        'Refresh' => '0.1'
    end

    def not_found
      status 404
      slim :not_found
    end

    def maintenance
      status 503
      slim :maintenance
    end

    def maintenance_json
      status 503
      jbuilder :maintenance
    end

    def count_requests
      req = session[:requests] || 0
      req += 1
      session[:requests] = req
      req
    end

    def reset_requests
      session[:requests] = 0
    end

    def retry_limit
      ENV['APP_REFRESH_RETRY'].to_i || 5
    end

    def convert_to_real_response
      url = request.url.gsub(/#{request.host}/, ENV['APP_DEST_HOST'])
      response = Faraday.get(url)
      headers \
        'content-type' => response.headers['content-type']
      body response.body
    end
  end
end
