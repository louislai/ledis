require 'sinatra'
require './ledis'

class MyApp < Sinatra::Base
  def initialize(app = nil)
    super(app)
    @ledis = ::Ledis.new
  end

  post '/ledis' do
    byebug
  end

  get '/' do
    'Hello World'
  end
end
