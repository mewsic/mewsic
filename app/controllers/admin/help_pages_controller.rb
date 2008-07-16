class Admin::HelpPagesController < Admin::AdminController
  def index
    @pages = HelpPage.find(:all, :order => 'position')
  end
  
  def show
    @page = HelpPage.find_from_param(params[:id])
  end

  def update
    @page = HelpPage.find_from_param(params[:id])
    @page.update_attributes! params[:help_page]
    render(:update) { |page| page.hide 'editing' }

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end
end
