class Admin::AdminController < ApplicationController
  before_filter :admin_required
  layout nil
end
