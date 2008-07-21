class InstrumentsController < ApplicationController

  def index
    @instruments = Instrument.find(:all, :order => 'description')
    
    respond_to do |format|
      format.xml
      format.html { redirect_to '/' }
    end
  end
  
end
