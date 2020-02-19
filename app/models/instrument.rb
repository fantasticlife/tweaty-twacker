class Instrument < ActiveRecord::Base
  
  def tweet_text
    tweet_text = ''
    tweet_text = tweet_text + self.lead_organisation
    tweet_text = tweet_text + ' treaty '
    tweet_text = tweet_text + self.series
    tweet_text = tweet_text + ' has been laid by the FCO '
    tweet_text = tweet_text + url
    tweet_text
  end
  
  def url
    'https://treaties.parliament.uk/treaty/' + self.instrument_id + '/'
  end
  
  def instrument_id
    self.instrument_uri.split( '/' ).last
  end
end
