require "bundler"
Bundler.require

module Simple
  # Default application
  class App < Sinatra::Base
    get '*' do
      method = [:random_refresh,
                :error_404,
                :maintenance,
                :maintenance_json].sample(1).first
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

    def maintenance
      status 503
      slim :maintenance
    end

    def maintenance_json
      status 503
      jbuilder :maintenance
    end
  end
end
