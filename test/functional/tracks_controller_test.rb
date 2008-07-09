require File.dirname(__FILE__) + '/../test_helper'

class TracksControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper

  fixtures :all

  def test_index_should_response_success
    get :index, :id => users(:quentin).id
    assert_response :success
  end
  
  def test_show_should_response_success
    get :show, :id => tracks(:sax_for_let_it_be)
    assert_response :success
  end
  
  def test_show_should_raise_exception_unless_track
    begin
      get :show, :id => 0
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end
  
  def test_toggle_idea_should_redirect_if_not_logged_in
    put :toggle_idea, :user_id => users(:quentin).id, :id => tracks(:guitar_for_closer).id
    assert_redirected_to new_session_path
  end
  
  def test_toggle_idea_should_redirect_current_user_is_not_the_track_user
    login_as :user_10
    put :toggle_idea, :user_id => users(:quentin).id, :id => tracks(:guitar_for_closer).id
    assert_redirected_to new_session_path
  end
  
  def test_toggle_idea_should_toggle_idea
    login_as :quentin
    t = tracks(:guitar_for_closer)
    is_idea = t.idea?
    put :toggle_idea, :user_id => users(:quentin).id, :id => t.id
    assert_not_equal is_idea, t.reload.idea?
    put :toggle_idea, :user_id => users(:quentin).id, :id => t.id
    assert_equal is_idea, t.reload.idea?
    
    assert_redirected_to user_path(users(:quentin))
  end
  
  def test_toggle_idea_should_toggle_idea_and_render_js
    login_as :quentin
    t = tracks(:guitar_for_closer)
    is_idea = t.idea?
    xhr :put, :toggle_idea, :user_id => users(:quentin).id, :id => t.id
    assert_response :success
  end
  
end
