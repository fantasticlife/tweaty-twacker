class InstrumentController < ApplicationController
  
  def index
    @instruments = Instrument.all.order( 'date_laid desc')
  end
  
  def show
    instrument = params[:instrument]
    @instrument = Instrument.find( instrument )
  end
end
