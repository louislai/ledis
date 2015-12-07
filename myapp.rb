require 'sinatra'
require 'json'
require './ledis'

class MyApp < Sinatra::Base
  def initialize(app = nil)
    super(app)
    @ledis = ::Ledis.new
  end

  post '/redis' do
    response = @ledis.handle_command params[:command].split
    content_type :json
    { response: response }.to_json
  end

  get '/' do
    'Hello World'
  end
end
