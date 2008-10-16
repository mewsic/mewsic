class Admin::StaticPagesController < Admin::AdminController #:nodoc:
  def index
    @pages = StaticPage.find(:all, :order => 'id DESC')
  end

  def new
    @page = StaticPage.new
    render :action => 'show'
  end

  def show
    @page = StaticPage.find_from_param(params[:id])
  end

  def create
    @page = StaticPage.new(params[:static_page])
    @page.save!

    render(:update) do |page|
      page.hide 'editing'
    end

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end

  def update
    @page = StaticPage.find_from_param(params[:id])
    @page.update_attributes! params[:static_page]
    render(:update) { |page| page.hide 'editing' }

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end
end
