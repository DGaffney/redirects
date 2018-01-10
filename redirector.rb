require 'nokogiri'
require 'open-uri'
require 'json'
require 'redis'
require 'time'
require 'mongo'
$client = Mongo::Client.new([ "localhost" ], :database => "redirects", :max_pool_size => 100, :wait_queue_timeout => 60, :connect_timeout => 30, :socket_timeout => 30)
Mongo::Logger.logger.level = Logger::FATAL
$redis = Redis.new
latest = "https://permanent-redirect.xyz/pages/1515462547"
click_count = $client[:redirects].find.sort({click_count: -1}).first["click_count"] rescue 0
data = Nokogiri.parse(open(latest).read());false
while true
  if data.search("a").length == 2
    sleep(20)
    data = Nokogiri.parse(open(latest).read());false
  else
    latest = "https://permanent-redirect.xyz/pages/"+data.search("a")[0].attributes["href"].value.split("/").last
    data = Nokogiri.parse(open(latest).read());false
    latest_id = latest.split("/").last
    timestamp = Time.parse(data.search("p")[1].text.split("created at ").last.split(".").first)
    click_count += 1
    page_visitors = data.search("img").collect{|x| x.attributes["alt"].text}.join.to_i
    current_status = {time: Time.now, page_visitors: page_visitors, clicked_link: latest, latest_id: latest_id, timestamp: timestamp, click_count: click_count}
    $client[:redirects].insert_one(current_status)
    $redis.set("redirect_current_status", current_status.to_json)
  end
end
