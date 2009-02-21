module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    @request.session[:user] = user ? users(user).id : nil
  end

  def logout
    logout_from_controller!
    login_as nil
  end

  def authorize_as(user)
    authorization = 'Basic ' + Base64.encode64("#{users(user).login}:test") if user
    @request.env['HTTP_AUTHORIZATION'] = authorization || nil
  end

  def deauthorize
    logout_from_controller!
    authorize_as nil
  end

  private
    def logout_from_controller!
      @controller.send :current_user=, nil
    end
end
