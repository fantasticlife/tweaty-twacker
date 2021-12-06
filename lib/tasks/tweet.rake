gem 'twitter'
require 'twitter'

consumer_key = ENV['CONSUMER_KEY']
consumer_secret = ENV['CONSUMER_SECRET']
access_token = ENV['ACCESS_TOKEN']
access_secret = ENV['ACCESS_SECRET']

task :tweet => [
  :tweet_the_untweeted] do
end

task :tweet_the_untweeted => :environment do
  puts "tweeting new instruments"
  instruments = Instrument.where( is_tweeted: false )
  puts "tweeting #{instruments.size} instruments"
  instruments.each do |instrument|
    puts instrument.tweet_text
    client = TwitterOAuth::Client.new(
        :consumer_key => consumer_key,
        :consumer_secret => consumer_secret,
        :token => access_token,
        :secret => access_secret
    )
    puts "Authorised: #{client.authorized?}"
  
    client.update( instrument.tweet_text )
    instrument.is_tweeted = true
    instrument.save
  end
end