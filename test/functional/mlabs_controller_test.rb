require 'rexml/document'

require File.dirname(__FILE__) + '/../test_helper'

class MlabsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :all
  
  def setup
    @controller = MlabController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_redirect_unless_logged_in
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_should_redirect_unless_logged_in_as_quetin
    login_as :user_4
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_should_success_if_logged_in_as_quetin
    login_as :quentin
    get :index, :user_id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_create
    login_as :quentin
    assert_difference 'Mlab.count', 2 do
      post :create, :user_id => users(:quentin).id, :type => 'track', :item_id => tracks(:sax_for_let_it_be).id, :format => 'xml'         
      post :create, :user_id => users(:quentin).id, :type => 'song',  :item_id => songs(:let_it_be).id, :format => 'xml'
    end
  end
  
  def test_should_not_create
    login_as :quentin
    assert_difference 'Mlab.count', 0 do
      post :create, :user_id => users(:quentin).id, :type => 'track', :item_id => 0, :format => 'xml'
    end
  end  
  
  def test_should_destroy
    login_as :quentin
    assert_difference 'Mlab.count', -1 do
      post :destroy, :format => 'js', :user_id => users(:quentin).id, :id => users(:quentin).mlabs.first.id
    end    
  end
  
  def test_new_should_send_authenticity_token
    login_as :quentin
    get :new, :user_id => users(:quentin).id, :format => 'xml'
    assert_response :success
    xml = REXML::Document.new(@response.body)
    assert_equal 1, REXML::XPath.match(xml, "/response/authenticity_token").size    
  end
  
  def test_should_destroy_with_xml_format
    login_as :quentin
    assert_difference 'Mlab.count', -1 do
      post :destroy, :format => 'xml', :user_id => users(:quentin).id, :id => users(:quentin).mlabs.first.id
    end    
  end    
  
end
