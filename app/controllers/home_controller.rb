class HomeController < ApplicationController
  
  def index
    @instruments = Instrument.all.order( 'date_laid desc')
  end
end
