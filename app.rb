require 'sinatra/base'
require 'sinatra/reloader'
require 'slim'
require 'jbuilder'

module Simple
  # Default application
  class App < Sinatra::Base
    get '*' do
      status 503
      body 'Service temporary not available'
      #status 500
      #body 'Internal server error occured'
    end
  end
end
