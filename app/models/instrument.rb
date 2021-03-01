class Instrument < ActiveRecord::Base
  
  def description
    description = ''
    description = description + self.title
    description = description + ' was laid on '
    description = description + self.date_laid.strftime( '%d-%m-%Y')
    description = description + ' by the FCDO, as '
    description = description + self.series
    description = description + '. Lead by the '
    description = description + self.lead_organisation
    description = description + '.'
    description
  end
  
  def tweet_text
    tweet_text = ''
    tweet_text = tweet_text + self.lead_organisation
    tweet_text = tweet_text + ' treaty '
    tweet_text = tweet_text + self.series
    tweet_text = tweet_text + ' has been laid by the FDCO '
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
