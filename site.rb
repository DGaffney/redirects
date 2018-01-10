require 'json'
require 'redis'
require 'time'
require 'mongo'
require 'sinatra'
configure do
  enable :sessions
  set :session_secret, "secret"
end
$client = Mongo::Client.new([ "localhost" ], :database => "redirects", :max_pool_size => 100, :wait_queue_timeout => 60, :connect_timeout => 30, :socket_timeout => 30)
Mongo::Logger.logger.level = Logger::FATAL

get '/' do
  @latest = $client[:redirects].find.sort({time: -1}).first
  @count = $client[:redirects].count
  @stats = $client[:redirects].find({}).projection({page_visitors: 1, click_count: 1}).sort({time: 1}).to_a.collect{|r| [r["click_count"], r["page_visitors"]]}
  erb :index
end
