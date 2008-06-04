class InstrumentsController < ApplicationController

  def index
    @instruments = Instrument.find(:all, :order => 'description')
    
    respond_to do |format|
      format.xml
    end
  end
  
end
