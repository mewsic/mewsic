class InstrumentsController < ApplicationController

  def index
    @instruments = params[:search] ? Instrument.find_used : Instrument.find(:all, :order => 'description')
    
    respond_to do |format|
      format.xml
      format.html { redirect_to '/' }
    end
  end
  
end
