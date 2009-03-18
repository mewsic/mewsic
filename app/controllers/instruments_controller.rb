# Myousica Instruments Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
#
# == Description
# 
# This controller merely renders the instrument +index+ into an XML sheet used by the multitrack.
#
class InstrumentsController < ApplicationController

  # ==== GET /instruments.xml
  #
  # Renders an XML sheet containing all instruments, sorted by description.
  # If HTML output is requested, user is  redirected to root_path.
  #
  def index
    @instruments = Instrument.find(:all, :order => 'description')
    
    respond_to do |format|
      format.xml { render :partial => 'multitrack/instruments' }
      format.html { redirect_to root_path }
    end
  end
  
end
