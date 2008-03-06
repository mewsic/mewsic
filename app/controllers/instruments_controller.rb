class InstrumentsController < ApplicationController

  def index
    @instruments = Instrument.find(:all)
    
    respond_to do |format|
      format.xml
    end
  end
  
end
