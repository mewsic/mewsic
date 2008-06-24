require File.dirname(__FILE__) + '/../test_helper'

class HelpControllerTest < ActionController::TestCase
  fixtures :help_pages

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    ActionMailer::Base.deliveries = []
  end

  def test_should_show_help_page
    get :index
    assert_response :success
  end

  def test_should_fetch_help_content
    get :index, :id => help_pages(:one).id
    assert_response :success

    # TODO: assert_select
  end

  def test_should_redirect_if_no_help_request_was_posted
    get :send_mail
    assert_response :redirect
  end

  def test_should_validate_help_request
    post :send_mail, :help => { :email => '', :body => '' }

    assert_response :success
    assert assigns(:help_request).errors.on(:email)
    assert assigns(:help_request).errors.on(:body)

    post :send_mail, :help => { :email => 'invalid email', :body => 'aaaaa' }

    assert_response :success
    assert assigns(:help_request).errors.on(:email)
  end

  def test_should_send_help_request
    post :send_mail, :help => { :email => 'vjt@example.org', :body => 'test request' }

    assert_response :redirect
    assert flash[:notice]
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end
