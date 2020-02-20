task :cleanup => [
  :cleanup_tweeted_instruments] do
end

task :cleanup_tweeted_instruments => :environment do
  puts "cleaning up old instruments that have been tweeted"
  # go back 30 days to avoid clashes between importing today, tweeting, deleting and accidentally reimporting etc
  date = 30.days.ago.to_date
  instruments = Instrument.where( 'date_laid < ?', date ).where( is_tweeted: :true )
  puts "cleaning up #{instruments.size} tweeted instruments"
  instruments.each do |instrument|
    instrument.destroy
  end
end