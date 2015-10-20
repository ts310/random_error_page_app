require 'sinatra/base'
require 'sinatra/reloader'
require 'slim'
require 'jbuilder'

module Simple
  # Default application
  class App < Sinatra::Base
    get '*' do
      method = [:random_refresh,
                :error_404,
                :maintentance].sample(1).first
      send(method)
    end

    private

    def random_refresh
      if rand(1..10).even?
        refresh
      else
        slim :index
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

    def error_404
      status 404
      slim :error_404
    end

    def maintentance
      status 503
      slim :error_503
    end
  end
end
