require File.dirname(__FILE__) + '/../../test_helper'

class Admin::MassMessagesControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    super
    ActionMailer::Base.deliveries = []
  end

  def test_mass_message
    login_as :john

    post :create, :message => {:subject => 'Test', :body => 'Test a lot'}
    assert_redirected_to :action => 'index'

    assert assigns(:message).valid?
    assert_equal 'Test', assigns(:message).subject
    assert_equal 'Test a lot', assigns(:message).body

    assert_equal User.count_activated - 1, ActionMailer::Base.deliveries.size
  end
end
