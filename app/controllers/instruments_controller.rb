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

  # <tt>GET /instruments.xml</tt>
  #
  # Renders an XML sheet containing all instruments, sorted by description.
  # If HTML output is requested, user is  redirected to '/'.
  #
  def index
    @instruments = params[:search] ? Instrument.find_used : Instrument.find(:all, :order => 'description')
    
    respond_to do |format|
      format.xml
      format.html { redirect_to '/' }
    end
  end
  
end
