class Admin::HelpPagesController < Admin::AdminController #:nodoc:
  def index
    @pages = HelpPage.find(:all, :order => 'position')
  end

  def rearrange
    @page = HelpPage.find_from_param(params[:id])
    @page.send!(params[:move] == 'up' ? :move_higher : :move_lower)
    
    index
    render :action => 'index'
  end
  
  def new
    @page = HelpPage.new
    render :action => 'show'
  end

  def show
    @page = HelpPage.find_from_param(params[:id])
  end

  def create
    @page = HelpPage.new(params[:help_page])
    @page.save!

    render(:update) do |page|
      page.hide 'editing'
    end

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end

  def update
    @page = HelpPage.find_from_param(params[:id])
    @page.update_attributes! params[:help_page]
    render(:update) { |page| page.hide 'editing' }

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end
end
