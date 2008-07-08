module Admin::DashboardHelper
  def edit_link_to(name, options = {}, html_options = {})
    link_to name, options, html_options.merge(:class => 'edit-link')
  end

  def edit_form_for(object, options, &block)
    remote_form_for object, options.merge(:update => 'editing'), &block
  end
end
