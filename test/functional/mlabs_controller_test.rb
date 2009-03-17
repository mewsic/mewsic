require 'rexml/document'

require File.dirname(__FILE__) + '/../test_helper'

class MlabsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :users, :mlabs, :songs, :tracks

  tests MlabsController
  
  def test_should_redirect_unless_logged_in
    get :index, :user_id => users(:quentin).id, :format => 'js'
    assert_response :forbidden
  end
  
  def test_should_forbid_if_trying_to_access_not_own_playlist
    login_as :user_4
    get :index, :user_id => users(:quentin).id
    assert_response :forbidden
  end

  def test_should_success_if_accessing_own_playlist
    login_as :quentin
    get :index, :user_id => users(:quentin).id, :format => 'js'
    assert_response :success
  end
  
  def test_should_create
    login_as :quentin
    assert_difference 'Mlab.count', 2 do
      post :create, :type => 'track', :user_id => users(:quentin).id,
        :item_id => tracks(:sax_for_let_it_be).id, :format => 'js'

      assert_response :success
      assert assigns(:mlab)
      assert_equal assigns(:mlab).user, users(:quentin)
      assert_equal assigns(:mlab).mixable, tracks(:sax_for_let_it_be)

      post :create, :type => 'song', :user_id => users(:quentin).id,
        :item_id => songs(:let_it_be).id, :format => 'js'

      assert_response :success
      assert assigns(:mlab)
      assert_equal assigns(:mlab).user, users(:quentin)
      assert_equal assigns(:mlab).mixable, songs(:let_it_be)
    end
  end
  
  def test_should_not_create
    login_as :quentin

    assert_no_difference 'Mlab.count' do
      post :create, :user_id => users(:quentin).id, :type => 'track',
        :item_id => 0, :format => 'js'
      assert_response :not_found

      post :create, :user_id => users(:quentin).id, :type => 'song',
        :item_id => 0, :format => 'js'
      assert_response :not_found
    end
  end
  
  def test_should_destroy
    login_as :quentin
    assert_difference 'Mlab.count', -1 do
      delete :destroy, :user_id => users(:quentin).id, :id => users(:quentin).mlabs.first.id, :format => 'js'
      assert_response :success
    end    

    assert_difference 'Mlab.count', -1 do
      delete :destroy, :user_id => users(:quentin).id, :id => users(:quentin).reload.mlabs.first.id, :format => 'js'
      assert_response :success
    end    
  end
  
  def test_should_not_destroy
    login_as :quentin
    assert_difference 'Mlab.count', 0 do
      delete :destroy, :user_id => users(:quentin).id, :id => 0, :format => 'js'
      assert_response :not_found

      delete :destroy, :user_id => users(:john).id, :id => users(:john).mlabs.first.id, :format => 'js'
      assert_response :forbidden
    end    
  end
  
  def test_should_redirect_if_format_is_not_javascript
    login_as :quentin

    assert_no_difference 'Mlab.count' do
      get :index, :user_id => users(:quentin).id, :format => 'html'
      assert_redirected_to '/'
    end

    assert_difference 'Mlab.count' do
      post :create, :type => 'track', :user_id => users(:quentin).id,
        :item_id => tracks(:sax_for_let_it_be).id, :format => 'html'

      assert_redirected_to '/'
    end

    assert_difference 'Mlab.count', -1 do
      delete :destroy, :user_id => users(:quentin).id,
        :id => users(:quentin).mlabs.first.id, :format => 'html'

      assert_redirected_to '/'
    end

  end
  
end
