require 'rexml/document'

require File.dirname(__FILE__) + '/../test_helper'

class MlabsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :all
  
  def setup
    @controller = MlabsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_redirect_unless_logged_in
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_should_redirect_unless_logged_in_as_quentin
    login_as :user_4
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_should_success_if_logged_in_as_quentin
    login_as :quentin
    get :index, :user_id => users(:quentin).id
    assert_response :success

    get :index, :user_id => users(:quentin).id, :format => 'js'
    assert_response :success
  end
  
  def test_should_create
    login_as :quentin
    assert_difference 'Mlab.count', 2 do
      post :create, :type => 'track', :user_id => users(:quentin).id, :item_id => tracks(:sax_for_let_it_be).id, :format => 'xml'         
      assert_response :success
      assert assigns(:mlab)
      assert_equal assigns(:mlab).user_id, users(:quentin).id
      assert_equal assigns(:mlab).mixable_id, tracks(:sax_for_let_it_be).id
      assert_equal assigns(:mlab).mixable_type, 'Track'

      assert assigns(:item)
      assert_equal assigns(:item).class, Hash
      assert_equal assigns(:item)['type'], 'track'
      assert_equal assigns(:item)['id'], tracks(:sax_for_let_it_be).id

      post :create, :type => 'song', :user_id => users(:quentin).id, :item_id => songs(:let_it_be).id, :format => 'js'
      assert_response :success
      assert assigns(:mlab)
      assert_equal assigns(:mlab).user_id, users(:quentin).id
      assert_equal assigns(:mlab).mixable_id, songs(:let_it_be).id
      assert_equal assigns(:mlab).mixable_type, 'Song'

      assert assigns(:item)
      assert_equal assigns(:item).class, Hash
      assert_equal assigns(:item)['type'], 'song'
      assert_equal assigns(:item)['id'], songs(:let_it_be).id
    end
  end
  
  def test_should_not_create
    login_as :quentin

    assert_no_difference 'Mlab.count' do
      post :create, :user_id => users(:quentin).id, :type => 'track', :item_id => 0, :format => 'xml'
      assert_response :not_found

      post :create, :user_id => users(:quentin).id, :type => 'song', :item_id => 0, :format => 'xml'
      assert_response :not_found
    end

    assert_no_difference 'Mlab.count' do
      post :create, :user_id => users(:quentin).id, :type => 'track', :item_id => 0, :format => 'js'
      assert_response :not_found

      post :create, :user_id => users(:quentin).id, :type => 'song', :item_id => 0, :format => 'js'
      assert_response :not_found
    end
  end
  
  def test_should_destroy
    login_as :quentin
    assert_difference 'Mlab.count', -1 do
      post :destroy, :user_id => users(:quentin).id, :id => users(:quentin).mlabs.first.id, :format => 'js'
      assert_response :success
    end    

    assert_difference 'Mlab.count', -1 do
      post :destroy, :user_id => users(:quentin).id, :id => users(:quentin).reload.mlabs.first.id, :format => 'xml'
      assert_response :success
    end    
  end
  
  def test_should_not_destroy
    login_as :quentin
    assert_difference 'Mlab.count', 0 do
      post :destroy, :format => 'js', :user_id => users(:quentin).id, :id => 0
      assert_response :not_found

      post :destroy, :format => 'xml', :user_id => users(:quentin).id, :id => 0
      assert_response :not_found
    end    
  end
  
end
