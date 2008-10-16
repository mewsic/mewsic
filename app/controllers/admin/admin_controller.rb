class Admin::AdminController < ApplicationController #:nodoc:
  before_filter :admin_required
  layout nil
  helper :all

  private
    def update_after_destroy
      render(:update) do |page|
        page.remove "row_#{params[:id]}"
        page.hide 'editing'
      end
    end
end
